// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'onboarding_data.dart';
import 'onboarding_placeholder.dart';

/// Widget représentant une seule slide d'onboarding.
/// Reçoit un [OnboardingData] et affiche l'illustration, le titre et la description.
class OnboardingSlide extends StatelessWidget {
  final OnboardingData data; // Les données à afficher pour cette slide

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [

          // Zone illustration
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Image.asset(
                data.illustrationAsset, // Charge l'image depuis les assets
                fit: BoxFit.contain,    // L'image garde ses proportions
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A3E), // Bleu foncé
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Expanded(
            flex: 3,
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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