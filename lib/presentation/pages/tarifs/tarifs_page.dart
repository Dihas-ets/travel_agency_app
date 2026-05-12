// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:code_initial/widgets/tarifs/tarifs_widgets.dart';

/// Page de consultation des tarifs.
///
/// Elle permet de choisir une ville de départ, une ville d'arrivée, puis de
/// lancer une recherche de tarif.
class TarifsPage extends StatefulWidget {
  final String? initialDepart;
  final String? initialDestination;

  const TarifsPage({
    super.key,
    this.initialDepart,
    this.initialDestination,
  });

  @override
  State<TarifsPage> createState() => _TarifsPageState();
}

class _TarifResult {
  final String from;
  final String to;
  final String dateDepart;
  final String heureDepart;
  final int places;
  final int fraisCfa;

  const _TarifResult({
    required this.from,
    required this.to,
    required this.dateDepart,
    required this.heureDepart,
    required this.places,
    required this.fraisCfa,
  });
}

class _TarifsPageState extends State<TarifsPage> {
  // Contrôleurs pour lire et modifier le texte des champs
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final List<_TarifResult> _results = <_TarifResult>[];
  bool _hasSearched = false;

  // Palette inspirée du logo (rouge STM + bleu profond)
  static const Color _stmRed = Color(0xFFF80C0D);
  static const Color _deepBlue = Color(0xFF060663);

  @override
  void initState() {
    super.initState();
    _departController.text = widget.initialDepart ?? '';
    _destinationController.text = widget.initialDestination ?? '';
  }

  // Liste des villes proposées dans la fenêtre de sélection (Bénin)
  final List<String> _cities = [
    'Cotonou',
    'Porto-Novo',
    'Abomey-Calavi',
    'Abomey',
    'Allada',
    'Bohicon',
    'Kétou',
    'Savalou',
    'Ouidah',
    'Lokossa',
    'Kandi',
    'Parakou',
    'Djougou',
    'Natitingou',
    'Bembèrèkè',
    'Malanville',
    'Tanguiéta',
  ];

  // Destinations populaires (Bénin uniquement)
  final List<Map<String, String>> _popularDestinations = [
    {'from': 'Cotonou', 'to': 'Porto-Novo'},
    {'from': 'Cotonou', 'to': 'Abomey-Calavi'},
    {'from': 'Cotonou', 'to': 'Parakou'},
    {'from': 'Abomey', 'to': 'Porto-Novo'},
    {'from': 'Ouidah', 'to': 'Cotonou'},
    {'from': 'Kandi', 'to': 'Parakou'},
  ];

  /// Intervertit les valeurs des deux champs (départ ↔ destination)
  void _swapCities() {
    final temp = _departController.text;
    setState(() {
      _departController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  /// Génère des résultats mockés (pour l’instant) en fonction des villes choisies.
  List<_TarifResult> _buildMockResults({
    required String depart,
    required String destination,
  }) {
    final seed = (depart.length * 17 + destination.length * 31) % 1000;
    final base = 4500 + seed; // CFA

    final List<_TarifResult> res = <_TarifResult>[];
    for (int i = 0; i < 3; i++) {
      final places = 1 + ((seed + i) % 4); // 1..4
      final frais = base + (i * 2500) + (places * 300);
      res.add(
        _TarifResult(
          from: depart,
          to: destination,
          dateDepart: '11 May 2026',
          heureDepart: i == 0
              ? '12:00'
              : (i == 1 ? '15:30' : '18:10'),
          places: places,
          fraisCfa: frais,
        ),
      );
    }
    return res;
  }

  String _formatCfa(int value) => value.toString();

  /// Ouvre une liste de villes en bas de l'écran.
  void _showCityPicker({
    required String title,
    required TextEditingController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _cities.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = controller.text == city;

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) {
                        setState(() {
                          controller.text = city;
                        });
                        Navigator.pop(context);
                      },
                      activeColor: _stmRed,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        city,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconLine({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _stmRed),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _deepBlue,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _TarifResultCard({
    required _TarifResult result,
    required VoidCallback onReserve,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // De / À
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'De',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.from,
                      style: const TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _stmRed.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: _stmRed.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: _stmRed,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'À',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.to,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE6E9F2)),

          const SizedBox(height: 12),

          _buildIconLine(
            icon: Icons.event_rounded,
            label: 'Date de départ : ${result.dateDepart}',
          ),
          const SizedBox(height: 8),
          _buildIconLine(
            icon: Icons.event_seat_rounded,
            label: 'Nbr de places : ${result.places}',
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 18, color: _stmRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Heure départ : ${result.heureDepart}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.money_rounded, size: 22, color: _stmRed),
              const SizedBox(width: 10),
              Text(
                _formatCfa(result.fraisCfa),
                style: const TextStyle(
                  color: _stmRed,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'CFA',
                  style: TextStyle(
                    color: _deepBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onReserve,
              style: ElevatedButton.styleFrom(
                backgroundColor: _stmRed,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.menu,
                        color: Color(0xFF444444),
                        size: 26,
                      ),
                    ),
                  ),
                  const STMLogoSmall(),
                ],
              ),
            ),

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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte formulaire
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
                              CityField(
                                controller: _departController,
                                label: 'De',
                                hint: 'Ville de départ',
                                isFirst: true,
                                onTap: () => _showCityPicker(
                                  title: 'Choisir la ville de départ',
                                  controller: _departController,
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                                indent: 16,
                                endIndent: 60,
                              ),
                              CityField(
                                controller: _destinationController,
                                label: 'À',
                                hint: 'Ville de destination',
                                isFirst: false,
                                onTap: () => _showCityPicker(
                                  title: 'Choisir la ville d’arrivée',
                                  controller: _destinationController,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _swapCities,
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

                    // Bouton rechercher
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final depart = _departController.text.trim();
                          final destination = _destinationController.text.trim();

                          if (depart.isEmpty || destination.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Veuillez renseigner le départ et la destination.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (depart == destination) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Le départ et la destination doivent être différents.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final mock = _buildMockResults(
                            depart: depart,
                            destination: destination,
                          );

                          setState(() {
                            _results
                              ..clear()
                              ..addAll(mock);
                            _hasSearched = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _stmRed,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _stmRed.withOpacity(0.4),
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

                    if (_hasSearched) ...[
                      const SizedBox(height: 18),
                      Text(
                        '${_results.length} résultats trouvés :',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Column(
                        children: _results
                            .map(
                              (r) => _TarifResultCard(
                                result: r,
                                onReserve: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                      content: Text('Réservation : ${r.from} → ${r.to}'),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Chips populaires
                    const Text(
                      'Destinations les plus recherchées :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _popularDestinations
                          .map(
                            (dest) => DestinationChip(
                              from: dest['from']!,
                              to: dest['to']!,
                              onTap: () {
                                setState(() {
                                  _departController.text = dest['from']!;
                                  _destinationController.text = dest['to']!;
                                });
                              },
                            ),
                          )
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _stmRed,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
