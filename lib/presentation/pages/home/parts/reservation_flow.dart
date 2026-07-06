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
                  MaterialPageRoute(builder: (_) => const _ReservationPage()),
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

  const _ReservationPage({
    this.initialDeparture,
    this.initialDestination,
    this.initialDateLabel,
    this.initialTime,
    this.initialPassengerCount = 1,
    this.initialPriceAmount = 0,
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

  final List<String> _cities = _beninCities;
  static const List<String> _departureTimes = ['6h20', '15h10', '20h'];

  @override
  void initState() {
    super.initState();
    _departController.text = widget.initialDeparture ?? 'Cotonou';
    _destinationController.text = widget.initialDestination ?? 'Porto-Novo';
    _passengerCount = widget.initialPassengerCount.clamp(1, 8).toInt();
    if (_departureTimes.contains(widget.initialTime)) {
      _selectedTime = widget.initialTime!;
    }
    final initialDate = _dateFromTarifLabel(widget.initialDateLabel);
    if (initialDate != null) {
      _travelDate = initialDate;
      _dateController.text =
          '${initialDate.day.toString().padLeft(2, '0')} ${_getMonthName(initialDate.month)} ${initialDate.year}';
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
    if (_departController.text.isEmpty || _destinationController.text.isEmpty) {
      return 0;
    }
    final seed =
        _departController.text.length + _destinationController.text.length;
    final base = 8000 + (seed % 5) * 500;
    return base + _passengerCount * 1200;
  }

  Future<void> _confirmReservation() async {
    if (_departController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _travelDate == null ||
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
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallField(
                  label: 'Heure',
                  value: _selectedTime,
                  icon: Icons.schedule_rounded,
                  onTap: _showTimePicker,
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
              onPressed: _confirmReservation,
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
              ..._departureTimes.map(
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
                      setState(() => _selectedTime = time);
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

  const _PaymentDetailsPage({
    required this.departure,
    required this.destination,
    required this.date,
    required this.priceAmount,
    required this.passengers,
    this.time = '10:00',
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

  void _finishReservation() {
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

    final registeredClientName = SessionStore.currentClientFullName?.trim();
    final beneficiaryName =
        registeredClientName != null && registeredClientName.isNotEmpty
        ? registeredClientName
        : _isForSomeoneElse
        ? '$beneficiaryFirstName $beneficiaryLastName'
        : 'Moi-même';
    final reservation = _ReservationItem(
      reference: 'TB${DateTime.now().millisecondsSinceEpoch}',
      departure: widget.departure,
      destination: widget.destination,
      date: widget.date,
      time: widget.time,
      seat: '${(widget.passengers % 12 == 0 ? 12 : widget.passengers)}A',
      price: '${_formatAmount(widget.priceAmount)} CFA',
      passengerCount: widget.passengers,
      beneficiaryName: beneficiaryName,
      requesterPhone: requesterPhone,
      beneficiaryPhone: _isForSomeoneElse ? beneficiaryPhone : requesterPhone,
      status: 'Confirmée',
    );
    _HistoryRepository.addReservation(reservation);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _GeneratedTicketPage(reservation: reservation),
      ),
    );
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
                        onPressed: _finishReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fofanaGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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
      builder: (_) => _PaymentMethodSheet(total: _reservation.price),
    );
  }

  void _editReservation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: _reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          setState(() => _reservation = updated);
        },
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await _showCancelReservationDialog(context);
    if (shouldCancel != true) return;

    _HistoryRepository.removeReservation(_reservation.reference);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée.')));
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
                      primaryActionLabel: 'Effectuer le règlement',
                      onPrimaryAction: _showPaymentSheet,
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

class _PaymentMethodSheet extends StatefulWidget {
  final String total;

  const _PaymentMethodSheet({required this.total});

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  String? _selectedMethod;

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
            const SizedBox(height: 24),
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE1E4EC)),
              ),
              child: const Row(
                children: [
                  Text('🇧🇯', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text(
                    'Benin',
                    style: TextStyle(
                      color: _deepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              value: 'moov',
              selectedValue: _selectedMethod,
              imagePath: 'assets/images/logo_moov.png',
              onTap: () => setState(() => _selectedMethod = 'moov'),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              value: 'mtn',
              selectedValue: _selectedMethod,
              imagePath: 'assets/images/logo_mtn.png',
              onTap: () => setState(() => _selectedMethod = 'mtn'),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              value: 'celtiis',
              selectedValue: _selectedMethod,
              imagePath: 'assets/images/logo_celtiis.png',
              onTap: () => setState(() => _selectedMethod = 'celtiis'),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _selectedMethod == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Paiement ${widget.total} lancé avec ${_selectedMethod!.toUpperCase()}.',
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _fofanaGreen,
                  disabledBackgroundColor: const Color(0xFFFFBE9D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String imagePath;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.value,
    required this.selectedValue,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A34A)
                : const Color(0xFFE1E4EC),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD8DCE6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const Spacer(),
            Image.asset(imagePath, width: 104, height: 58, fit: BoxFit.contain),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _EditReservationSheet extends StatefulWidget {
  final _ReservationItem reservation;
  final ValueChanged<_ReservationItem> onSave;

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

  void _save() {
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

    widget.onSave(
      widget.reservation.copyWith(
        departure: _departureController.text.trim(),
        destination: _destinationController.text.trim(),
        date: _dateController.text.trim(),
        passengerCount: _passengerCount,
        beneficiaryName: _beneficiaryController.text.trim(),
        beneficiaryPhone: _phoneController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
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
