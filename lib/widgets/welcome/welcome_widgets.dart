// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Grand logo STM utilisé sur la page d'accueil
/// Affiche "STM" en blanc dans un cadre ovale orange
class STMLogo extends StatelessWidget {
  const STMLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center, // Centre tous les enfants
      children: [
        // Cadre ovale avec bordure orange
        Container(
          width: 130,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: const Color(0xFFFF8C00), // Orange STM
              width: 3.5,
            ),
          ),
        ),

        // Texte "STM" centré dans le cadre
        const Text(
          'STM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1,
          ),
        ),

        // Petite flèche orange en bas à droite (détail graphique du logo)
        Positioned(
          right: 0,
          bottom: 14,
          child: Container(
            width: 18,
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8C00),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouton de navigation en forme de pilule
/// Prend une icône, un label et une action onTap
class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Déclenche l'action passée en paramètre
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          // Fond noir semi-transparent pour que le bouton reste lisible
          // sur l'image de fond
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(30), // Forme arrondie (pilule)
          border: Border.all(
            color: Colors.white.withOpacity(0.15), // Bordure subtile
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ne prend que l'espace nécessaire
          children: [
            Icon(icon, color: const Color(0xFFFF8C00), size: 18), // Icône orange
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}