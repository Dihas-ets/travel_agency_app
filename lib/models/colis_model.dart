import 'dart:convert';
import 'package:code_initial/models/store/colis_store.dart';

class ColisDetailItem {
  final String nature;
  final double poids;
  final int nombre;
  final String description;
  final String? imagePath;

  ColisDetailItem({
    required this.nature,
    this.poids = 0,
    required this.nombre,
    this.description = '',
    this.imagePath,
  });

  factory ColisDetailItem.fromJson(Map<String, dynamic> json) {
    return ColisDetailItem(
      nature: json['nature']?.toString() ?? '',
      poids: double.tryParse(json['poids']?.toString() ?? '0') ?? 0,
      nombre: int.tryParse(json['nombre']?.toString() ?? '1') ?? 1,
      description: json['description']?.toString() ?? '',
      imagePath: json['image_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nature': nature,
      'poids': poids,
      'nombre': nombre,
      'description': description,
      if (imagePath != null) 'image_path': imagePath,
    };
  }
}

class ColisModel {
  final int id;
  final String reference;
  final String? qrCode;
  final int? agenceDepotId;
  final int? agenceRetraitId;
  final int? expediteurId;
  final int? destinataireId;
  final int? enregistreurId;
  final List<ColisDetailItem> colisDetails;
  final String statut;
  final String statutPaiement;
  final double montant;
  final double montantBase;
  final String modePaiement;
  final double valeurEstime;
  final int nombreColis;
  final String origine;
  final DateTime? createdAt;
  final String? agenceDepotNom;
  final String? agenceRetraitNom;
  final String? expediteurNom;
  final String? expediteurTel;
  final String? destinataireNom;
  final String? destinataireTel;

  ColisModel({
    required this.id,
    required this.reference,
    this.qrCode,
    this.agenceDepotId,
    this.agenceRetraitId,
    this.expediteurId,
    this.destinataireId,
    this.enregistreurId,
    required this.colisDetails,
    required this.statut,
    required this.statutPaiement,
    required this.montant,
    this.montantBase = 0,
    required this.modePaiement,
    this.valeurEstime = 0,
    this.nombreColis = 1,
    this.origine = 'en_externe',
    this.createdAt,
    this.agenceDepotNom,
    this.agenceRetraitNom,
    this.expediteurNom,
    this.expediteurTel,
    this.destinataireNom,
    this.destinataireTel,
  });

  factory ColisModel.fromJson(Map<String, dynamic> json) {
    List<ColisDetailItem> details = [];
    if (json['colis_details'] != null) {
      if (json['colis_details'] is List) {
        details = (json['colis_details'] as List)
            .map((item) => ColisDetailItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (json['colis_details'] is String) {
        try {
          final decoded = jsonDecode(json['colis_details']);
          if (decoded is List) {
            details = decoded
                .map((item) => ColisDetailItem.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }
    }

    final expediteur = json['expediteur'] as Map<String, dynamic>?;
    final destinataire = json['destinataire'] as Map<String, dynamic>?;
    final agenceDepot = json['agence_depot'] as Map<String, dynamic>?;
    final agenceRetrait = json['agence_retrait'] as Map<String, dynamic>?;

    String? expNom;
    if (expediteur != null) {
      final p = expediteur['prenom']?.toString() ?? '';
      final n = expediteur['nom']?.toString() ?? '';
      expNom = '$p $n'.trim();
    }

    String? destNom;
    if (destinataire != null) {
      final p = destinataire['prenom']?.toString() ?? '';
      final n = destinataire['nom']?.toString() ?? '';
      destNom = '$p $n'.trim();
    }

    return ColisModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      reference: json['reference']?.toString() ?? '',
      qrCode: json['qr_code']?.toString(),
      agenceDepotId: json['agence_depot_id'] != null ? int.tryParse(json['agence_depot_id'].toString()) : null,
      agenceRetraitId: json['agence_retrait_id'] != null ? int.tryParse(json['agence_retrait_id'].toString()) : null,
      expediteurId: json['expediteur_id'] != null ? int.tryParse(json['expediteur_id'].toString()) : null,
      destinataireId: json['destinataire_id'] != null ? int.tryParse(json['destinataire_id'].toString()) : null,
      enregistreurId: json['enregistreur_id'] != null ? int.tryParse(json['enregistreur_id'].toString()) : null,
      colisDetails: details,
      statut: json['statut']?.toString() ?? 'brouillon',
      statutPaiement: json['statut_paiement']?.toString() ?? 'en_attente_paiement',
      montant: double.tryParse(json['montant']?.toString() ?? '0') ?? 0,
      montantBase: double.tryParse(json['montant_base']?.toString() ?? '0') ?? 0,
      modePaiement: json['mode_paiement']?.toString() ?? 'MOBILEMONEY',
      valeurEstime: double.tryParse(json['valeur_estime']?.toString() ?? '0') ?? 0,
      nombreColis: int.tryParse(json['nombre_colis']?.toString() ?? '1') ?? 1,
      origine: json['origine']?.toString() ?? 'en_externe',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      agenceDepotNom: agenceDepot?['nom_agence']?.toString(),
      agenceRetraitNom: agenceRetrait?['nom_agence']?.toString(),
      expediteurNom: expNom,
      expediteurTel: expediteur?['numero']?.toString(),
      destinataireNom: destNom,
      destinataireTel: destinataire?['numero']?.toString(),
    );
  }

  ParcelRecord toParcelRecord() {
    final firstDetail = colisDetails.isNotEmpty ? colisDetails.first : null;
    final natureSummary = colisDetails.map((d) => '${d.nature} x${d.nombre}').join(', ');

    String displayStatus;
    switch (statut) {
      case 'brouillon':
        displayStatus = statutPaiement == 'payé' ? 'Payé (Brouillon)' : 'En attente';
        break;
      case 'a_expedier':
        displayStatus = 'Enregistré';
        break;
      case 'en_transit':
        displayStatus = 'En transit';
        break;
      case 'arrive':
        displayStatus = 'Arrivé';
        break;
      case 'livre':
        displayStatus = 'Livré';
        break;
      default:
        displayStatus = statut;
    }

    return ParcelRecord(
      code: reference,
      departureCity: agenceDepotNom ?? 'Départ',
      destinationCity: agenceRetraitNom ?? 'Destination',
      recipientLastName: destinataireNom ?? '',
      recipientFirstName: '',
      recipientPhone: destinataireTel ?? '',
      parcelNature: natureSummary.isNotEmpty ? natureSummary : 'Colis',
      parcelCount: nombreColis,
      senderPhone: expediteurTel ?? '',
      senderName: expediteurNom,
      attachmentPath: firstDetail?.imagePath,
      attachmentName: firstDetail?.imagePath != null ? 'Image colis' : null,
      deliveryFee: montant > 0 ? montant.toStringAsFixed(0) : '',
      createdAt: createdAt ?? DateTime.now(),
      status: displayStatus,
      qrCode: qrCode,
      estimatedValue: valeurEstime,
      rawStatus: statut,
      paymentStatus: statutPaiement,
      modePaiement: modePaiement,
    );
  }
}
