import 'dart:convert';

import 'package:fofanavoyage/auth/stockage_auth_local.dart';
import 'package:fofanavoyage/config/app_config.dart';
import 'package:http/http.dart' as http;

class AccountDeletionService {
  Future<Map<String, dynamic>> deleteMyAccount() async {
    final token = await AuthLocalStore.getToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
    }

    final response = await http
        .delete(
          Uri.parse('${AppConfig.apiBaseUrl}/auth/client/account'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'Impossible de supprimer votre compte.',
      );
    }
    return data;
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const FormatException('Réponse API invalide.');
    }
    return Map<String, dynamic>.from(decoded);
  }
}
