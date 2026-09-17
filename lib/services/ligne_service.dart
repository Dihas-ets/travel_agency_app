import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/ligne_model.dart';
import 'package:code_initial/models/voyage_disponibilite_model.dart';

class LigneService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// Cherche une ligne correspondant exactement au trajet départ → arrivée.
  /// ⬅️ MODIF : utilise la route publique (pas de token requis)
  Future<Ligne?> findTarif({
    required String depart,
    required String destination,
  }) async {
    final uri = Uri.parse('$baseUrl/public/lignes').replace(
      queryParameters: {'status': 'actif', 'all': '1'},
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des tarifs.');
    }

    final List data = jsonDecode(response.body);
    final lignes = data.map((e) => Ligne.fromJson(e as Map<String, dynamic>)).toList();

    

    final departLower = depart.trim().toLowerCase();
    final destinationLower = destination.trim().toLowerCase();

    for (final ligne in lignes) {
      if (ligne.trajetDepart.trim().toLowerCase() == departLower &&
          ligne.trajetArrivee.trim().toLowerCase() == destinationLower) {
        return ligne;
      }
    }
    return null;
  }

  /// ⬅️ MODIF : route publique correcte
  Future<List<Ligne>> getPopulaires() async {
    final uri = Uri.parse('$baseUrl/public/lignes/populaires');

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des destinations populaires.');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Ligne.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ⬇️ AJOUT : bus/heures/places réellement disponibles pour une ligne à une date donnée
  Future<List<VoyageDisponibilite>> rechercheDisponibilites({
    required int ligneId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('$baseUrl/public/recherche/disponibilites').replace(
      queryParameters: {'ligne_id': ligneId.toString(), 'date': dateStr},
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la recherche des disponibilités.');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => VoyageDisponibilite.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Retourne la liste unique des villes desservies (départs + arrivées),
/// triée alphabétiquement, à partir des lignes actives en base.
Future<List<String>> getVillesDisponibles() async {
  final uri = Uri.parse('$baseUrl/public/lignes').replace(
    queryParameters: {'status': 'actif', 'all': '1'},
  );

  final response = await http
      .get(uri, headers: {'Accept': 'application/json'})
      .timeout(const Duration(seconds: 8));

  if (response.statusCode != 200) {
    throw Exception('Erreur lors du chargement des villes.');
  }

  final List data = jsonDecode(response.body);
  final lignes = data.map((e) => Ligne.fromJson(e as Map<String, dynamic>)).toList();

  final villes = <String>{};
  for (final ligne in lignes) {
    if (ligne.trajetDepart.trim().isNotEmpty) villes.add(ligne.trajetDepart.trim());
    if (ligne.trajetArrivee.trim().isNotEmpty) villes.add(ligne.trajetArrivee.trim());
  }

  final liste = villes.toList()..sort();
  return liste;
}
}