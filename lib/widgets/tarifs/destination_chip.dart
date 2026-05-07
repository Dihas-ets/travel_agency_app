// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Chip cliquable représentant une destination populaire
/// Ex: "Niamey › Maradi"
/// Quand on clique dessus, il remplit automatiquement les champs de saisie
class DestinationChip extends StatelessWidget {
  final String from;        // Ville de départ
  final String to;          // Ville d'arrivée
  final VoidCallback onTap; // Action au clic (remplir les champs)

  const DestinationChip({
    super.key,
    required this.from,
    required this.to,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Forme arrondie
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2), // Ombre légère en bas
            ),
          ],
        ),
        // Affiche "Niamey › Maradi"
        child: Text(
          '$from › $to',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}