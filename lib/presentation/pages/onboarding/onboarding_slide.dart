// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:code_initial/domain/models/onboarding_data_model.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.48).clamp(190.0, 300.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                // Zone illustration
                Container(
                  width: double.infinity,
                  height: imageHeight,
                  margin: const EdgeInsets.only(top: 4, bottom: 14),
                  padding: EdgeInsets.all(slideIndex < 2 ? 4 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.58),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B4F2A).withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      data.illustrationAsset, // Charge l'image depuis les assets
                      fit: slideIndex < 2 ? BoxFit.cover : BoxFit.contain,
                      // Si l'image est absente, affiche le placeholder gris
                      errorBuilder: (_, __, ___) =>
                          const OnboardingPlaceholder(),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.66),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.88),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Titre de la slide
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Description
                      Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.42,
                          color: Color(0xFF4D5875),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
