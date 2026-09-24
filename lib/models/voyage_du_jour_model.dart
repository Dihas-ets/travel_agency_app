class VoyageDuJour {
  final int ligneId;
  final int voyageId;
  final String depart;
  final String arrivee;
  final String heure;
  final double montant;
  final String busType;
  final int placesRestantes;

  VoyageDuJour({
    required this.ligneId,
    required this.voyageId,
    required this.depart,
    required this.arrivee,
    required this.heure,
    required this.montant,
    required this.busType,
    required this.placesRestantes,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  factory VoyageDuJour.fromJson(Map<String, dynamic> json) {
    return VoyageDuJour(
      ligneId: _toInt(json['ligne_id']),
      voyageId: _toInt(json['voyage_id']),
      depart: json['trajet_depart']?.toString() ?? '',
      arrivee: json['trajet_arrivee']?.toString() ?? '',
      heure: json['heure']?.toString() ?? '',
      montant: _toDouble(json['montant']),
      busType: json['bus_type']?.toString() ?? 'standard',
      placesRestantes: _toInt(json['places_restantes']),
    );
  }
}