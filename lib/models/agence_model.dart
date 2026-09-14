class Agence {
  final int id;
  final String nomAgence;
  final String? image;
  final String adresse;
  final double? latitude;
  final double? longitude;
  final String? tel1;
  final double? distance; // en km, renvoyé par l'endpoint /proches

  Agence({
    required this.id,
    required this.nomAgence,
    this.image,
    required this.adresse,
    this.latitude,
    this.longitude,
    this.tel1,
    this.distance,
  });

  factory Agence.fromJson(Map<String, dynamic> json) {
    return Agence(
      id: json['id'] as int,
      nomAgence: json['nom_agence']?.toString() ?? '',
      image: json['image']?.toString(),
      adresse: json['adresse']?.toString() ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      tel1: json['tel1']?.toString(),
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
    );
  }
}