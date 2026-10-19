class ParcelSenderDefaults {
  final String name;
  final String phone;

  const ParcelSenderDefaults({required this.name, required this.phone});

  factory ParcelSenderDefaults.fromProfile({
    required bool isPercepteur,
    required String? fullName,
    required String? phone,
  }) {
    return ParcelSenderDefaults(
      name: isPercepteur ? '' : fullName ?? '',
      phone: isPercepteur ? '' : phone ?? '',
    );
  }
}
