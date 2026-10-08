import 'dart:convert';
import 'package:fofanavoyage/models/store/colis_store.dart';

class ColisDetailItem {
  final String nature;
  final double poids;
  final double valeur;
  final int nombre;
  final String description;
  final String? imagePath;

  ColisDetailItem({
    required this.nature,
    this.poids = 0,
    this.valeur = 0,
    required this.nombre,
    this.description = '',
    this.imagePath,
  });

  factory ColisDetailItem.fromJson(Map<String, dynamic> json) {
    return ColisDetailItem(
      nature: json['nature']?.toString() ?? '',
      poids: double.tryParse(json['poids']?.toString() ?? '0') ?? 0,
      valeur: double.tryParse(json['valeur']?.toString() ?? '0') ?? 0,
      nombre: int.tryParse(json['nombre']?.toString() ?? '1') ?? 1,
      description: json['description']?.toString() ?? '',
      imagePath: json['image_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nature': nature,
      'poids': poids,
      'valeur': valeur,
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
  final String? refundStatus;
  final double refundAmount;
  final double refundPenalty;
  final double montant;
  final double montantBase;
  final double montantTaxe;
  final double tauxTaxe;
  final String modePaiement;
  final double valeurEstime;
  final int nombreColis;
  final String origine;
  final DateTime? createdAt;
  final Map<String, dynamic>? mecefResponse;
  final String? enregistreurNom;
  final int? taxeGroupId;
  final String? taxGroupLabel;
  final String? taxGroupCode;
  final String? agenceDepotNom;
  final String? agenceRetraitNom;
  final String? expediteurNom;
  final String? expediteurTel;
  final String? destinataireNom;
  final String? destinataireNomFamille;
  final String? destinatairePrenom;
  final String? destinataireTel;
  final String? destinataireTelSecondaire;

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
    this.refundStatus,
    this.refundAmount = 0,
    this.refundPenalty = 0,
    required this.montant,
    this.montantBase = 0,
    this.montantTaxe = 0,
    this.tauxTaxe = 0,
    required this.modePaiement,
    this.valeurEstime = 0,
    this.nombreColis = 1,
    this.origine = 'en_externe',
    this.createdAt,
    this.mecefResponse,
    this.enregistreurNom,
    this.taxeGroupId,
    this.taxGroupLabel,
    this.taxGroupCode,
    this.agenceDepotNom,
    this.agenceRetraitNom,
    this.expediteurNom,
    this.expediteurTel,
    this.destinataireNom,
    this.destinataireNomFamille,
    this.destinatairePrenom,
    this.destinataireTel,
    this.destinataireTelSecondaire,
  });

  factory ColisModel.fromJson(Map<String, dynamic> json) {
    List<ColisDetailItem> details = [];
    if (json['colis_details'] != null) {
      if (json['colis_details'] is List) {
        details = (json['colis_details'] as List)
            .map(
              (item) => ColisDetailItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (json['colis_details'] is String) {
        try {
          final decoded = jsonDecode(json['colis_details']);
          if (decoded is List) {
            details = decoded
                .map(
                  (item) =>
                      ColisDetailItem.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        } catch (_) {}
      }
    }

    final expediteur = json['expediteur'] as Map<String, dynamic>?;
    final destinataire = json['destinataire'] as Map<String, dynamic>?;
    final agenceDepot = json['agence_depot'] as Map<String, dynamic>?;
    final agenceRetrait = json['agence_retrait'] as Map<String, dynamic>?;
    final refundDetails = json['refund_details'] is Map
        ? Map<String, dynamic>.from(json['refund_details'] as Map)
        : const <String, dynamic>{};
    final rawMecef = json['mecef_response'] ?? json['mecefResponse'];
    final mecefResponse = rawMecef is Map
        ? Map<String, dynamic>.from(rawMecef)
        : null;
    final rawTaxGroup = json['taxe_groupe'] ?? json['taxeGroupe'];
    final taxGroup = rawTaxGroup is Map
        ? Map<String, dynamic>.from(rawTaxGroup)
        : null;
    final enregistreur = json['enregistreur'] is Map
        ? Map<String, dynamic>.from(json['enregistreur'] as Map)
        : null;

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
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      reference: json['reference']?.toString() ?? '',
      qrCode: json['qr_code']?.toString(),
      agenceDepotId: json['agence_depot_id'] != null
          ? int.tryParse(json['agence_depot_id'].toString())
          : null,
      agenceRetraitId: json['agence_retrait_id'] != null
          ? int.tryParse(json['agence_retrait_id'].toString())
          : null,
      expediteurId: json['expediteur_id'] != null
          ? int.tryParse(json['expediteur_id'].toString())
          : null,
      destinataireId: json['destinataire_id'] != null
          ? int.tryParse(json['destinataire_id'].toString())
          : null,
      enregistreurId: json['enregistreur_id'] != null
          ? int.tryParse(json['enregistreur_id'].toString())
          : null,
      colisDetails: details,
      statut: json['statut']?.toString() ?? 'brouillon',
      statutPaiement:
          json['statut_paiement']?.toString() ?? 'en_attente_paiement',
      refundStatus:
          refundDetails['status']?.toString() ?? json['refund']?.toString(),
      refundAmount:
          double.tryParse(refundDetails['amount']?.toString() ?? '0') ?? 0,
      refundPenalty:
          double.tryParse(refundDetails['penalty_amount']?.toString() ?? '0') ??
          0,
      montant: double.tryParse(json['montant']?.toString() ?? '0') ?? 0,
      montantBase:
          double.tryParse(json['montant_base']?.toString() ?? '0') ?? 0,
      montantTaxe:
          double.tryParse(json['montant_taxe']?.toString() ?? '0') ?? 0,
      tauxTaxe: double.tryParse(json['taxe_taux']?.toString() ?? '0') ?? 0,
      modePaiement: json['mode_paiement']?.toString() ?? 'MOBILEMONEY',
      valeurEstime:
          double.tryParse(json['valeur_estime']?.toString() ?? '0') ?? 0,
      nombreColis: int.tryParse(json['nombre_colis']?.toString() ?? '1') ?? 1,
      origine: json['origine']?.toString() ?? 'en_externe',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      mecefResponse: mecefResponse,
      enregistreurNom: enregistreur == null
          ? null
          : '${enregistreur['prenom'] ?? ''} ${enregistreur['nom'] ?? ''}'
                .trim(),
      taxeGroupId: int.tryParse(
        (json['taxe_group_id'] ?? taxGroup?['id'])?.toString() ?? '',
      ),
      taxGroupLabel: taxGroup?['label']?.toString(),
      taxGroupCode: taxGroup?['code']?.toString(),
      agenceDepotNom: agenceDepot?['nom_agence']?.toString(),
      agenceRetraitNom: agenceRetrait?['nom_agence']?.toString(),
      expediteurNom: expNom,
      expediteurTel: expediteur?['numero']?.toString(),
      destinataireNom: destNom,
      destinataireNomFamille: destinataire?['nom']?.toString(),
      destinatairePrenom: destinataire?['prenom']?.toString(),
      destinataireTel: destinataire?['numero']?.toString(),
      destinataireTelSecondaire: json['destinataire_tel2']?.toString(),
    );
  }

  ParcelRecord toParcelRecord() {
    final firstDetail = colisDetails.isNotEmpty ? colisDetails.first : null;
    final natureSummary = colisDetails
        .map((d) => '${d.nature} x${d.nombre}')
        .join(', ');

    String displayStatus;
    switch (statut) {
      case 'brouillon':
        displayStatus = statutPaiement == 'payé'
            ? 'Payé (Brouillon)'
            : 'En attente';
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
      amountBase: montantBase,
      taxAmount: montantTaxe,
      taxRate: tauxTaxe,
      taxGroupId: taxeGroupId,
      taxGroupLabel: taxGroupLabel,
      taxGroupCode: taxGroupCode,
      mecefInfo: mecefResponse == null
          ? null
          : ParcelMecefInfo.fromJson(mecefResponse!),
      parcelItems: colisDetails
          .map(
            (detail) => ParcelLine(
              nature: detail.nature,
              quantity: detail.nombre,
              weight: detail.poids,
              value: detail.valeur,
              description: detail.description,
              attachmentPath: detail.imagePath,
            ),
          )
          .toList(),
    );
  }
}
