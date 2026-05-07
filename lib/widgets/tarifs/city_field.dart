import 'package:flutter/material.dart';

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