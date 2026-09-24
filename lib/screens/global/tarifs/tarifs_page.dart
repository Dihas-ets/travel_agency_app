// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:code_initial/screens/global/widgets/tarifs/tarifs_widgets.dart';

import 'package:code_initial/models/ligne_model.dart';
import 'package:code_initial/models/voyage_disponibilite_model.dart';
import 'package:code_initial/models/voyage_du_jour_model.dart';
import 'package:code_initial/services/ligne_service.dart';

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
  final int? ligneId;
  final int? voyageId;
  final DateTime? dateVoyage;

  const TarifReservationSelection({
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.priceAmount,
    this.ligneId,
    this.voyageId,
    this.dateVoyage,
  });
}

class _TarifResult {
  final String from;
  final String to;
  final String dateDepart;
  final DateTime dateVoyage;
  final String heureDepart;
  final int placesRestantes;
  final int capacity;
  final int fraisCfa;
  final int ligneId;
  final int voyageId;

  const _TarifResult({
    required this.from,
    required this.to,
    required this.dateDepart,
    required this.dateVoyage,
    required this.heureDepart,
    required this.placesRestantes,
    required this.capacity,
    required this.fraisCfa,
    required this.ligneId,
    required this.voyageId,
  });
}

class _TarifsPageState extends State<TarifsPage> {
  // Contrôleurs pour lire et modifier le texte des champs
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final List<_TarifResult> _results = <_TarifResult>[];
  bool _hasSearched = false;
  bool _isSearching = false;

  // Villes disponibles pour la recherche
  List<String> _villes = [];
  bool _isLoadingVilles = true;

  // Voyages programmés aujourd'hui (remplace "Destinations les plus recherchées")
  List<VoyageDuJour> _voyagesDuJour = [];
  bool _isLoadingVoyagesDuJour = true;

  DateTime _selectedDate = DateTime.now();

  // Palette inspirée du logo (rouge Fofana + bleu profond)
  static const Color _fofanaGreen = Color(0xFF16A34A);
  static const Color _deepBlue = Color(0xFF0B4F2A);

  @override
  void initState() {
    super.initState();
    _departController.text = widget.initialDepart ?? '';
    _destinationController.text = widget.initialDestination ?? '';
    _loadVoyagesDuJour();
    _loadVilles();

    // Si le départ et la destination sont déjà renseignés (venant par ex. de
    // la page d'accueil), on lance directement la recherche pour éviter à
    // l'utilisateur de recliquer sur "Rechercher".
    final depart = _departController.text.trim();
    final destination = _destinationController.text.trim();
    if (depart.isNotEmpty && destination.isNotEmpty && depart != destination) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchTarif(depart: depart, destination: destination);
        }
      });
    }
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadVilles() async {
    try {
      final villes = await LigneService().getVillesDisponibles();
      if (!mounted) return;
      setState(() {
        _villes = villes;
        _isLoadingVilles = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingVilles = false);
    }
  }

  Future<void> _loadVoyagesDuJour() async {
    try {
      final voyages = await LigneService().getVoyagesDuJour(limit: 8);
      if (!mounted) return;
      setState(() {
        _voyagesDuJour = voyages;
        _isLoadingVoyagesDuJour = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingVoyagesDuJour = false);
    }
  }

  void _reserveVoyageDuJour(VoyageDuJour voyage) {
    final today = DateTime.now();
    const months = [
      'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];
    final selection = TarifReservationSelection(
      departure: voyage.depart,
      destination: voyage.arrivee,
      date: '${today.day} ${months[today.month - 1]} ${today.year}',
      dateVoyage: today,
      time: voyage.heure,
      passengerCount: 1,
      priceAmount: voyage.montant.toInt(),
      ligneId: voyage.ligneId,
      voyageId: voyage.voyageId,
    );

    final createReservation = widget.onCreateReservation;
    if (createReservation != null) {
      createReservation(context, selection);
      return;
    }
    widget.onReserve?.call(context, selection);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _fofanaGreen, onPrimary: Colors.white, onSurface: _deepBlue),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  String get _selectedDateLabel {
    const months = ['jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  double _tarifPourClasse(Ligne ligne, String busType) {
    final estVip = busType.toLowerCase() == 'vip';
    if (estVip) return ligne.montantVip ?? ligne.montant;
    return ligne.montant;
  }

  /// Intervertit les valeurs des deux champs (départ ↔ destination)
  void _swapCities() {
    final temp = _departController.text;
    setState(() {
      _departController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  String _formatCfa(int value) => value.toString();

  void _reserveTarif(_TarifResult result) {
    final selection = TarifReservationSelection(
      departure: result.from,
      destination: result.to,
      date: result.dateDepart,
      dateVoyage: result.dateVoyage,
      time: result.heureDepart,
      passengerCount: 1,
      priceAmount: result.fraisCfa,
      ligneId: result.ligneId,
      voyageId: result.voyageId,
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

  Future<void> _searchTarif({required String depart, required String destination}) async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _results.clear();
    });

    try {
      final ligne = await LigneService().findTarif(depart: depart, destination: destination);

      if (ligne == null) {
        if (mounted) setState(() {});
        return;
      }

      final disponibilites = await LigneService().rechercheDisponibilites(
        ligneId: ligne.id,
        date: _selectedDate,
      );

      if (!mounted) return;

      final results = <_TarifResult>[];
      for (final voyage in disponibilites) {
        final tarif = _tarifPourClasse(ligne, voyage.busType);
        for (final h in voyage.heures) {
          results.add(_TarifResult(
            from: ligne.trajetDepart,
            to: ligne.trajetArrivee,
            dateDepart: _selectedDateLabel,
            dateVoyage: _selectedDate,
            heureDepart: h.heure,
            placesRestantes: h.placesRestantes,
            capacity: voyage.capacite,
            fraisCfa: tarif.toInt(),
            ligneId: ligne.id,
            voyageId: voyage.voyageId,
          ));
        }
      }

      results.sort((a, b) => a.heureDepart.compareTo(b.heureDepart));

      setState(() => _results.addAll(results));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la recherche des tarifs.')),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _openReservationFromInput() {
    final depart = _departController.text.trim();
    final destination = _destinationController.text.trim();

    if (depart.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renseignez le départ et la destination, puis lancez une recherche.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (depart == destination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le départ et la destination doivent être différents.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _searchTarif(depart: depart, destination: destination);
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
                              _isLoadingVilles
                                  ? 'Chargement des villes...'
                                  : '${_villes.length} ville${_villes.length > 1 ? 's' : ''} disponible${_villes.length > 1 ? 's' : ''}',
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

                if (_isLoadingVilles)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                  )
                else if (_villes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Center(
                      child: Text(
                        'Aucune ville disponible pour le moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF7B849B), fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      itemCount: _villes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final city = _villes[index];
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                    isSelected ? Icons.check_circle_rounded : Icons.location_on_outlined,
                                    color: isSelected ? _fofanaGreen : _deepBlue.withValues(alpha: 0.54),
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
                                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFB1B8C8)),
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
                  border: Border.all(
                    color: _fofanaGreen.withValues(alpha: 0.35),
                  ),
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
            label: 'Places restantes : ${result.placesRestantes}/${result.capacity}',
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
              onPressed: result.placesRestantes > 0 ? onReserve : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _fofanaGreen,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                result.placesRestantes > 0 ? 'Réserver' : 'Complet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
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

                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _deepBlue.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: _fofanaGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Date : $_selectedDateLabel',
                                style: const TextStyle(color: _deepBlue, fontSize: 14.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB1B8C8)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton rechercher
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : () {
                          final depart = _departController.text.trim();
                          final destination = _destinationController.text.trim();

                          if (depart.isEmpty || destination.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez renseigner le départ et la destination.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (depart == destination) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Le départ et la destination doivent être différents.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          _searchTarif(depart: depart, destination: destination);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fofanaGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _fofanaGreen.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSearching
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : const Text('Rechercher', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    if (_hasSearched) ...[
                      const SizedBox(height: 18),
                      if (_results.isEmpty && !_isSearching)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
                          ),
                          child: const Center(
                            child: Text(
                              'Aucun tarif trouvé pour ce trajet à cette date.\nContactez une agence pour plus d’informations.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700, height: 1.4),
                            ),
                          ),
                        )
                      else if (!_isSearching) ...[
                        Text(
                          '${_results.length} résultat${_results.length > 1 ? 's' : ''} trouvé${_results.length > 1 ? 's' : ''} :',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E)),
                        ),
                        const SizedBox(height: 14),
                        Column(
                          children: _results.map((r) => _TarifResultCard(result: r, onReserve: () => _reserveTarif(r))).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],

                    // Voyages du jour (remplace "Destinations les plus recherchées")
                    if (!_hasSearched) const SizedBox(height: 30),
                    const Text(
                      'Voyages du jour :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (_isLoadingVoyagesDuJour)
                      const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
                    else if (_voyagesDuJour.isEmpty)
                      const Text(
                        'Aucun voyage programmé aujourd’hui.',
                        style: TextStyle(color: Color(0xFF7B849B), fontWeight: FontWeight.w600),
                      )
                    else
                      Column(
                        children: _voyagesDuJour
                            .map((v) => _VoyageDuJourCard(
                                  voyage: v,
                                  onTap: () => _reserveVoyageDuJour(v),
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

class _VoyageDuJourCard extends StatelessWidget {
  final VoyageDuJour voyage;
  final VoidCallback onTap;

  const _VoyageDuJourCard({required this.voyage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${voyage.depart} → ${voyage.arrivee}',
                        style: const TextStyle(color: deepBlue, fontWeight: FontWeight.w900, fontSize: 14.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Départ ${voyage.heure} · ${voyage.placesRestantes} place${voyage.placesRestantes > 1 ? 's' : ''} restante${voyage.placesRestantes > 1 ? 's' : ''}',
                        style: const TextStyle(color: Color(0xFF7B849B), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${voyage.montant.toInt()} CFA',
                  style: const TextStyle(color: green, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}