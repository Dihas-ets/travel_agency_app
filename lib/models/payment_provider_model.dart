class PaymentProvider {
  final String slug;
  final String name;
  final Map<String, String> methods; // ex: {'mtn_open': 'MTN Mobile Money', ...}
  final bool configured;

  PaymentProvider({
    required this.slug,
    required this.name,
    required this.methods,
    required this.configured,
  });

  factory PaymentProvider.fromJson(Map<String, dynamic> json) {
    final methodsJson = json['methods'] as Map<String, dynamic>? ?? {};
    return PaymentProvider(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      methods: methodsJson.map((k, v) => MapEntry(k, v.toString())),
      configured: json['configured'] == true,
    );
  }
}