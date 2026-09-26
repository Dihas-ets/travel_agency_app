class TaxGroup {
  final int id;
  final String label;
  final String? code;
  final double rate;
  final List<String> defaultFor;

  const TaxGroup({
    required this.id,
    required this.label,
    this.code,
    required this.rate,
    required this.defaultFor,
  });

  factory TaxGroup.fromJson(Map<String, dynamic> json) {
    final rawDefaultFor = json['is_default_for'];

    return TaxGroup(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      label: json['label']?.toString() ?? '',
      code: json['code']?.toString(),
      rate: double.tryParse(json['taux_defaut']?.toString() ?? '') ?? 0,
      defaultFor: rawDefaultFor is List
          ? rawDefaultFor.map((value) => value.toString()).toList()
          : const [],
    );
  }

  bool appliesAsDefaultTo(String module) => defaultFor.contains(module);
}
