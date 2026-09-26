import 'dart:convert';

import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/tax_group_model.dart';
import 'package:http/http.dart' as http;

class TaxService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  Future<List<TaxGroup>> getGroupsForModule(
    String module, {
    bool includeInactive = false,
  }) async {
    final token = await AuthLocalStore.getToken();
    final uri = includeInactive
        ? Uri.parse(
            '$_baseUrl/taxes/groupes',
          ).replace(queryParameters: {'module': module})
        : Uri.parse(
            '$_baseUrl/taxes/par-module',
          ).replace(queryParameters: {'module': module});
    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': '******',
          },
        )
        .timeout(const Duration(seconds: 10));

    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message']?.toString() : null;
      throw Exception(message ?? 'Impossible de charger les groupes de taxes.');
    }

    final rows = decoded is List
        ? decoded
        : decoded is Map && decoded['data'] is List
        ? decoded['data'] as List
        : null;
    if (rows == null) {
      throw const FormatException(
        'La réponse des groupes de taxes est invalide.',
      );
    }

    return rows
        .whereType<Map>()
        .map((row) => TaxGroup.fromJson(Map<String, dynamic>.from(row)))
        .where((group) => group.id > 0)
        .toList();
  }
}
