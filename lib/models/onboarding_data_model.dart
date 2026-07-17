class OnboardingData {
  final String title;
  final String description;
  final String illustrationAsset;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.illustrationAsset,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      illustrationAsset: json['illustrationAsset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'illustrationAsset': illustrationAsset,
    };
  }
}
