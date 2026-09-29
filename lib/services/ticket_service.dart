import 'dart:convert';

import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/voyage_programme_model.dart';
import 'package:http/http.dart' as http;

class TicketService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  String _errorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    } on FormatException {
      return fallback;
    }
    return fallback;
  }

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };
  }

  Future<List<Map<String, dynamic>>> getHistoriqueClient() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/auth/client/tickets/historique'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Impossible de charger votre historique.');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Searches passenger accounts through the same endpoint as the web dashboard.
  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    final value = query.trim();
    if (value.isEmpty) return [];
    final uri = Uri.parse(
      '$baseUrl/users/search',
    ).replace(queryParameters: {'q': value});
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Impossible de rechercher les passagers.'),
      );
    }
    final decoded = jsonDecode(response.body);
    final rows = decoded is Map ? decoded['data'] : decoded;
    if (rows is! List) return [];
    return rows
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Returns every ticket emitted by the authenticated percepteur.
  Future<List<Map<String, dynamic>>> getTicketsEmis() async {
    final tickets = <Map<String, dynamic>>[];
    var page = 1;
    var lastPage = 1;
    do {
      final uri = Uri.parse('$baseUrl/tickets').replace(
        queryParameters: {
          'only_mine': '1',
          'per_page': '100',
          'page': page.toString(),
        },
      );
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception(
          _errorMessage(response, 'Impossible de charger les tickets émis.'),
        );
      }
      final decoded = jsonDecode(response.body);
      final rows = decoded is Map ? decoded['data'] : decoded;
      if (rows is! List) return tickets;
      tickets.addAll(
        rows.whereType<Map>().map((item) => Map<String, dynamic>.from(item)),
      );
      if (decoded is Map) {
        lastPage = int.tryParse(decoded['last_page']?.toString() ?? '') ?? page;
      }
      page++;
    } while (page <= lastPage);
    return tickets;
  }

  /// Annule une réservation/un ticket côté client.
  Future<Map<String, dynamic>> annulerClient(int ticketId) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/tickets/$ticketId/annuler'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 10));

    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      // Ignore non-JSON error bodies and report a friendly fallback.
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'Impossible d’annuler la réservation.',
      );
    }
    return data;
  }

  /// Reprogramme une réservation/un ticket côté client.
  Future<void> reprogrammer({
    required int ticketId,
    required String nouvelleDate,
    required String nouvelleHeure,
    required int nouveauVoyageId,
  }) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/auth/client/tickets/$ticketId/reprogrammer'),
          headers: await _headers(),
          body: jsonEncode({
            'nouvelle_date': nouvelleDate,
            'nouvelle_heure': nouvelleHeure,
            'nouveau_voyage_id': nouveauVoyageId,
          }),
        )
        .timeout(const Duration(seconds: 12));
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'Impossible de modifier la réservation.',
      );
    }
  }

  /// Revalidates a selected trip and its live bus/timetable data.
  Future<VoyageProgramme?> getProgrammationParDate({
    required int ligneId,
    required DateTime date,
    required int voyageId,
    String? villeArrivee,
  }) async {
    final voyages = await getProgrammesParDate(
      ligneId: ligneId,
      date: date,
      villeArrivee: villeArrivee,
    );
    for (final voyage in voyages) {
      if (voyage.id == voyageId) return voyage;
    }
    return null;
  }

  Future<List<VoyageProgramme>> getProgrammesParDate({
    required int ligneId,
    required DateTime date,
    String? villeArrivee,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse('$baseUrl/tickets/programmation').replace(
      queryParameters: {
        'ligne_id': ligneId.toString(),
        'date': dateStr,
        if (villeArrivee != null && villeArrivee.trim().isNotEmpty)
          'ville_arrivee': villeArrivee.trim(),
      },
    );
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Erreur lors du chargement des départs disponibles.',
        ),
      );
    }
    final decoded = jsonDecode(response.body);
    final rows = decoded is List
        ? decoded
        : decoded is Map && decoded['voyages'] is List
        ? decoded['voyages'] as List
        : const [];
    return rows
        .whereType<Map>()
        .map(
          (item) => VoyageProgramme.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<int> getPlacesDisponibles({
    required int voyageId,
    required int busId,
    required DateTime date,
    required String heure,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse('$baseUrl/tickets/verifier-places').replace(
      queryParameters: {
        'voyage_id': voyageId.toString(),
        'bus_id': busId.toString(),
        'date_voyage': dateStr,
        'heure_voyage': heure,
      },
    );
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Impossible de vérifier les places disponibles.',
        ),
      );
    }
    final decoded = jsonDecode(response.body);
    return int.tryParse(decoded['disponibles']?.toString() ?? '') ?? 0;
  }

  /// Creates a real ticket using the existing staff/client POST endpoint.
  Future<Map<String, dynamic>> storeTicket({
    required int ligneId,
    required int voyageId,
    required int busId,
    String? villeArrivee,
    required DateTime dateVoyage,
    required String heureVoyage,
    required bool tiers,
    String modePaiement = 'MOBILEMONEY',
    String? nomPassager,
    String? prenomPassager,
    String? numeroPassager,
    int? userId,
    required int nbrePlace,
    int? taxGroupId,
    double? montantBase,
    double? montantManuel,
  }) async {
    final dateStr =
        '${dateVoyage.year.toString().padLeft(4, '0')}-${dateVoyage.month.toString().padLeft(2, '0')}-${dateVoyage.day.toString().padLeft(2, '0')}';
    final body = {
      'ligne_id': ligneId,
      'voyage_id': voyageId,
      'bus_id': busId,
      if (villeArrivee != null) 'ville_arrivee': villeArrivee,
      if (userId != null) 'user_id': userId,
      'date_voyage': dateStr,
      'heure_voyage': heureVoyage,
      'tiers': tiers,
      if (tiers) 'nom_passager': nomPassager,
      if (tiers) 'prenom_passager': prenomPassager,
      if (tiers) 'numero_passager': numeroPassager,
      'nbre_place': nbrePlace,
      'mode_paiement': modePaiement,
      if (taxGroupId != null) 'taxe_group_id': taxGroupId,
      if (montantBase != null) 'montant_base': montantBase,
      if (montantManuel != null) 'montant_manuel': montantManuel,
    };
    final response = await http
        .post(
          Uri.parse('$baseUrl/tickets'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 403 &&
          data is Map &&
          data['code_required'] == true) {
        throw Exception(
          'Votre section est fermée. Ouvrez Connexion et activez votre code d’accès avant d’émettre un ticket.',
        );
      }
      throw Exception(
        data is Map
            ? data['message']?.toString() ?? 'Erreur lors de la réservation.'
            : 'Erreur lors de la réservation.',
      );
    }
    return Map<String, dynamic>.from(data as Map);
  }
}
