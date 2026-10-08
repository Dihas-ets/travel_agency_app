import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fofanavoyage/config/app_config.dart';
import 'package:fofanavoyage/auth/stockage_auth_local.dart';

String? ticketReferenceFromQr(String payload) {
  final value = payload.trim();
  if (value.isEmpty) return null;

  final referencePattern = RegExp(
    r'FV-TKT-\d{8}-[A-Z0-9]{4}',
    caseSensitive: false,
  );
  final embeddedReference = referencePattern.firstMatch(value);
  if (embeddedReference != null) return embeddedReference.group(0);

  if (value.startsWith('{')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        for (final key in const [
          'reference',
          'ticket_reference',
          'ticketReference',
          'ref',
        ]) {
          final reference = decoded[key]?.toString().trim();
          if (reference != null && reference.isNotEmpty) return reference;
        }
      }
    } on FormatException {
      return null;
    }
  }

  final uri = Uri.tryParse(value);
  if (uri != null) {
    for (final key in const [
      'reference',
      'ticket_reference',
      'ticketReference',
      'ref',
    ]) {
      final reference = uri.queryParameters[key]?.trim();
      if (reference != null && reference.isNotEmpty) return reference;
    }
    for (final segment in uri.pathSegments.reversed) {
      final match = referencePattern.firstMatch(segment);
      if (match != null) return match.group(0);
    }
  }

  if (!value.contains(RegExp(r'\s')) && !value.contains('://')) return value;
  return null;
}

class MecefTicketQrData {
  final String nim;
  final String code;

  const MecefTicketQrData({required this.nim, required this.code});
}

String normalizeMecefCode(String value) =>
    value.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

MecefTicketQrData? mecefTicketDataFromQr(String payload) {
  final parts = payload.trim().split(';');
  if (parts.length < 3 || parts.first.trim().toUpperCase() != 'F') {
    return null;
  }

  final nim = parts[1].trim();
  final code = parts[2].trim();
  if (nim.isEmpty || code.isEmpty) return null;
  return MecefTicketQrData(nim: nim, code: code);
}

// Service pour les operations ticket des espaces Staff (Controleur & Percepteur).
// Utilise uniquement les endpoints API existants, sans modification backend.

class StaffTicketModel {
  final int id;
  final String reference;
  final String statut;
  final String? statutPaiement;
  final String? nomPassager;
  final String? prenomPassager;
  final String? numeroPassager;
  final String? villeDepart;
  final String? villeArrivee;
  final String? dateVoyage;
  final String? heureVoyage;
  final String? numPlace;
  final String? busMatricule;
  final String? busMarque;
  final String? ligneTitre;
  final String? classe;
  final int? nombrePlaces;
  final double? tarifUnitaire;
  final double? montantTotal;
  final double? montantBase;
  final double? tauxTaxe;
  final double? montantTaxe;
  final String? modePaiement;
  final String? emetteurNom;
  final String? mecefStatus;
  final String? mecefCode;
  final String? mecefNim;
  final String? mecefQrCode;

  const StaffTicketModel({
    required this.id,
    required this.reference,
    required this.statut,
    this.statutPaiement,
    this.nomPassager,
    this.prenomPassager,
    this.numeroPassager,
    this.villeDepart,
    this.villeArrivee,
    this.dateVoyage,
    this.heureVoyage,
    this.numPlace,
    this.busMatricule,
    this.busMarque,
    this.ligneTitre,
    this.classe,
    this.nombrePlaces,
    this.tarifUnitaire,
    this.montantTotal,
    this.montantBase,
    this.tauxTaxe,
    this.montantTaxe,
    this.modePaiement,
    this.emetteurNom,
    this.mecefStatus,
    this.mecefCode,
    this.mecefNim,
    this.mecefQrCode,
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
      case 'utilise':
      case 'utilisé':
        return 'Embarque';
      case 'annule':
      case 'annulé':
        return 'Annule';
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'paye':
        return 'Paye';
      default:
        return statut;
    }
  }

  String get statutPaiementLabel {
    final normalized = (statutPaiement ?? '').toLowerCase();
    if (normalized == 'payé' || normalized == 'paye' || normalized == 'paid') {
      return 'Payé';
    }
    if (normalized == 'en_attente_paiement' || normalized == 'pending') {
      return 'Paiement en attente';
    }
    if (normalized.isEmpty) return 'Non renseigné';
    return statutPaiement!;
  }

  bool get canValidateBoarding {
    final paymentStatus = (statutPaiement ?? '').toLowerCase();
    final isPaid =
        paymentStatus == 'payé' ||
        paymentStatus == 'paye' ||
        paymentStatus == 'paid';
    return statut == 'en_cours' && isPaid;
  }

  bool get isBoarded =>
      statut == 'utilisé' || statut == 'utilise' || statut == 'valide';

  bool get isMecefCertified =>
      mecefStatus?.toLowerCase() == 'confirmed' &&
      (mecefCode?.isNotEmpty ?? false) &&
      (mecefNim?.isNotEmpty ?? false);

  StaffTicketModel copyWith({String? statut, String? statutPaiement}) {
    return StaffTicketModel(
      id: id,
      reference: reference,
      statut: statut ?? this.statut,
      statutPaiement: statutPaiement ?? this.statutPaiement,
      nomPassager: nomPassager,
      prenomPassager: prenomPassager,
      numeroPassager: numeroPassager,
      villeDepart: villeDepart,
      villeArrivee: villeArrivee,
      dateVoyage: dateVoyage,
      heureVoyage: heureVoyage,
      numPlace: numPlace,
      busMatricule: busMatricule,
      busMarque: busMarque,
      ligneTitre: ligneTitre,
      classe: classe,
      nombrePlaces: nombrePlaces,
      tarifUnitaire: tarifUnitaire,
      montantTotal: montantTotal,
      montantBase: montantBase,
      tauxTaxe: tauxTaxe,
      montantTaxe: montantTaxe,
      modePaiement: modePaiement,
      emetteurNom: emetteurNom,
      mecefStatus: mecefStatus,
      mecefCode: mecefCode,
      mecefNim: mecefNim,
      mecefQrCode: mecefQrCode,
    );
  }

  factory StaffTicketModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapValue(Object? value) =>
        value is Map ? Map<String, dynamic>.from(value) : {};

    double? doubleValue(Object? value) =>
        double.tryParse(value?.toString() ?? '');
    int? intValue(Object? value) => int.tryParse(value?.toString() ?? '');

    final ligne = mapValue(json['ligne']);
    final voyage = mapValue(json['voyage']);
    final bus = mapValue(json['bus']);
    final user = mapValue(json['user']);
    final emetteur = mapValue(json['emetteur']);
    final mecef = mapValue(json['mecef_response'] ?? json['mecefResponse']);

    String? nomPassager = json['nom_passager']?.toString();
    String? prenomPassager = json['prenom_passager']?.toString();
    String? numeroPassager = json['numero_passager']?.toString();

    if ((nomPassager == null || nomPassager.isEmpty) && user.isNotEmpty) {
      nomPassager = user['nom']?.toString();
      prenomPassager = user['prenom']?.toString();
      numeroPassager = user['numero']?.toString();
    }

    final issuerFirstName = emetteur['prenom']?.toString() ?? '';
    final issuerLastName = emetteur['nom']?.toString() ?? '';

    return StaffTicketModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      reference: json['reference']?.toString() ?? '',
      statut: json['statut']?.toString() ?? 'en_attente',
      statutPaiement: json['statut_paiement']?.toString(),
      nomPassager: nomPassager,
      prenomPassager: prenomPassager,
      numeroPassager: numeroPassager,
      villeDepart:
          ligne['trajet_depart']?.toString() ??
          json['ville_depart']?.toString(),
      villeArrivee:
          json['ville_arrivee']?.toString() ??
          ligne['trajet_arrivee']?.toString(),
      dateVoyage:
          voyage['date_voyage']?.toString() ?? json['date_voyage']?.toString(),
      heureVoyage:
          voyage['heure_depart']?.toString() ??
          json['heure_voyage']?.toString(),
      numPlace: json['num_place']?.toString(),
      busMatricule:
          bus['immatriculation']?.toString() ??
          bus['matricule']?.toString() ??
          json['bus_matricule']?.toString(),
      busMarque: bus['marque']?.toString(),
      ligneTitre: ligne['titre']?.toString(),
      classe: json['classe']?.toString(),
      nombrePlaces: intValue(json['nbre_place']),
      tarifUnitaire: doubleValue(json['tarif_unitaire']),
      montantTotal: doubleValue(json['tarif_total']),
      montantBase: doubleValue(json['montant_base']),
      tauxTaxe: doubleValue(json['taxe_taux']),
      montantTaxe: doubleValue(json['montant_taxe']),
      modePaiement: json['mode_paiement']?.toString(),
      emetteurNom: '$issuerFirstName $issuerLastName'.trim(),
      mecefStatus: mecef['status']?.toString(),
      mecefCode: mecef['code_mecef']?.toString(),
      mecefNim: mecef['nim']?.toString(),
      mecefQrCode: mecef['qr_code']?.toString(),
    );
  }
}

class StaffTicketService {
  String get _baseUrl => AppConfig.apiBaseUrl;

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
          .get(
            Uri.parse('$_baseUrl/tickets/${Uri.encodeComponent(ref)}'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map) {
          throw Exception('Réponse invalide lors du chargement du ticket.');
        }
        final data = Map<String, dynamic>.from(decoded);
        final rawTicket = data['ticket'];
        final ticketJson = rawTicket is Map
            ? Map<String, dynamic>.from(rawTicket)
            : data;
        return StaffTicketModel.fromJson(ticketJson);
      }
      if (response.statusCode == 404) {
        throw Exception('Ticket introuvable. Vérifiez la référence.');
      }
      final errorBody = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      final message = errorBody is Map
          ? errorBody['message']?.toString()
          : null;
      throw Exception(
        message ??
            'Erreur ${response.statusCode} lors du chargement du ticket.',
      );
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Impossible de charger le ticket : $error');
    }
  }

  /// Recherche un ticket certifié en comparant le code MECeF et le NIM.
  /// L’API ne propose pas de filtre MECeF, les pages sont donc parcourues
  /// jusqu’à trouver une correspondance exacte ou atteindre la dernière page.
  Future<StaffTicketModel?> getTicketByMecef({
    required String code,
    required String nim,
  }) async {
    final normalizedCode = normalizeMecefCode(code);
    final normalizedNim = nim.trim();
    if (normalizedCode.isEmpty || normalizedNim.isEmpty) return null;

    var page = 1;
    var lastPage = 1;
    do {
      final uri = Uri.parse(
        '$_baseUrl/tickets',
      ).replace(queryParameters: {'page': '$page', 'per_page': '100'});
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 20));

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (response.statusCode != 200) {
        final message = decoded is Map ? decoded['message']?.toString() : null;
        throw Exception(
          message ??
              'Erreur ${response.statusCode} lors de la recherche MECeF.',
        );
      }
      if (decoded is! Map || decoded['data'] is! List) {
        throw const FormatException(
          'Réponse invalide lors de la recherche du ticket MECeF.',
        );
      }

      final items = decoded['data'] as List;
      for (final item in items) {
        if (item is! Map) continue;
        final ticketJson = Map<String, dynamic>.from(item);
        final ticket = StaffTicketModel.fromJson(ticketJson);
        if (ticket.isMecefCertified &&
            normalizeMecefCode(ticket.mecefCode ?? '') == normalizedCode &&
            (ticket.mecefNim ?? '').trim() == normalizedNim) {
          return ticket;
        }
      }

      page = int.tryParse(decoded['current_page']?.toString() ?? '') ?? page;
      lastPage = int.tryParse(decoded['last_page']?.toString() ?? '') ?? page;
      page++;
    } while (page <= lastPage);

    return null;
  }

  /// Valide l'embarquement d'un ticket.
  /// PATCH /api/tickets/{id}/valider
  Future<Map<String, dynamic>> validerEmbarquement(int ticketId) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl/tickets/$ticketId/valider'),
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

  Future<Map<String, dynamic>> annulerTicket(int ticketId) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/tickets/$ticketId/annuler'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));
    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};
    final data = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'Impossible d’annuler ce ticket.',
      );
    }
    return data;
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
        '$_baseUrl/tickets',
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
        '$_baseUrl/colis',
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
