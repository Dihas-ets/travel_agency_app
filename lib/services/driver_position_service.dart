import 'dart:convert';

import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:http/http.dart' as http;

enum DriverTrackingStatus { notStarted, started, ended }

class DriverPositionService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<DriverTrackingStatus> getTrackingStatus(int affectationId) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/voyage/tracking-status/$affectationId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));
    final data = _decodeMap(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        data['message']?.toString() ??
            'Impossible de vérifier le suivi du voyage.',
      );
    }
    switch (data['status']) {
      case 'started':
        return DriverTrackingStatus.started;
      case 'ending':
        return DriverTrackingStatus.ended;
      default:
        return data['is_started'] == true
            ? DriverTrackingStatus.started
            : DriverTrackingStatus.notStarted;
    }
  }

  Future<void> startJourney(int affectationId, double lat, double lng) async {
    await _post('voyage/start', {
      'affectation_id': affectationId,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<void> updateLocation(int affectationId, double lat, double lng) async {
    await _post('voyage/update-location', {
      'affectation_id': affectationId,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<void> endJourney(int affectationId) async {
    await _post('voyage/end', {'affectation_id': affectationId});
  }

  Future<void> _post(String endpoint, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    final data = _decodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'La demande de suivi du voyage a échoué.',
      );
    }
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const FormatException('Réponse API invalide.');
    }
    return Map<String, dynamic>.from(decoded);
  }
}
