class VoyageProgramme {
  final int id;
  final int busId;
  final String busType;
  final int busCapacite;
  final List<String> heuresDepart;
  final double montant;
  final double? montantVip;

  VoyageProgramme({
    required this.id,
    required this.busId,
    required this.busType,
    required this.busCapacite,
    required this.heuresDepart,
    required this.montant,
    this.montantVip,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
    return 0;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory VoyageProgramme.fromJson(Map<String, dynamic> json) {
    final bus = json['bus'] as Map<String, dynamic>?;
    final ligne = json['ligne'] as Map<String, dynamic>?;
    return VoyageProgramme(
      id: _toInt(json['id']),
      busId: _toInt(bus?['id']),
      busType: bus?['type']?.toString() ?? 'standard',
      busCapacite: _toInt(bus?['capacite']),
      heuresDepart: (json['heures_depart'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      montant: _toDouble(ligne?['montant']) ?? 0,
      montantVip: _toDouble(ligne?['montant_vip']),
    );
  }
}