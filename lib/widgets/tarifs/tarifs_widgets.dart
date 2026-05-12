// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Widgets réutilisables de la page Tarifs.
///
/// Ils contiennent le logo, les champs de ville et les chips de destinations.

/// Petite version du logo STM utilisée dans la page Tarifs (AppBar)
class STMLogoSmall extends StatelessWidget {
  const STMLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_stm_no_background.png',
      height: 54,
      fit: BoxFit.contain,
    );
  }
}

/// Champ de saisie pour une ville (Départ ou Destination)
/// Utilisé dans la page Tarifs
class CityField extends StatelessWidget {
  /// Controller du champ, mis à jour quand l'utilisateur choisit une ville.
  final TextEditingController
  controller; // Contrôleur pour lire/écrire la valeur

  final String label; // Ex: "De" ou "À"
  final String hint; // Ex: "Ville de départ"

  final bool
  isFirst; // Indique si c'est le premier champ (non utilisé visuellement ici)

  final VoidCallback onTap; // Ouvre la liste des villes

  const CityField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF060663);
    const stmRed = Color(0xFFF80C0D);
    final icon = isFirst
        ? Icons.trip_origin_rounded
        : Icons.location_on_rounded;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final hasValue = controller.text.trim().isNotEmpty;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            isFirst ? 12 : 6,
            12,
            isFirst ? 6 : 12,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                decoration: BoxDecoration(
                  color: hasValue
                      ? const Color(0xFFF8FBFF)
                      : const Color(0xFFF6F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasValue
                        ? stmRed.withValues(alpha: 0.22)
                        : deepBlue.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: hasValue
                            ? stmRed.withValues(alpha: 0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: stmRed, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              color: hasValue
                                  ? stmRed
                                  : const Color(0xFF7B849B),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasValue ? controller.text : hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              color: hasValue
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF8B93A6),
                              fontWeight: hasValue
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: deepBlue.withValues(alpha: 0.58),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Chip cliquable représentant une destination populaire
/// Ex: "Niamey › Maradi"
/// Quand on clique dessus, il remplit automatiquement les champs de saisie
class DestinationChip extends StatelessWidget {
  final String from; // Ville de départ
  final String to; // Ville d'arrivée

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
