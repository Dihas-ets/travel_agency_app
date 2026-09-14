class Ligne {
  final int id;
  final String trajetDepart;
  final String trajetArrivee;
  final int? agenceResponsableId;
  final String? agenceResponsableNom;
  final int distance;
  final double montant;
  final double? montantVip;
  final int dureeMoyenne;
  final String status;

  Ligne({
    required this.id,
    required this.trajetDepart,
    required this.trajetArrivee,
    this.agenceResponsableId,
    this.agenceResponsableNom,
    required this.distance,
    required this.montant,
    this.montantVip,
    required this.dureeMoyenne,
    required this.status,
  });

  // ⬇️ AJOUT : parsing tolérant (String OU num)
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    return null;
  }

  factory Ligne.fromJson(Map<String, dynamic> json) {
    return Ligne(
      id: _toInt(json['id']) ?? 0,
      trajetDepart: json['trajet_depart']?.toString() ?? '',
      trajetArrivee: json['trajet_arrivee']?.toString() ?? '',
      agenceResponsableId: _toInt(json['agence_responsable_id']),
      agenceResponsableNom: json['agence_responsable']?['nom_agence']?.toString(),
      distance: _toInt(json['distance']) ?? 0,
      montant: _toDouble(json['montant']) ?? 0,
      montantVip: _toDouble(json['montant_vip']),
      dureeMoyenne: _toInt(json['duree_moyenne']) ?? 0,
      status: json['status']?.toString() ?? 'actif',
    );
  }
}