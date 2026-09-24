part of '../home_page.dart';

// Flux de reservation client: formulaires, paiement, billet genere, edition et annulation.

class TarifsPlaceholderCard extends StatelessWidget {
  const TarifsPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Liste des tarifs (placeholder)',
        style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  final _HomeTab tab;

  const _HomeTabContent({required super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          tab.description,
          style: const TextStyle(
            color: Color(0xFF5F6B86),
            fontSize: 14.5,
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VoyageTabContent extends StatelessWidget {
  const _VoyageTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _NewsSection(),

            const SizedBox(height: 18),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Vos options de voyage',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _VoyageActionsCard(
              onReservation: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TarifsPage(
                      onCreateReservation: (context, selection) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _ReservationPage(
                              initialDeparture: selection.departure,
                              initialDestination: selection.destination,
                              initialDateLabel: selection.date,
                              initialTime: selection.time,
                              initialPassengerCount: selection.passengerCount,
                              initialPriceAmount: selection.priceAmount,
                              ligneId: selection.ligneId,
                              voyageId: selection.voyageId,
                              dateVoyage: selection.dateVoyage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              onReprogram: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _ReprogramPage()),
                );
              },
              onHistory: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const _HistoryPage()));
              },
              onTarifs: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TarifsPage(
                      onCreateReservation: (context, selection) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _ReservationPage(
                              initialDeparture: selection.departure,
                              initialDestination: selection.destination,
                              initialDateLabel: selection.date,
                              initialTime: selection.time,
                              initialPassengerCount: selection.passengerCount,
                              initialPriceAmount: selection.priceAmount,
                              ligneId: selection.ligneId, // ⬅️ AJOUT
                              voyageId: selection.voyageId, // ⬅️ AJOUT
                              dateVoyage: selection.dateVoyage, // ⬅️ AJOUT
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VoyageActionsCard extends StatelessWidget {
  final VoidCallback onReservation;
  final VoidCallback onReprogram;
  final VoidCallback onHistory;
  final VoidCallback onTarifs;

  const _VoyageActionsCard({
    required this.onReservation,
    required this.onReprogram,
    required this.onHistory,
    required this.onTarifs,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    Widget actionTile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: deepBlue.withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: green.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, size: 20, color: green),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepBlue,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                actionTile(
                  icon: Icons.event_available_rounded,
                  label: 'Reservation',
                  onTap: onReservation,
                ),
                const SizedBox(width: 12),
                actionTile(
                  icon: Icons.schedule_send_rounded,
                  label: 'Reprogrammation',
                  onTap: onReprogram,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                actionTile(
                  icon: Icons.history_rounded,
                  label: 'Historique',
                  onTap: onHistory,
                ),
                const SizedBox(width: 12),
                actionTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Tarifs',
                  onTap: onTarifs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationPage extends StatefulWidget {
  final String? initialDeparture;
  final String? initialDestination;
  final String? initialDateLabel;
  final String? initialTime;
  final int initialPassengerCount;
  final int initialPriceAmount;
  final int? ligneId; // ⬅️ AJOUT
  final int? voyageId; // ⬅️ AJOUT
  final DateTime? dateVoyage; // ⬅️ AJOUT

  const _ReservationPage({
    this.initialDeparture,
    this.initialDestination,
    this.initialDateLabel,
    this.initialTime,
    this.initialPassengerCount = 1,
    this.initialPriceAmount = 0,
    this.ligneId, // ⬅️ AJOUT
    this.voyageId, // ⬅️ AJOUT
    this.dateVoyage, // ⬅️ AJOUT
  });

  @override
  State<_ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<_ReservationPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int _passengerCount = 1;
  DateTime? _travelDate;
  String _selectedTime = '6h20';

  List<String> _cities = _beninCities;
  final Map<String, int> _voyageByTime = {};
  List<String> _availableTimes = [];
  int? _selectedLigneId;
  int? _selectedVoyageId;
  int _dynamicPrice = 0;
  bool _isLoadingAvailability = false;

  @override
  void initState() {
    super.initState();
    _departController.text = widget.initialDeparture ?? 'Cotonou';
    _destinationController.text = widget.initialDestination ?? 'Porto-Novo';
    _passengerCount = widget.initialPassengerCount.clamp(1, 8).toInt();

    if (widget.voyageId != null && widget.initialTime != null) {
      _selectedTime = widget
          .initialTime!; // ⬅️ AJOUT : accepte l'heure réelle sans filtrage
    }

    final initialDate =
        widget.dateVoyage ??
        _dateFromTarifLabel(widget.initialDateLabel); // ⬅️ MODIF
    if (initialDate != null) {
      _travelDate = initialDate;
      _dateController.text =
          '${initialDate.day.toString().padLeft(2, '0')} ${_getMonthName(initialDate.month)} ${initialDate.year}';
    }
    if (widget.ligneId != null) {
      _selectedLigneId = widget.ligneId;
      _selectedVoyageId = widget.voyageId;
    } else {
      final today = DateTime.now();
      _travelDate = DateTime(today.year, today.month, today.day);
      _dateController.text =
          '${today.day.toString().padLeft(2, '0')} ${_getMonthName(today.month)} ${today.year}';
      _loadDynamicCities();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshAvailability();
      });
    }
  }

  Future<void> _loadDynamicCities() async {
    try {
      final cities = await LigneService().getVillesDisponibles();
      if (mounted && cities.isNotEmpty) setState(() => _cities = cities);
    } catch (_) {
      // Les villes locales restent disponibles en cas d'erreur réseau.
    }
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _fofanaGreen,
            onPrimary: Colors.white,
            onSurface: _deepBlue,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _fofanaGreen),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        _travelDate = date;
        _dateController.text =
            '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
      });
      await _refreshAvailability();
    }
  }

  Future<void> _refreshAvailability() async {
    if (widget.ligneId != null ||
        _travelDate == null ||
        _departController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty ||
        _departController.text.trim() == _destinationController.text.trim()) {
      return;
    }

    setState(() {
      _isLoadingAvailability = true;
      _availableTimes = [];
      _voyageByTime.clear();
      _selectedLigneId = null;
      _selectedVoyageId = null;
      _dynamicPrice = 0;
    });

    try {
      final ligne = await LigneService().findTarif(
        depart: _departController.text.trim(),
        destination: _destinationController.text.trim(),
      );
      if (ligne == null) return;

      final disponibilites = await LigneService().rechercheDisponibilites(
        ligneId: ligne.id,
        date: _travelDate!,
      );
      final options = <String>[];
      for (final voyage in disponibilites) {
        for (final heure in voyage.heures) {
          if (heure.placesRestantes > 0) {
            options.add(heure.heure);
            _voyageByTime[heure.heure] = voyage.voyageId;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _selectedLigneId = ligne.id;
        _dynamicPrice = ligne.montant.toInt();
        _availableTimes = options.toSet().toList()..sort();
        if (_availableTimes.isNotEmpty &&
            !_availableTimes.contains(_selectedTime)) {
          _selectedTime = _availableTimes.first;
        }
        _selectedVoyageId = _voyageByTime[_selectedTime];
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les voyages disponibles.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAvailability = false);
    }
  }

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
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _deepBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _deepBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: _deepBlue.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cities.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      return ListTile(
                        title: Text(
                          city,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          controller.text = city;
                          Navigator.of(context).pop();
                          _refreshAvailability();
                        },
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

  int get _fare {
    if (widget.initialPriceAmount > 0) {
      return widget.initialPriceAmount * _passengerCount;
    }
    return _dynamicPrice * _passengerCount;
  }

  Future<void> _confirmReservation() async {
    if (_departController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _travelDate == null ||
        _selectedLigneId == null ||
        _selectedVoyageId == null ||
        _passengerCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter tous les champs.')),
      );
      return;
    }

    if (_departController.text == _destinationController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La destination doit être différente du départ.'),
        ),
      );
      return;
    }

    if (_fare <= 0 ||
        (widget.ligneId == null && _availableTimes.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun voyage disponible pour ce trajet et cette date.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PaymentDetailsPage(
          departure: _departController.text.trim(),
          destination: _destinationController.text.trim(),
          date:
              '${_travelDate!.day.toString().padLeft(2, '0')} ${_getMonthName(_travelDate!.month)} ${_travelDate!.year}',
          priceAmount: _fare,
          passengers: _passengerCount,
          time: _selectedTime,
          ligneId: _selectedLigneId,
          voyageId: _selectedVoyageId,
          dateVoyage: _travelDate,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[month - 1];
  }

  DateTime? _dateFromTarifLabel(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    final now = DateTime.now();
    switch (label.trim()) {
      case 'Aujourd’hui':
      case "Aujourd'hui":
        return now;
      case 'Demain':
        return now.add(const Duration(days: 1));
      case 'Après-demain':
      case 'Apres-demain':
        return now.add(const Duration(days: 2));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/welcome_image.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0x99060E27),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _HeaderIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_fofana_no_background.png',
                        height: 44,
                        width: 142,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Réserver un billet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const _HistoryPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          'Nouvelle réservation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F9FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildReservationForm(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _deepBlue.withValues(alpha: 0.07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                      onTap: _switchLocations,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _deepBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _deepBlue.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  label: 'Date de départ',
                  value: _dateController.text.isEmpty
                      ? 'Sélectionner une date'
                      : _dateController.text,
                  icon: Icons.calendar_month_rounded,
                  onTap: widget.voyageId != null
                      ? () {}
                      : _pickDate,
                  disabled: widget.voyageId != null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallField(
                  label: 'Heure',
                  value: widget.voyageId != null
                      ? _selectedTime
                      : _isLoadingAvailability
                      ? 'Chargement...'
                      : (_availableTimes.isEmpty
                          ? 'Choisir une date et un trajet'
                          : _selectedTime),
                  icon: Icons.schedule_rounded,
                  onTap: widget.voyageId != null || _availableTimes.isEmpty
                      ? () {}
                      : _showTimePicker,
                  disabled: widget.voyageId != null || _availableTimes.isEmpty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPassengerCard(),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoadingAvailability ? null : _confirmReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _fofanaGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Suivant',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchLocations() {
    final first = _departController.text;
    _departController.text = _destinationController.text;
    _destinationController.text = first;
    setState(() {});
    _refreshAvailability();
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choisir l’heure de départ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ..._availableTimes.map(
                (time) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: time == _selectedTime
                            ? _fofanaGreen
                            : _deepBlue.withValues(alpha: 0.10),
                      ),
                    ),
                    tileColor: Colors.white,
                    leading: Icon(
                      time == _selectedTime
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      color: time == _selectedTime ? _fofanaGreen : _deepBlue,
                    ),
                    title: Text(
                      time,
                      style: const TextStyle(
                        color: _deepBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                        _selectedVoyageId = _voyageByTime[time];
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: disabled ? Colors.white : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _deepBlue.withValues(alpha: 0.12)),
          boxShadow: disabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: disabled
                    ? const Color(0xFFB4BFD4)
                    : const Color(0xFF5F6B86),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(icon, size: 18, color: _deepBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: _deepBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Passager(s)',
                  style: TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sélectionnez le nombre de voyageurs',
                  style: TextStyle(
                    color: Color(0xFF7F8BAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: () {
                  setState(() {
                    if (_passengerCount > 1) _passengerCount -= 1;
                  });
                },
              ),
              const SizedBox(width: 10),
              Text(
                '$_passengerCount',
                style: const TextStyle(
                  color: _deepBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              _buildStepperButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    if (_passengerCount < 8) _passengerCount += 1;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _deepBlue.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: _deepBlue),
      ),
    );
  }
}

class _PaymentDetailsPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final int priceAmount;
  final int passengers;
  final String time;
  final int? ligneId; // ⬅️ AJOUT
  final int? voyageId; // ⬅️ AJOUT
  final DateTime? dateVoyage; // ⬅️ AJOUT

  const _PaymentDetailsPage({
    required this.departure,
    required this.destination,
    required this.date,
    required this.priceAmount,
    required this.passengers,
    this.time = '10:00',
    this.ligneId, // ⬅️ AJOUT
    this.voyageId, // ⬅️ AJOUT
    this.dateVoyage, // ⬅️ AJOUT
  });

  @override
  State<_PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<_PaymentDetailsPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _requesterPhoneController =
      TextEditingController();
  final TextEditingController _beneficiaryFirstNameController =
      TextEditingController();
  final TextEditingController _beneficiaryLastNameController =
      TextEditingController();
  final TextEditingController _beneficiaryPhoneController =
      TextEditingController();

  bool _isForSomeoneElse = false;

  @override
  void initState() {
    super.initState();
    _requesterPhoneController.text = SessionStore.currentClientPhone ?? '';
  }

  @override
  void dispose() {
    _requesterPhoneController.dispose();
    _beneficiaryFirstNameController.dispose();
    _beneficiaryLastNameController.dispose();
    _beneficiaryPhoneController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;
  Future<void> _finishReservation() async {
    final requesterPhone = _requesterPhoneController.text.trim();
    final beneficiaryFirstName = _beneficiaryFirstNameController.text.trim();
    final beneficiaryLastName = _beneficiaryLastNameController.text.trim();
    final beneficiaryPhone = _beneficiaryPhoneController.text.trim();

    if (requesterPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le numéro demandeur.')),
      );
      return;
    }

    if (_isForSomeoneElse &&
        (beneficiaryFirstName.isEmpty ||
            beneficiaryLastName.isEmpty ||
            beneficiaryPhone.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez compléter les informations du bénéficiaire.'),
        ),
      );
      return;
    }

    // ⬇️ AJOUT : garde-fou si on n'a pas les vraies infos backend (ex: vieux flux mock)
    if (widget.ligneId == null ||
        widget.voyageId == null ||
        widget.dateVoyage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informations de voyage incomplètes. Relancez une recherche.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Retrouver le bus_id réel pour ce voyage précis, à cette date
      final programme = await TicketService().getProgrammationParDate(
        ligneId: widget.ligneId!,
        date: widget.dateVoyage!,
        voyageId: widget.voyageId!,
      );

      if (programme == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ce voyage n’est plus disponible à cette date. Veuillez relancer une recherche.',
            ),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // 2. Créer le ticket réel côté backend
      final result = await TicketService().storeTicket(
        ligneId: widget.ligneId!,
        voyageId: widget.voyageId!,
        busId: programme.busId,
        villeArrivee: widget.destination,
        dateVoyage: widget.dateVoyage!,
        heureVoyage: widget.time,
        tiers: _isForSomeoneElse,
        nomPassager: _isForSomeoneElse ? beneficiaryFirstName : null,
        prenomPassager: _isForSomeoneElse ? beneficiaryLastName : null,
        numeroPassager: _isForSomeoneElse ? beneficiaryPhone : null,
        nbrePlace: widget.passengers,
      );

      if (!mounted) return;

      final ticketData = result['ticket'] as Map<String, dynamic>?;
      final registeredClientName = SessionStore.currentClientFullName?.trim();

      final beneficiaryName = _isForSomeoneElse
          ? '$beneficiaryFirstName $beneficiaryLastName'
          : (registeredClientName != null && registeredClientName.isNotEmpty)
          ? registeredClientName
          : 'Moi-même';

      // 3. Construire l'objet d'affichage local à partir de la vraie réponse backend
      final reservation = _ReservationItem(
        ticketId: int.tryParse(ticketData?['id']?.toString() ?? ''),
         voyageId: widget.voyageId, // ⬅️ AJOUT
        reference:
            ticketData?['reference']?.toString() ??
            'TB${DateTime.now().millisecondsSinceEpoch}',
        departure: widget.departure,
        destination: widget.destination,
        date: '${widget.dateVoyage!.day.toString().padLeft(2, '0')}/'
              '${widget.dateVoyage!.month.toString().padLeft(2, '0')}/'
              '${widget.dateVoyage!.year}',
        time: widget.time,
        seat: '${(widget.passengers % 12 == 0 ? 12 : widget.passengers)}A',
        price: '${_formatAmount(widget.priceAmount)} CFA',
        passengerCount: widget.passengers,
        beneficiaryName: beneficiaryName,
        requesterPhone: requesterPhone,
        beneficiaryPhone: _isForSomeoneElse ? beneficiaryPhone : requesterPhone,
        isPaymentPending: result['statut_paiement'] != 'payé',
        status: result['statut_paiement'] == 'payé'
            ? 'Confirmée'
            : 'En attente de paiement',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _GeneratedTicketPage(reservation: reservation),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _deepBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/logo_fofana_no_background.png',
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Confirmation',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entrez le numéro de téléphone et le destinataire.',
                      style: TextStyle(
                        color: _deepBlue.withValues(alpha: 0.72),
                        fontSize: 14.2,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Numéro de téléphone demandeur :'),
                    const SizedBox(height: 12),
                    PhoneLoginField(controller: _requesterPhoneController),
                    const SizedBox(height: 18),
                    _buildCheckboxCard(),
                    if (_isForSomeoneElse) ...[
                      const SizedBox(height: 22),
                      _buildSectionHeader('Nom et Prénom du bénéficiaire :'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _beneficiaryFirstNameController,
                        label: 'Nom',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _beneficiaryLastNameController,
                        label: 'Prénom',
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('N° du bénéficiaire :'),
                      const SizedBox(height: 12),
                      PhoneLoginField(controller: _beneficiaryPhoneController),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : _finishReservation, // ⬅️ MODIF
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fofanaGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isSubmitting // ⬅️ AJOUT
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Terminer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _deepBlue,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.24),
          width: 1.4,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 16,
          ),
          hintText: label,
          hintStyle: const TextStyle(
            color: Color(0xFF7B849B),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCheckboxCard() {
    return GestureDetector(
      onTap: () => setState(() => _isForSomeoneElse = !_isForSomeoneElse),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isForSomeoneElse
              ? _fofanaGreen.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isForSomeoneElse
                ? _fofanaGreen
                : _deepBlue.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _isForSomeoneElse ? _fofanaGreen : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _deepBlue.withValues(alpha: 0.18)),
              ),
              child: Icon(
                _isForSomeoneElse ? Icons.check : Icons.check_box_outline_blank,
                size: 18,
                color: _isForSomeoneElse ? Colors.white : _deepBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Achat pour quelqu’un',
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedTicketPage extends StatefulWidget {
  final _ReservationItem reservation;

  const _GeneratedTicketPage({required this.reservation});

  @override
  State<_GeneratedTicketPage> createState() => _GeneratedTicketPageState();
}

class _GeneratedTicketPageState extends State<_GeneratedTicketPage> {
  late _ReservationItem _reservation;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodSheet(
        total: _reservation.price,
        ticketReference: _reservation.reference,
        onPaymentConfirmed: () {
          setState(() {
            _reservation = _reservation.copyWith(status: 'Confirmée');
          });
        },
      ),
    );
  }

  void _editReservation() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditReservationSheet(
      reservation: _reservation,
      onSave: (updated) async {
        await _updateReservation(updated);
      },
    ),
  );
}

Future<void> _updateReservation(_ReservationItem updated) async {
  final ticketId = _reservation.ticketId;
  final voyageId = _reservation.voyageId;
  if (ticketId == null || voyageId == null) {
    _showActionError('Réservation introuvable sur le serveur.');
    return;
  }

  final dateParts = updated.date.split('/');
  if (dateParts.length != 3) {
    _showActionError('Format de date invalide.');
    return;
  }

  try {
    await TicketService().reprogrammer(
      ticketId: ticketId,
      nouvelleDate: '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}',
      nouvelleHeure: _reservation.time,
      nouveauVoyageId: voyageId,
    );
    if (mounted) setState(() => _reservation = updated);
  } catch (error) {
    _showActionError(error.toString().replaceFirst('Exception: ', ''));
  }
}

void _showActionError(String message) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

  Future<void> _confirmCancel() async {
    final shouldCancel = await _showCancelReservationDialog(context);
    if (shouldCancel != true) return;

    final ticketId = _reservation.ticketId;
    if (ticketId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation introuvable sur le serveur.')),
      );
      return;
    }

    try {
      await TicketService().annulerClient(ticketId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
      return;
    }

    _HistoryRepository.removeReservation(_reservation.reference);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réservation annulée.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_fofana_no_background.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const Text(
              'Réservations',
              style: TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1 ticket pour ${_reservation.passengerCount} place${_reservation.passengerCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ReservationPaymentCard(
                      amount: _reservation.price,
                      onPay: _showPaymentSheet,
                    ),
                    const SizedBox(height: 20),
                    _TicketVisual(
                      departure: _reservation.departure,
                      destination: _reservation.destination,
                      date: _reservation.date,
                      time: _reservation.time,
                      passengerCount: _reservation.passengerCount,
                      ticketIndex: 1,
                      beneficiaryName: _reservation.beneficiaryName,
                      total: _reservation.price,
                      reference: _reservation.reference,
                      primaryActionLabel: '',
                      onEdit: _editReservation,
                      onCancel: _confirmCancel,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationPaymentCard extends StatelessWidget {
  final String amount;
  final VoidCallback onPay;

  const _ReservationPaymentCard({
    required this.amount,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepBlue, Color(0xFF116B3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant à payer',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.lock_rounded, size: 19),
              label: const Text('Effectuer le paiement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSheet extends StatefulWidget {
  final String total;
  final String
  ticketReference; // ⬅️ AJOUT : nécessaire pour initier/vérifier le paiement
  final VoidCallback? onPaymentConfirmed;

  const _PaymentMethodSheet({
    required this.total,
    required this.ticketReference,
    this.onPaymentConfirmed,
  });

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  List<PaymentProvider> _providers = [];
  bool _isLoadingProviders = true;
  String? _selectedProviderSlug;
  String _selectedMethod = 'all';
  bool _isProcessing = false;
  Timer? _pollingTimer;

  IconData _providerIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'feexpay':
        return Icons.phone_android_rounded;
      case 'fedapay':
        return Icons.account_balance_wallet_rounded;
      case 'kkiapay':
        return Icons.credit_card_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await PaymentService().getProvidersActifs();
      if (!mounted) return;
      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingProviders = false);
    }
  }

  Future<void> _startPayment() async {
    if (_selectedProviderSlug == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await PaymentService().initierPaiement(
        payableRef: widget.ticketReference,
        provider: _selectedProviderSlug!,
        method: _selectedMethod,
        payableType: 'ticket',
      );

      final transaction = result['transaction'] as Map<String, dynamic>?;
      final transactionReference = transaction?['reference']?.toString();
      if (transactionReference == null || transactionReference.isEmpty) {
        throw Exception('La référence de transaction est absente.');
      }

      if (result['provider'] == 'feexpay') {
        if (!mounted) return;
        await FeexPayService.openPayment(
          context: context,
          amount: num.tryParse(result['amount']?.toString() ?? '') ?? 0,
          token: result['token']?.toString() ?? '',
          shopId: result['shop_id']?.toString() ?? '',
          reference: transactionReference,
          onResult: (paymentResult) async {
            if (!paymentResult.isSuccess) {
              if (mounted) {
                setState(() => _isProcessing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(paymentResult.message ?? 'Paiement échoué.'),
                  ),
                );
              }
              return;
            }
            final verification = await PaymentService().verifierPaiement(
              reference: transactionReference,
              payableType: 'ticket',
              externalId: paymentResult.reference,
            );
            if (mounted && verification['verified'] == true) {
              setState(() => _isProcessing = false);
              widget.onPaymentConfirmed?.call();
              Navigator.of(context).pop();
            }
          },
        );
        return;
      }

      if (result['provider'] == 'kkiapay') {
        if (!mounted) return;
        final customer = result['customer'] as Map<String, dynamic>?;
        final externalId = await KkiapayService.openPayment(
          context: context,
          amount: int.tryParse(result['amount']?.toString() ?? '') ?? 0,
          publicKey: result['public_key']?.toString() ?? '',
          sandbox: result['environment']?.toString() != 'live',
          reference: transactionReference,
          phone: customer?['phone']?.toString(),
          name:
              '${customer?['firstname']?.toString() ?? ''} ${customer?['lastname']?.toString() ?? ''}'
                  .trim(),
          email: customer?['email']?.toString(),
        );
        if (externalId == null || externalId.isEmpty) {
          if (mounted) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiement Kkiapay annulé ou échoué.')),
            );
          }
          return;
        }
        final verification = await PaymentService().verifierPaiement(
          reference: transactionReference,
          payableType: 'ticket',
          externalId: externalId,
        );
        if (mounted && verification['verified'] == true) {
          setState(() => _isProcessing = false);
          widget.onPaymentConfirmed?.call();
          Navigator.of(context).pop();
        }
        return;
      }

      final paymentUrl = result['payment_url']?.toString();

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        final uri = Uri.parse(paymentUrl);
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!opened) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir la page de paiement.'),
            ),
          );
          return;
        }
      }

      // On démarre le polling : on vérifie le statut auprès du backend
      _pollPaymentStatus(transactionReference);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _pollPaymentStatus(String transactionReference) {
    var attempts = 0;
    const maxAttempts = 45; // 45 x 4s = 3 minutes

    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      attempts++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (attempts > maxAttempts) {
        timer.cancel();
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Délai dépassé. Vérifiez votre historique pour le statut du paiement.',
            ),
          ),
        );
        return;
      }

      try {
        final result = await PaymentService().verifierPaiement(
          reference: transactionReference,
          payableType: 'ticket',
        );
        final verified = result['verified'] == true;

        if (verified) {
          timer.cancel();
          if (!mounted) return;
          setState(() => _isProcessing = false);
          widget.onPaymentConfirmed?.call();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement confirmé ! Votre billet est prêt.'),
            ),
          );
        }
        // Sinon on continue le polling silencieusement
      } catch (_) {
        // On ignore les erreurs transitoires de vérification et on continue le polling
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Effectuer le règlement',
              style: TextStyle(
                color: _deepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Montant : ${widget.total}',
              style: const TextStyle(
                color: _fofanaGreen,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),

            if (_isLoadingProviders)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else if (_isProcessing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: const [
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _fofanaGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'En attente de confirmation du paiement...\nRevenez ici une fois le paiement effectué.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _deepBlue,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else if (_providers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucun moyen de paiement disponible pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5F6B86),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else ...[
              // Sélection de l'agrégateur
              ..._providers.map((provider) {
                final isSelectedProvider =
                    _selectedProviderSlug == provider.slug;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedProviderSlug = provider.slug;
                          _selectedMethod = 'all';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelectedProvider
                                ? _fofanaGreen.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelectedProvider
                                  ? _fofanaGreen
                                  : const Color(0xFFE1E4EC),
                              width: isSelectedProvider ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelectedProvider
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: isSelectedProvider
                                    ? _fofanaGreen
                                    : const Color(0xFFB1B8C8),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                _providerIcon(provider.slug),
                                color: isSelectedProvider
                                    ? _fofanaGreen
                                    : _deepBlue,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                provider.name,
                                style: const TextStyle(
                                  color: _deepBlue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _selectedProviderSlug != null
                      ? _startPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _fofanaGreen,
                    disabledBackgroundColor: const Color(0xFFDDE3EE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditReservationSheet extends StatefulWidget {
  final _ReservationItem reservation;
  final Future<void> Function(_ReservationItem) onSave;

  const _EditReservationSheet({
    required this.reservation,
    required this.onSave,
  });

  @override
  State<_EditReservationSheet> createState() => _EditReservationSheetState();
}

class _EditReservationSheetState extends State<_EditReservationSheet> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  late final TextEditingController _departureController;
  late final TextEditingController _destinationController;
  late final TextEditingController _dateController;
  late final TextEditingController _beneficiaryController;
  late final TextEditingController _phoneController;
  late int _passengerCount;

  @override
  void initState() {
    super.initState();
    _departureController = TextEditingController(
      text: widget.reservation.departure,
    );
    _destinationController = TextEditingController(
      text: widget.reservation.destination,
    );
    _dateController = TextEditingController(text: widget.reservation.date);
    _beneficiaryController = TextEditingController(
      text: widget.reservation.beneficiaryName,
    );
    _phoneController = TextEditingController(
      text: widget.reservation.beneficiaryPhone,
    );
    _passengerCount = widget.reservation.passengerCount;
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _beneficiaryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCityPicker(TextEditingController controller, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: _deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _beninCities.length,
                  itemBuilder: (context, index) {
                    final city = _beninCities[index];
                    return ListTile(
                      title: Text(
                        city,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      onTap: () {
                        controller.text = city;
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_departureController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty ||
        _dateController.text.trim().isEmpty ||
        _beneficiaryController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter les champs.')),
      );
      return;
    }

    if (_departureController.text.trim() ==
        _destinationController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La destination doit être différente du départ.'),
        ),
      );
      return;
    }

    await widget.onSave(
      widget.reservation.copyWith(
        departure: _departureController.text.trim(),
        destination: _destinationController.text.trim(),
        date: _dateController.text.trim(),
        passengerCount: _passengerCount,
        beneficiaryName: _beneficiaryController.text.trim(),
        beneficiaryPhone: _phoneController.text.trim(),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifier la réservation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _EditSheetField(
                controller: _departureController,
                label: 'Ville de départ',
                readOnly: true,
                onTap: () =>
                    _showCityPicker(_departureController, 'Choisir le départ'),
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _destinationController,
                label: 'Ville d’arrivée',
                readOnly: true,
                onTap: () => _showCityPicker(
                  _destinationController,
                  'Choisir l’arrivée',
                ),
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _dateController,
                label: 'Date de départ',
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _beneficiaryController,
                label: 'Bénéficiaire',
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _phoneController,
                label: 'Téléphone bénéficiaire',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _deepBlue.withValues(alpha: 0.10)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nombre de passagers',
                        style: TextStyle(
                          color: _deepBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _passengerCount > 1
                          ? () => setState(() => _passengerCount--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: _fofanaGreen,
                    ),
                    Text(
                      '$_passengerCount',
                      style: const TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      onPressed: _passengerCount < 8
                          ? () => setState(() => _passengerCount++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: _fofanaGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _fofanaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditSheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _EditSheetField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: readOnly
            ? const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF0B4F2A),
              )
            : null,
        labelStyle: const TextStyle(
          color: Color(0xFF7B849B),
          fontWeight: FontWeight.w800,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.6),
        ),
      ),
    );
  }
}

Future<bool?> _showCancelReservationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFF16A34A),
          size: 34,
        ),
      ),
      title: const Text(
        'Annuler la réservation ?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF0B4F2A), fontWeight: FontWeight.w900),
      ),
      content: const Text(
        'Voulez-vous vraiment annuler cette réservation ?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Non',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Oui',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}
