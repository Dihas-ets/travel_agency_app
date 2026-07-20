// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Widget affiché à la place de l'illustration
/// quand l'image asset est introuvable ou pas encore ajoutée
class OnboardingPlaceholder extends StatelessWidget {
  const OnboardingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Fond blanc semi-transparent pour s'intégrer au dégradé de fond
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 80, color: Color(0xFFB6BED3)),
      ),
    );
  }
}
