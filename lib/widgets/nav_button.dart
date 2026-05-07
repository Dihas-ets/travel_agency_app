// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Bouton de navigation en forme de pilule (utilisé dans la HomePage)
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