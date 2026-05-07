// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Petite version du logo STM utilisée dans la page Tarifs (AppBar)
/// Le "S" est orange et "TM" est bleu
class STMLogoSmall extends StatelessWidget {
  const STMLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Permet au contenu de déborder du Stack
      children: [
        // Cadre ovale avec bordure orange
        Container(
          width: 72,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFF8C00),
              width: 2.5,
            ),
          ),
        ),

        // Texte bicolore : "S" orange + "TM" bleu
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'S',
                style: TextStyle(
                  color: Color(0xFFFF8C00), // Orange pour le S
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'TM',
                style: TextStyle(
                  color: Color(0xFF1A6FC4), // Bleu pour TM
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        // Petite flèche orange en bas à droite
        Positioned(
          right: -2,
          bottom: 6,
          child: Container(
            width: 10,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8C00),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Champ de saisie pour une ville (Départ ou Destination)
/// Utilisé dans la page Tarifs
class CityField extends StatelessWidget {
  final TextEditingController controller; // Contrôleur pour lire/écrire la valeur
  final String label;   // Ex: "De" ou "À"
  final String hint;    // Ex: "Ville de départ"
  final bool isFirst;   // Indique si c'est le premier champ (non utilisé visuellement ici)

  const CityField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Icône de localisation orange à gauche
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFFF8C00),
            size: 22,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label au-dessus du champ (ex: "De" ou "À")
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Champ de saisie sans bordure visible
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none, // Pas de bordure par défaut
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Espace réservé pour le bouton swap (défini dans tarifs_page.dart)
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

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