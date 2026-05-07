/// Modèle de données représentant le contenu d'une slide d'onboarding
class OnboardingData {
  final String title;           // Titre affiché en grand
  final String description;     // Texte descriptif sous le titre
  final String illustrationAsset; // Chemin vers l'image dans les assets

  // Marqué const car les données ne changent jamais → optimisation mémoire
  const OnboardingData({
    required this.title,
    required this.description,
    required this.illustrationAsset,
  });
}