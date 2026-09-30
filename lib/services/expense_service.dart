import 'dart:convert';

import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/expense_model.dart';
import 'package:http/http.dart' as http;

class ExpenseService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Votre session a expiré. Reconnectez-vous.');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ExpenseModel>> listAll() async {
    final headers = await _headers();
    final expenses = <ExpenseModel>[];
    var page = 1;
    var lastPage = 1;

    do {
      final uri = Uri.parse(
        '$_baseUrl/expenses',
      ).replace(queryParameters: {'per_page': '100', 'page': '$page'});
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      final data = _decodeResponse(response);
      final rows = data['data'];
      if (rows is! List) {
        throw const FormatException('La liste des dépenses est invalide.');
      }
      expenses.addAll(
        rows.whereType<Map>().map(
          (row) => ExpenseModel.fromJson(Map<String, dynamic>.from(row)),
        ),
      );
      page = int.tryParse(data['current_page']?.toString() ?? '') ?? page;
      lastPage = int.tryParse(data['last_page']?.toString() ?? '') ?? page;
      page++;
    } while (page <= lastPage);

    return expenses;
  }

  Future<List<Map<String, dynamic>>> listSuppliers() async {
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl/suppliers',
          ).replace(queryParameters: {'per_page': '100'}),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));
    final data = _decodeResponse(response);
    final rows = data['data'];
    if (rows is! List) {
      throw const FormatException('La liste des fournisseurs est invalide.');
    }
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<Map<String, dynamic>> createSupplier(
    Map<String, dynamic> payload,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/suppliers'),
          headers: await _headers(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));
    final data = _decodeResponse(response);
    final supplier = data['supplier'];
    if (supplier is! Map) {
      throw const FormatException(
        'La réponse de création du fournisseur est invalide.',
      );
    }
    return Map<String, dynamic>.from(supplier);
  }

  Future<ExpenseModel> createManual(Map<String, dynamic> payload) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/expenses'),
          headers: await _headers(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));
    final data = _decodeResponse(response);
    final expense = data['expense'];
    if (expense is! Map) {
      throw const FormatException(
        'La réponse de création de dépense est invalide.',
      );
    }
    return ExpenseModel.fromJson(Map<String, dynamic>.from(expense));
  }

  Future<Map<String, dynamic>> verifyMecefInvoice({
    required String code,
    required String nim,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/factures/verifications'),
          headers: await _headers(),
          body: jsonEncode({'code_mecef': code, 'nim': nim}),
        )
        .timeout(const Duration(seconds: 30));
    return _decodeResponse(response);
  }

  Future<ExpenseModel> createFromVerifiedInvoice({
    required int agencyId,
    required String code,
    required String nim,
    String? note,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/expenses/from-mecef'),
          headers: await _headers(),
          body: jsonEncode({
            'agency_id': agencyId,
            'code_mecef': code,
            'nim': nim,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          }),
        )
        .timeout(const Duration(seconds: 30));
    final data = _decodeResponse(response);
    final expense = data['expense'];
    if (expense is! Map) {
      throw const FormatException(
        'La réponse de création depuis la facture MECEF est invalide.',
      );
    }
    return ExpenseModel.fromJson(Map<String, dynamic>.from(expense));
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Réponse API invalide.');
      }
      data = Map<String, dynamic>.from(decoded);
    } on FormatException {
      throw Exception(
        response.statusCode >= 200 && response.statusCode < 300
            ? 'Réponse API invalide.'
            : 'Erreur ${response.statusCode} lors de la requête.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Erreur ${response.statusCode} lors de la requête.',
      );
    }
    return data;
  }
}
