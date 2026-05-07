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