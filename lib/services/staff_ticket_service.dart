import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';

// Service pour les operations ticket des espaces Staff (Controleur & Percepteur).
// Utilise uniquement les endpoints API existants, sans modification backend.

class StaffTicketModel {
  final int id;
  final String reference;
  final String statut;
  final String? nomPassager;
  final String? prenomPassager;
  final String? numeroPassager;
  final String? villeDepart;
  final String? villeArrivee;
  final String? dateVoyage;
  final String? heureVoyage;
  final String? numPlace;
  final String? busMatricule;
  final String? ligneTitre;

  const StaffTicketModel({
    required this.id,
    required this.reference,
    required this.statut,
    this.nomPassager,
    this.prenomPassager,
    this.numeroPassager,
    this.villeDepart,
    this.villeArrivee,
    this.dateVoyage,
    this.heureVoyage,
    this.numPlace,
    this.busMatricule,
    this.ligneTitre,
  });

  String get fullPassengerName {
    final p = (prenomPassager ?? '').trim();
    final n = (nomPassager ?? '').trim();
    if (p.isEmpty && n.isEmpty) return 'Passager';
    if (p.isEmpty) return n;
    if (n.isEmpty) return p;
    return '$p $n';
  }

  String get route {
    final dep = (villeDepart ?? '').trim();
    final arr = (villeArrivee ?? '').trim();
    if (dep.isEmpty && arr.isEmpty) return '-';
    if (dep.isEmpty) return arr;
    if (arr.isEmpty) return dep;
    return '$dep -> $arr';
  }

  String get statutLabel {
    switch (statut) {
      case 'valide':
        return 'Embarque';
      case 'annule':
        return 'Annule';
      case 'en_attente':
        return 'En attente';
      case 'paye':
        return 'Paye';
      default:
        return statut;
    }
  }

  factory StaffTicketModel.fromJson(Map<String, dynamic> json) {
    final ligne = json['ligne'] as Map<String, dynamic>?;
    final voyage = json['voyage'] as Map<String, dynamic>?;
    final bus = json['bus'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;

    String? nomPassager = json['nom_passager']?.toString();
    String? prenomPassager = json['prenom_passager']?.toString();
    String? numeroPassager = json['numero_passager']?.toString();

    if ((nomPassager == null || nomPassager.isEmpty) && user != null) {
      nomPassager = user['nom']?.toString();
      prenomPassager = user['prenom']?.toString();
      numeroPassager = user['numero']?.toString();
    }

    return StaffTicketModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      reference: json['reference']?.toString() ?? '',
      statut: json['statut']?.toString() ?? 'en_attente',
      nomPassager: nomPassager,
      prenomPassager: prenomPassager,
      numeroPassager: numeroPassager,
      villeDepart:
          ligne?['ville_depart']?.toString() ??
          json['ville_depart']?.toString(),
      villeArrivee:
          json['ville_arrivee']?.toString() ??
          ligne?['ville_arrivee']?.toString(),
      dateVoyage:
          voyage?['date_voyage']?.toString() ?? json['date_voyage']?.toString(),
      heureVoyage:
          voyage?['heure_depart']?.toString() ??
          json['heure_voyage']?.toString(),
      numPlace: json['num_place']?.toString(),
      busMatricule:
          bus?['matricule']?.toString() ?? json['bus_matricule']?.toString(),
      ligneTitre: ligne?['titre']?.toString(),
    );
  }
}

class StaffTicketService {
  static const String _base = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStore.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Recherche un ticket par sa reference.
  /// GET /api/tickets/{reference}
  Future<StaffTicketModel?> getTicketByReference(String reference) async {
    final ref = reference.trim();
    if (ref.isEmpty) return null;
    try {
      final response = await http
          .get(Uri.parse('$_base/tickets/$ref'), headers: await _headers())
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ticketJson = data['ticket'] as Map<String, dynamic>? ?? data;
        return StaffTicketModel.fromJson(ticketJson);
      }
      throw Exception(
        'Erreur ${response.statusCode} lors du chargement du ticket.',
      );
    } catch (error) {
      throw Exception('Impossible de charger le ticket : $error');
    }
  }

  /// Valide l'embarquement d'un ticket.
  /// PATCH /api/tickets/{id}/valider
  Future<Map<String, dynamic>> validerEmbarquement(int ticketId) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_base/tickets/$ticketId/valider'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Embarquement valide.',
          'ticket': data['ticket'] != null
              ? StaffTicketModel.fromJson(
                  data['ticket'] as Map<String, dynamic>,
                )
              : null,
        };
      }
      return {
        'success': false,
        'message':
            data['message']?.toString() ?? 'Impossible de valider ce ticket.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion : ${e.toString()}',
      };
    }
  }

  /// Liste les tickets du jour.
  /// GET /api/tickets?date=YYYY-MM-DD
  Future<List<StaffTicketModel>> getTicketsDuJour() async {
    try {
      final today = DateTime.now();
      final y = today.year.toString().padLeft(4, '0');
      final m = today.month.toString().padLeft(2, '0');
      final d = today.day.toString().padLeft(2, '0');
      final dateStr = '$y-$m-$d';
      final uri = Uri.parse(
        '$_base/tickets',
      ).replace(queryParameters: {'date': dateStr});
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'] is List
            ? data['data']
            : (data is List ? data : []);
        return items
            .whereType<Map<String, dynamic>>()
            .map(StaffTicketModel.fromJson)
            .toList();
      }
      throw Exception(
        'Erreur ${response.statusCode} lors du chargement des tickets.',
      );
    } catch (error) {
      throw Exception('Impossible de charger les tickets : $error');
    }
  }

  /// Liste les colis par statut.
  /// GET /api/colis?statut=...
  Future<List<Map<String, dynamic>>> getColisParStatut(String statut) async {
    try {
      final uri = Uri.parse(
        '$_base/colis',
      ).replace(queryParameters: {'statut': statut});
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'] is List
            ? data['data']
            : (data is List ? data : []);
        return items.whereType<Map<String, dynamic>>().toList();
      }
      throw Exception(
        'Erreur ${response.statusCode} lors du chargement des colis.',
      );
    } catch (error) {
      throw Exception('Impossible de charger les colis : $error');
    }
  }
}
