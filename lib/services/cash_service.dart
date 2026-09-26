import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/config/app_config.dart';

class CashSummary {
  final double balance;
  final double receipts;
  final double expenses;

  const CashSummary({
    required this.balance,
    required this.receipts,
    required this.expenses,
  });

  factory CashSummary.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) =>
        double.tryParse(value?.toString() ?? '') ?? 0;

    final source = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return CashSummary(
      balance: number(
        source['solde'] ?? source['balance'] ?? source['closing_balance'],
      ),
      receipts: number(
        source['recettes'] ?? source['receipts'] ?? source['total_recettes'],
      ),
      expenses: number(
        source['depenses'] ?? source['expenses'] ?? source['total_depenses'],
      ),
    );
  }
}

class CashService {
  static const _base = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<CashSummary> getSummary({int? agencyId, int? userId}) async {
    final query = <String, String>{
      if (agencyId != null) 'agency_id': '$agencyId',
      if (userId != null) 'user_id': '$userId',
      'status': 'ouverte',
    };
    final registersResponse = await http
        .get(
          Uri.parse('$_base/caisses').replace(queryParameters: query),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));
    if (registersResponse.statusCode != 200) {
      throw Exception(
        'Erreur ${registersResponse.statusCode} lors du chargement de la caisse.',
      );
    }

    final decoded = jsonDecode(registersResponse.body);
    final items = decoded is Map<String, dynamic> && decoded['data'] is List
        ? decoded['data'] as List
        : decoded is List
        ? decoded
        : const [];
    if (items.isEmpty || items.first is! Map<String, dynamic>) {
      return const CashSummary(balance: 0, receipts: 0, expenses: 0);
    }

    final register = items.first as Map<String, dynamic>;
    final id = register['id'];
    if (id == null) return CashSummary.fromJson(register);

    final balanceResponse = await http
        .get(Uri.parse('$_base/caisses/$id/solde'), headers: await _headers())
        .timeout(const Duration(seconds: 15));
    if (balanceResponse.statusCode != 200) {
      throw Exception(
        'Erreur ${balanceResponse.statusCode} lors du chargement du solde.',
      );
    }
    return CashSummary.fromJson(
      jsonDecode(balanceResponse.body) as Map<String, dynamic>,
    );
  }
}
