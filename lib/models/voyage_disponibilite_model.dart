class HeureDisponibilite {
  final String heure;
  final int placesRestantes;

  HeureDisponibilite({required this.heure, required this.placesRestantes});

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  factory HeureDisponibilite.fromJson(Map<String, dynamic> json) {
    return HeureDisponibilite(
      heure: json['heure']?.toString() ?? '',
      placesRestantes: _toInt(json['places_restantes']),
    );
  }
}

class VoyageDisponibilite {
  final int voyageId;
  final int busId;
  final String busType;
  final int capacite;
  final List<HeureDisponibilite> heures;

  VoyageDisponibilite({
    required this.voyageId,
    required this.busId,
    required this.busType,
    required this.capacite,
    required this.heures,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  factory VoyageDisponibilite.fromJson(Map<String, dynamic> json) {
    return VoyageDisponibilite(
      voyageId: _toInt(json['voyage_id']),
      busId: _toInt(json['bus_id']),
      busType: json['bus_type']?.toString() ?? 'standard',
      capacite: _toInt(json['capacite']),
      heures: (json['heures'] as List<dynamic>? ?? [])
          .map((e) => HeureDisponibilite.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}