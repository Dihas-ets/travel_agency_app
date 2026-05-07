// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// Import des widgets réutilisables
import 'package:code_initial/widgets/tarifs/city_field.dart';
import 'package:code_initial/widgets/tarifs/destination_chip.dart';
import 'package:code_initial/widgets/tarifs/stm_logo_small.dart';

class TarifsPage extends StatefulWidget {
  const TarifsPage({super.key});

  @override
  State<TarifsPage> createState() => _TarifsPageState();
}

class _TarifsPageState extends State<TarifsPage> {
  // Contrôleurs pour lire et modifier le texte des champs
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Liste des destinations populaires affichées en chips
  final List<Map<String, String>> _popularDestinations = [
    {'from': 'Niamey', 'to': 'Maradi'},
    {'from': 'Niamey', 'to': 'Tahoua'},
    {'from': 'Niamey', 'to': 'Zinder'},
    {'from': 'Agadez', 'to': 'Niamey'},
  ];

  /// Intervertit les valeurs des deux champs (départ ↔ destination)
  void _swapCities() {
    final temp = _departController.text;
    setState(() {
      _departController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  /// Libère les contrôleurs quand la page est détruite (bonne pratique)
  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Fond gris clair

      body: SafeArea(
        child: Column(
          children: [

            // ── AppBar personnalisée ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icône menu à gauche — appuyer dessus revient en arrière
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context), // Retour à la page précédente
                      child: const Icon(Icons.menu, color: Color(0xFF444444), size: 26),
                    ),
                  ),
                  // Logo centré dans l'AppBar
                  const STMLogoSmall(),
                ],
              ),
            ),

            // ── Titre de la page ───────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Tarifs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),

            // ── Contenu principal scrollable ───────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Carte blanche contenant les deux champs + bouton swap
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              // Champ ville de départ
                              CityField(
                                controller: _departController,
                                label: 'De',
                                hint: 'Ville de départ',
                                isFirst: true,
                              ),

                              // Séparateur entre les deux champs
                              Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                                indent: 16,
                                endIndent: 60,
                              ),

                              // Champ ville de destination
                              CityField(
                                controller: _destinationController,
                                label: 'À',
                                hint: 'Ville de destination',
                                isFirst: false,
                              ),
                            ],
                          ),

                          // Bouton swap positionné à droite au centre vertical
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _swapCities, // Inverse départ ↔ destination
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.swap_vert_rounded,
                                    color: Color(0xFF888888),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton de recherche pleine largeur
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // implémenter la logique de recherche
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(0xFFFF8C00).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Recherche',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Titre section destinations populaires
                    const Text(
                      'Destinations les plus recherchées :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Chips générées dynamiquement depuis _popularDestinations
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _popularDestinations
                          .map((dest) => DestinationChip(
                                from: dest['from']!,
                                to: dest['to']!,
                                // Au clic, remplit les champs avec la destination choisie
                                onTap: () {
                                  setState(() {
                                    _departController.text = dest['from']!;
                                    _destinationController.text = dest['to']!;
                                  });
                                },
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bouton flottant "+" en bas à droite
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),

      // Barre de navigation en bas
      bottomNavigationBar: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2), // Ombre vers le haut
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF888888)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.radio_button_unchecked, color: Color(0xFF888888)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.remove, color: Color(0xFF888888)),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}