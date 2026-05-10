import 'package:flutter/material.dart';

/// Indicateur animé des slides d'onboarding.
///
/// Le point actif est plus large que les autres pour montrer la position actuelle.
class DotIndicator extends StatelessWidget {
  /// Nombre total de points à afficher.
  final int count;

  /// Index du point actif.
  final int currentIndex;

  /// Couleur du point actif.
  final Color activeColor;

  /// Couleur des points inactifs.
  final Color inactiveColor;

  const DotIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = const Color.fromRGBO(245, 124, 0, 1),
    this.inactiveColor = const Color(0xFFD9D9D9),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;

        // AnimatedContainer anime la largeur quand l'utilisateur change de slide.
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 14,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
