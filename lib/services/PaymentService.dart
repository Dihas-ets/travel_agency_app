import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/auth/stockage_auth_local.dart';

class PaymentService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getProvidersActifs() async {
    final uri = Uri.parse('$baseUrl/paiements/providers-actifs');
    final response = await http.get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'Erreur chargement agrégateurs.');
    }
    return List<Map<String, dynamic>>.from(data['providers'] ?? []);
  }

  Future<Map<String, dynamic>> initierPaiement({
    required String payableType, // 'ticket' | 'colis'
    required String payableRef,  // reference du ticket
    required String provider,    // slug agrégateur, ex: 'fedapay'
    required String method,      // 'mtn' | 'moov' | ...
    String? clientEmail,
  }) async {
    final uri = Uri.parse('$baseUrl/paiements/initier');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'payable_type': payableType,
        'payable_ref': payableRef,
        'provider': provider,
        'method': method,
        if (clientEmail != null) 'client_email': clientEmail,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'Erreur initiation paiement.');
    }
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifierPaiement({
    required String reference, // reference de transaction OU du ticket
    String? externalId,
  }) async {
    final uri = Uri.parse('$baseUrl/paiements/verifier');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'reference': reference,
        if (externalId != null) 'external_id': externalId,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'Erreur vérification paiement.');
    }
    return data as Map<String, dynamic>;
  }
}