import 'dart:convert';

import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:http/http.dart' as http;

class AffectationService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getMyAssignments() async {
    final headers = await _headers();
    final assignments = <Map<String, dynamic>>[];
    var page = 1;
    var lastPage = 1;

    do {
      final uri = Uri.parse(
        '$_baseUrl/affectations',
      ).replace(queryParameters: {'page': '$page'});
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      final decoded = _decodeMap(response.body);
      if (response.statusCode != 200) {
        throw Exception(
          decoded['message']?.toString() ??
              'Impossible de charger vos affectations.',
        );
      }

      final data = decoded['data'];
      final rows = data is List
          ? data
          : decoded['data'] is Map && (decoded['data'] as Map)['data'] is List
          ? (decoded['data'] as Map)['data'] as List
          : <dynamic>[];
      assignments.addAll(
        rows.whereType<Map>().map((row) => Map<String, dynamic>.from(row)),
      );
      lastPage =
          int.tryParse(
            (decoded['last_page'] ??
                        (decoded['data'] is Map
                            ? (decoded['data'] as Map)['last_page']
                            : null))
                    ?.toString() ??
                '',
          ) ??
          page;
      page++;
    } while (page <= lastPage);

    return assignments;
  }

  Future<Map<String, dynamic>> getAssignmentTeam(int assignmentId) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/affectations/$assignmentId/equipe'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 12));
    final decoded = _decodeMap(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        decoded['message']?.toString() ??
            'Impossible de charger l’équipe de cette affectation.',
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> activateAccessCode(String code) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/access/utiliser-code'),
          headers: await _headers(),
          body: jsonEncode({'code': code.trim()}),
        )
        .timeout(const Duration(seconds: 12));
    final decoded = _decodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message']?.toString() ??
            'Impossible d’activer la session avec ce code.',
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> getMySession() async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/access/ma-session'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 12));
    final decoded = _decodeMap(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        decoded['message']?.toString() ??
            'Impossible de vérifier votre session.',
      );
    }
    return decoded;
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
