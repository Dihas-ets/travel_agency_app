import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/models/voyage_programme_model.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';

class TicketService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // ⬅️ garde ton IP actuelle

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Retrouve le vrai bus_id (et les heures fraîches) pour un voyage donné,
  /// juste avant de finaliser la réservation.
  Future<VoyageProgramme?> getProgrammationParDate({
    required int ligneId,
    required DateTime date,
    required int voyageId,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('$baseUrl/tickets/programmation').replace(
      queryParameters: {'ligne_id': ligneId.toString(), 'date': dateStr},
    );

    final response = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la vérification du voyage.');
    }

    final List data = jsonDecode(response.body);
    final voyages = data.map((e) => VoyageProgramme.fromJson(e as Map<String, dynamic>)).toList();

    try {
      return voyages.firstWhere((v) => v.id == voyageId);
    } catch (_) {
      return null; // le voyage n'est plus disponible à cette date
    }
  }

  /// Crée le ticket réel (réservation) côté backend.
  Future<Map<String, dynamic>> storeTicket({
    required int ligneId,
    required int voyageId,
    required int busId,
    String? villeArrivee,
    required DateTime dateVoyage,
    required String heureVoyage,
    required bool tiers,
    String? nomPassager,
    String? prenomPassager,
    String? numeroPassager,
    required int nbrePlace,
  }) async {
    final dateStr =
        '${dateVoyage.year.toString().padLeft(4, '0')}-${dateVoyage.month.toString().padLeft(2, '0')}-${dateVoyage.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('$baseUrl/tickets');

    final body = {
      'ligne_id': ligneId,
      'voyage_id': voyageId,
      'bus_id': busId,
      if (villeArrivee != null) 'ville_arrivee': villeArrivee,
      'date_voyage': dateStr,
      'heure_voyage': heureVoyage,
      'tiers': tiers,
      if (tiers) 'nom_passager': nomPassager,
      if (tiers) 'prenom_passager': prenomPassager,
      if (tiers) 'numero_passager': numeroPassager,
      'nbre_place': nbrePlace,
      'mode_paiement': 'MOBILEMONEY', // imposé pour les clients de toute façon côté backend
    };

    final response = await http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 12));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message']?.toString() ?? 'Erreur lors de la réservation.');
    }

    return data as Map<String, dynamic>;
  }
}