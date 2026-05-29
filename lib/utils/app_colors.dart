import 'package:flutter/material.dart';

/// Regroupe les couleurs réutilisables de l'application.
///
/// Cette classe évite de répéter les mêmes codes couleur dans plusieurs pages.
class AppColors {
  /// Constructeur privé : cette classe sert seulement de conteneur de constantes.
  AppColors._();

  /// Vert principal du logo Fofana Voyage.
  ///
  /// Il doit rester la couleur d'action dominante : boutons principaux,
  /// éléments sélectionnés, confirmations et icônes importantes.
  static const Color primary = Color(0xFF16A34A);

  /// Vert foncé utilisé pour les titres, icônes fortes et barres.
  ///
  /// Il apporte le contraste nécessaire sur les fonds blancs et verts doux.
  static const Color darkGreen = Color(0xFF0B4F2A);

  /// Vert doux pour les fonds légers, badges et états calmes.
  static const Color lightGreen = Color(0xFFEAF7EF);

  /// Fond général clair de l'application.
  ///
  /// Légèrement verdâtre pour garder l'identité Fofana sans fatiguer les yeux.
  static const Color background = Color(0xFFF8FCF9);

  /// Blanc cassé utilisé par les pages avec cartes et formulaires.
  static const Color surfaceSoft = Color(0xFFF6FBF7);

  /// Bordure discrète des cartes, champs et panneaux.
  static const Color border = Color(0xFFE1EFE6);

  /// Texte secondaire pour les descriptions et métadonnées.
  static const Color mutedText = Color(0xFF607169);

  /// Vert très clair pour les surbrillances sans forte saturation.
  static const Color greenMist = Color(0xFFDFF5E7);
}
