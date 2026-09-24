import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/payment_provider_model.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';

class PaymentService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Récupère les agrégateurs activés pour l'agence (FedaPay, Feexpay, KkiaPay...).
  Future<List<PaymentProvider>> getProvidersActifs() async {
    final uri = Uri.parse('$baseUrl/paiements/providers-actifs');
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des moyens de paiement.');
    }

    final data = jsonDecode(response.body);
    final List providersJson = data['providers'] ?? [];
    return providersJson
        .map((e) => PaymentProvider.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Initie un paiement pour une entité payable donnée (ticket ou colis).
  Future<Map<String, dynamic>> initierPaiement({
    required String payableRef,
    required String provider,
    required String method,
    String payableType = 'ticket',
    String? clientEmail,
  }) async {
    final uri = Uri.parse('$baseUrl/paiements/initier');

    final body = {
      'payable_type': payableType,
      'payable_ref': payableRef,
      'provider': provider,
      'method': method,
      if (clientEmail != null) 'client_email': clientEmail,
    };

    final response = await http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message']?.toString() ?? 'Erreur lors de l\'initialisation du paiement.');
    }

    return data as Map<String, dynamic>;
  }

  /// Vérifie le statut du paiement.
  Future<Map<String, dynamic>> verifierPaiement({
    required String reference,
    String payableType = 'ticket',
    String? externalId,
  }) async {
    final uri = Uri.parse('$baseUrl/paiements/verifier');

    final body = {
      'reference': reference,
      'payable_type': payableType,
      if (externalId != null && externalId.isNotEmpty) 'external_id': externalId,
    };

    final response = await http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'Erreur lors de la vérification du paiement.');
    }

    return data as Map<String, dynamic>;
  }
}
