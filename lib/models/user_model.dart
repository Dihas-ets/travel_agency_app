import 'package:code_initial/config/app_config.dart';

class UserModel {
  final int id;
  final String? nom;
  final String? prenom;
  final String numero;
  final String? email;
  final String? country;
  final String? profil;
  final String role;
  final String status;
  final DateTime? createdAt;
  final int? agenceId;
  final Map<String, dynamic>? agence;

  const UserModel({
    required this.id,
    this.nom,
    this.prenom,
    required this.numero,
    this.email,
    this.country,
    this.profil,
    this.role = 'client',
    this.status = 'actif',
    this.createdAt,
    this.agenceId,
    this.agence,
  });

  String get fullName {
    final n = (nom ?? '').trim();
    final p = (prenom ?? '').trim();
    if (n.isEmpty && p.isEmpty) return 'Client Fofana';
    if (p.isEmpty) return n;
    if (n.isEmpty) return p;
    return '$p $n';
  }

  String? get photoUrl {
    if (profil == null || profil!.trim().isEmpty) return null;
    final path = profil!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Construit l'URL complète avec le stockage Laravel
    final apiBase = AppConfig.apiBaseUrl;
    final baseHost = apiBase.endsWith('/api')
        ? apiBase.substring(0, apiBase.length - 4)
        : apiBase;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('storage/')) {
      return '$baseHost/$cleanPath';
    }
    return '$baseHost/storage/$cleanPath';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      nom: json['nom']?.toString(),
      prenom: json['prenom']?.toString(),
      numero: json['numero']?.toString() ?? '',
      email: json['email']?.toString(),
      country: json['country']?.toString(),
      profil: json['profil']?.toString(),
      role: json['role']?.toString() ?? 'client',
      status: json['status']?.toString() ?? 'actif',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      agenceId: json['agence_id'] != null
          ? int.tryParse(json['agence_id'].toString())
          : null,
      agence: json['agence'] is Map<String, dynamic>
          ? json['agence'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'numero': numero,
      'email': email,
      'country': country,
      'profil': profil,
      'role': role,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (agenceId != null) 'agence_id': agenceId,
      if (agence != null) 'agence': agence,
    };
  }

  UserModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? numero,
    String? email,
    String? country,
    String? profil,
    String? role,
    String? status,
    DateTime? createdAt,
    int? agenceId,
    Map<String, dynamic>? agence,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      numero: numero ?? this.numero,
      email: email ?? this.email,
      country: country ?? this.country,
      profil: profil ?? this.profil,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      agenceId: agenceId ?? this.agenceId,
      agence: agence ?? this.agence,
    );
  }
}
