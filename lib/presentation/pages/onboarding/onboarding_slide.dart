// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/onboarding_data_model.dart';
import 'onboarding_placeholder.dart';

/// Widget représentant une seule slide d'onboarding.
/// Reçoit un [OnboardingData] et affiche l'illustration, le titre et la description.
class OnboardingSlide extends StatelessWidget {
  final OnboardingData data; // Les données à afficher pour cette slide
  final int slideIndex; // Index de la slide pour ajuster la taille

  const OnboardingSlide({
    super.key,
    required this.data,
    required this.slideIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Les deux premières illustrations sont plus larges, donc elles gardent
      // moins de marge horizontale que la troisième.
      padding: EdgeInsets.symmetric(horizontal: slideIndex < 2 ? 16 : 28),
      child: Column(
        children: [
          // Zone illustration
          Flexible(
            flex: slideIndex < 2 ? 7 : 6, // Plus grand pour slides 1 et 2
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Image.asset(
                data.illustrationAsset, // Charge l'image depuis les assets
                fit: slideIndex < 2 ? BoxFit.cover : BoxFit.contain,
                // Si l'image est absente, affiche le placeholder gris
                errorBuilder: (_, __, ___) => const OnboardingPlaceholder(),
              ),
            ),
          ),

          // Titre de la slide
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A3E), // Bleu foncé
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Flexible(
            flex: 4,
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.6, // Interligne
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
