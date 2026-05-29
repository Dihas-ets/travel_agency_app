import 'package:flutter/material.dart';

/// Regroupe les couleurs réutilisables de l'application.
///
/// Cette classe évite de répéter les mêmes codes couleur dans plusieurs pages.
class AppColors {
  /// Constructeur privé : cette classe sert seulement de conteneur de constantes.
  AppColors._();

  /// Vert principal du logo Fofana Voyage.
  static const Color primary = Color(0xFF16A34A);

  /// Vert foncé utilisé pour les titres, icônes fortes et barres.
  static const Color darkGreen = Color(0xFF0B4F2A);

  /// Vert doux pour les fonds légers.
  static const Color lightGreen = Color(0xFFEAF7EF);

  /// Fond général clair de l'application.
  static const Color background = Color(0xFFF8FCF9);
}
