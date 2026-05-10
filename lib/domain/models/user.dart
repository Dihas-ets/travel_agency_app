/// Modèle représentant un utilisateur de l'application.
///
/// Il sert à convertir les données reçues depuis une API ou une base locale
/// vers un objet Dart plus simple à manipuler dans le code.
class User {
  /// Identifiant unique de l'utilisateur.
  final String id;

  /// Nom complet affiché dans l'application.
  final String fullName;

  /// Adresse email de l'utilisateur.
  final String email;

  /// Adresse physique. Le champ est optionnel car elle peut être absente.
  final String? adress;

  /// Numéro de téléphone principal.
  final String phoneNumber;

  /// Nom de l'église ou organisation associée, conservé depuis le modèle initial.
  final String churchName;

  /// Indicatif pays lié au numéro de téléphone.
  final String countryCode;

  /// Rôle fonctionnel de l'utilisateur.
  final String role;

  /// Indique si le compte est actif.
  final bool active;

  /// Indique si le compte est marqué comme supprimé.
  final bool deleted;

  /// Indique si l'email a été vérifié.
  final bool emailVerified;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.adress,
    required this.phoneNumber,
    required this.churchName,
    required this.countryCode,
    required this.role,
    required this.active,
    required this.deleted,
    required this.emailVerified,
  });

  /// Construit un utilisateur à partir d'un JSON.
  ///
  /// Les clés doivent correspondre aux noms envoyés par le backend.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      adress: json['adress'],
      phoneNumber: json['phoneNumber'],
      churchName: json['churchName'],
      countryCode: json['countryCode'],
      role: json['role'],
      active: json['active'],
      deleted: json['deleted'],
      emailVerified: json['emailVerified'],
    );
  }

  /// Convertit l'utilisateur en Map pour l'envoyer à une API ou le stocker.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'churchName': churchName,
      'countryCode': countryCode,
      'role': role,
      'active': active,
      'deleted': deleted,
      'emailVerified': emailVerified,
    };
  }
}
