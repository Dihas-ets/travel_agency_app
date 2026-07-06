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
  final void Function(
    BuildContext context,
    TarifReservationSelection selection,
  )?
  onReserve;
  final void Function(
    BuildContext context,
    TarifReservationSelection selection,
  )?
  onCreateReservation;

  const TarifsPage({
    super.key,
    this.initialDepart,
    this.initialDestination,
    this.onReserve,
    this.onCreateReservation,
  });

  @override
  State<TarifsPage> createState() => _TarifsPageState();
}

class TarifReservationSelection {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final int priceAmount;

  const TarifReservationSelection({
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.priceAmount,
  });
}

class _TarifResult {
  final String from;
  final String to;
  final String dateDepart;
  final String heureDepart;
  final int places;
  final int capacity;
  final int fraisCfa;

  const _TarifResult({
    required this.from,
    required this.to,
    required this.dateDepart,
    required this.heureDepart,
    required this.places,
    required this.capacity,
    required this.fraisCfa,
  });
}

class _TarifsPageState extends State<TarifsPage> {
  // Contrôleurs pour lire et modifier le texte des champs
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final List<_TarifResult> _results = <_TarifResult>[];
  bool _hasSearched = false;

  // Palette inspirée du logo (rouge Fofana + bleu profond)
  static const Color _fofanaGreen = Color(0xFF16A34A);
  static const Color _deepBlue = Color(0xFF0B4F2A);

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
    'Sèmè-Kpodji',
    'Akpro-Missérété',
    'Adjarra',
    'Avrankou',
    'Dangbo',
    'Adjohoun',
    'Bonou',
    'Abomey',
    'Dassa-Zoumè',
    'Glazoué',
    'Savè',
    'Bantè',
    'Allada',
    'Toffo',
    'Tori-Bossito',
    'Zè',
    'Bohicon',
    'Covè',
    'Zagnanado',
    'Zogbodomey',
    'Za-Kpota',
    'Ouinhi',
    'Agbangnizoun',
    'Djidja',
    'Kétou',
    'Pobè',
    'Sakété',
    'Ifangni',
    'Savalou',
    'Ouidah',
    'Grand-Popo',
    'Comè',
    'Athiémé',
    'Lokossa',
    'Dogbo',
    'Aplahoué',
    'Azovè',
    'Klouékanmè',
    'Djakotomey',
    'Toviklin',
    'Lalo',
    'Kandi',
    'Banikoara',
    'Gogounou',
    'Ségbana',
    'Karimama',
    'Parakou',
    'Tchaourou',
    'Nikki',
    'N’Dali',
    'Pèrèrè',
    'Kalalé',
    'Sinendé',
    'Djougou',
    'Bassila',
    'Copargo',
    'Ouaké',
    'Natitingou',
    'Kouandé',
    'Matéri',
    'Cobly',
    'Boukoumbé',
    'Kérou',
    'Péhunco',
    'Toucountouna',
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
      final places = 4 + ((seed + i * 3) % 9); // 4..12
      final frais = base + (i * 2500) + (places * 300);
      res.add(
        _TarifResult(
          from: depart,
          to: destination,
          dateDepart: i == 0 ? 'Aujourd’hui' : (i == 1 ? 'Demain' : 'Après-demain'),
          heureDepart: i == 0 ? '6h20' : (i == 1 ? '15h10' : '20h'),
          places: places,
          capacity: 30,
          fraisCfa: frais,
        ),
      );
    }
    return res;
  }

  String _formatCfa(int value) => value.toString();

  void _reserveTarif(_TarifResult result) {
    final selection = TarifReservationSelection(
      departure: result.from,
      destination: result.to,
      date: result.dateDepart,
      time: result.heureDepart,
      passengerCount: 1,
      priceAmount: result.fraisCfa,
    );

    final createReservation = widget.onCreateReservation;
    if (createReservation != null) {
      createReservation(context, selection);
      return;
    }

    final handler = widget.onReserve;
    if (handler != null) {
      handler(context, selection);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text('Réservation : ${result.from} → ${result.to}'),
      ),
    );
  }

  void _openReservationFromInput() {
    final depart = _departController.text.trim().isEmpty
        ? 'Cotonou'
        : _departController.text.trim();
    final destination = _destinationController.text.trim().isEmpty
        ? 'Porto-Novo'
        : _destinationController.text.trim();
    final selection = TarifReservationSelection(
      departure: depart,
      destination: destination,
      date: 'Aujourd’hui',
      time: '6h20',
      passengerCount: 1,
      priceAmount: 0,
    );

    final createReservation = widget.onCreateReservation;
    if (createReservation != null) {
      createReservation(context, selection);
      return;
    }

    final reserve = widget.onReserve;
    if (reserve != null) {
      reserve(context, selection);
    }
  }

  /// Ouvre une liste de villes en bas de l'écran.
  void _showCityPicker({
    required String title,
    required TextEditingController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.76,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _deepBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _fofanaGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: _fofanaGreen,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_cities.length} villes disponibles au Bénin',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7B849B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    itemCount: _cities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      final isSelected = controller.text == city;

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              controller.text = city;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? _fofanaGreen.withValues(alpha: 0.36)
                                    : _deepBlue.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.location_on_outlined,
                                  color: isSelected
                                      ? _fofanaGreen
                                      : _deepBlue.withValues(alpha: 0.54),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFB1B8C8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconLine({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _fofanaGreen),
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
                  color: _fofanaGreen.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: _fofanaGreen.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: _fofanaGreen,
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
            label: 'Nbr de places : ${result.places}/${result.capacity}',
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: _fofanaGreen,
              ),
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
              const Icon(Icons.money_rounded, size: 22, color: _fofanaGreen),
              const SizedBox(width: 10),
              Text(
                _formatCfa(result.fraisCfa),
                style: const TextStyle(
                  color: _fofanaGreen,
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
                backgroundColor: _fofanaGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
                  const FofanaLogoSmall(),
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _deepBlue.withValues(alpha: 0.07),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
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
                                    // Cercle de permutation en bleu pour mieux ressortir entre les champs.
                                    color: _deepBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _deepBlue.withValues(
                                          alpha: 0.28,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.swap_vert_rounded,
                                    color: Colors.white,
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
                          final destination = _destinationController.text
                              .trim();

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
                          backgroundColor: _fofanaGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _fofanaGreen.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Rechercher',
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
                                onReserve: () => _reserveTarif(r),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Chips populaires
                    // Espace ajouté pour décoller visuellement les destinations du bouton Recherche.
                    if (!_hasSearched) const SizedBox(height: 30),
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
        onPressed: _openReservationFromInput,
        backgroundColor: _fofanaGreen,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
