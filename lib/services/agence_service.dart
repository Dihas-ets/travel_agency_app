import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/models/agence_model.dart';

import 'package:code_initial/auth/stockage_auth_local.dart';

class AgenceService {
  // ⚠️ Même base URL que AuthService — pense à la mettre à jour au même endroit si tu changes d'environnement
  static const String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<Agence>> getAgencesProches({
  required double latitude,
  required double longitude,
  double? rayon,
}) async {
  
  final uri = Uri.parse('$baseUrl/auth/client/agences/proches').replace(  
    queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (rayon != null) 'rayon': rayon.toString(),
    },
  );

  final token = await AuthLocalStore.getToken();

  final response = await http
      .get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      )
      .timeout(const Duration(seconds: 8));

      // 🔍 AJOUT TEMPORAIRE : voir exactement ce que répond le serveur
      print('➡️ URL appelée: $uri');
      print('➡️ Token présent: ${token != null}');
      print('⬅️ Status code: ${response.statusCode}');
      print('⬅️ Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List agencesJson = data['agences'] ?? [];
        return agencesJson
            .map((e) => Agence.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        'Erreur ${response.statusCode} lors du chargement des agences proches: ${response.body}',
      );
    }

  // ⬇️ AJOUT : récupère toutes les agences actives (pour affichage sur la carte)
  Future<List<Agence>> getAllAgences() async {
    final uri = Uri.parse('$baseUrl/agences?status=actif');

    // ⬇️ AJOUT : récupération du token sauvegardé lors du login
    final token = await AuthLocalStore.getToken();

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token', // ⬅️ AJOUT
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // /api/agences est paginé côté Laravel (paginate()), les résultats sont dans "data"
      final List agencesJson = data['data'] ?? [];
      return agencesJson
          .map((e) => Agence.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erreur lors du chargement des agences.');
  }
}