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