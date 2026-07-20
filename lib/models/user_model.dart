class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String churchName;
  final bool active;
  final bool deleted;
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.churchName,
    this.active = true,
    this.deleted = false,
    this.emailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      churchName: json['churchName'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'churchName': churchName,
      'active': active,
      'deleted': deleted,
      'emailVerified': emailVerified,
    };
  }
}
