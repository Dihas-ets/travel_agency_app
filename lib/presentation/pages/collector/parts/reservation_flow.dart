part of '../collector_home_page.dart';

// Reservation percepteur: donnees, formulaire, paiement, billet et presence.

class _CollectorCityPosition {
  final double latitude;
  final double longitude;

  const _CollectorCityPosition(this.latitude, this.longitude);
}

const Map<String, _CollectorCityPosition> _collectorCityPositions = {
  'Abomey': _CollectorCityPosition(7.1829, 1.9912),
  'Abomey-Calavi': _CollectorCityPosition(6.4485, 2.3557),
  'Adjohoun': _CollectorCityPosition(6.7167, 2.4833),
  'Allada': _CollectorCityPosition(6.6655, 2.1514),
  'Aplahoué': _CollectorCityPosition(6.9333, 1.6833),
  'Banikoara': _CollectorCityPosition(11.2985, 2.4386),
  'Bassila': _CollectorCityPosition(9.0081, 1.6654),
  'Bembèrèkè': _CollectorCityPosition(10.2283, 2.6633),
  'Bétérou': _CollectorCityPosition(9.1992, 2.2586),
  'Bohicon': _CollectorCityPosition(7.1783, 2.0667),
  'Cotonou': _CollectorCityPosition(6.3703, 2.3912),
  'Dassa-Zoumè': _CollectorCityPosition(7.75, 2.1833),
  'Djougou': _CollectorCityPosition(9.7085, 1.6659),
  'Kandi': _CollectorCityPosition(11.1342, 2.9386),
  'Lokossa': _CollectorCityPosition(6.6387, 1.7167),
  'Natitingou': _CollectorCityPosition(10.3042, 1.3796),
  'Ouidah': _CollectorCityPosition(6.3631, 2.0851),
  'Parakou': _CollectorCityPosition(9.3372, 2.6303),
  'Porto-Novo': _CollectorCityPosition(6.4969, 2.6289),
  'Sakété': _CollectorCityPosition(6.7362, 2.6587),
  'Savalou': _CollectorCityPosition(7.9281, 1.9756),
  'Sèmè-Kpodji': _CollectorCityPosition(6.3654, 2.6161),
  'Tchaourou': _CollectorCityPosition(8.8865, 2.5975),
};

class _CollectorReservationRecord {
  final String reference;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String passengerName;
  final String phone;
  final String price;
  final String busMatricule;
  final String status;

  const _CollectorReservationRecord({
    required this.reference,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.passengerName,
    required this.phone,
    required this.price,
    required this.busMatricule,
    required this.status,
  });

  _CollectorReservationRecord copyWith({String? status, String? busMatricule}) {
    return _CollectorReservationRecord(
      reference: reference,
      departure: departure,
      destination: destination,
      date: date,
      time: time,
      passengerCount: passengerCount,
      passengerName: passengerName,
      phone: phone,
      price: price,
      busMatricule: busMatricule ?? this.busMatricule,
      status: status ?? this.status,
    );
  }
}

class _CollectorReservationStore {
  static final List<_CollectorReservationRecord> reservations = [];
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static _CollectorReservationRecord? get activeReservation {
    if (reservations.isEmpty) return null;
    return reservations.first;
  }

  static List<_CollectorReservationRecord> get historicalReservations {
    if (reservations.length <= 1) return [];
    return reservations.skip(1).toList();
  }

  static void add(_CollectorReservationRecord reservation) {
    reservations.insert(0, reservation);
    version.value += 1;
  }
}

class _CollectorReservationPage extends StatefulWidget {
  const _CollectorReservationPage();

  @override
  State<_CollectorReservationPage> createState() =>
      _CollectorReservationPageState();
}

class _CollectorReservationPageState extends State<_CollectorReservationPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _departController = TextEditingController(
    text: 'Cotonou',
  );
  final TextEditingController _destinationController = TextEditingController(
    text: 'Porto-Novo',
  );
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _passengerCount = 1;
  DateTime? _travelDate;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _syncFareAmount();
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int get _fare {
    final distance = _routeDistanceKm(
      _departController.text.trim(),
      _destinationController.text.trim(),
    );
    final base = 900;
    final perPassenger = (base + distance * 95).round();
    final roundedFare = ((perPassenger / 100).ceil() * 100)
        .clamp(1200, 65000)
        .toInt();
    return roundedFare * _passengerCount;
  }

  void _syncFareAmount() {
    _amountController.text = _formatAmount(_fare);
  }

  int _currentAmount() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? _fare;
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

  double _routeDistanceKm(String departure, String destination) {
    final from = _positionFor(departure);
    final to = _positionFor(destination);
    if (from == null || to == null) {
      final seed = departure.length * 17 + destination.length * 31;
      return 35 + (seed % 420).toDouble();
    }

    return _distanceKm(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  _CollectorCityPosition? _positionFor(String city) {
    if (city.startsWith('Ma position') && _currentPosition != null) {
      return _CollectorCityPosition(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
    return _collectorCityPositions[city];
  }

  double _distanceKm(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(latitudeB - latitudeA);
    final dLon = _degreesToRadians(longitudeB - longitudeA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(latitudeA)) *
            math.cos(_degreesToRadians(latitudeB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  Future<void> _useCurrentLocation(TextEditingController controller) async {
    Navigator.pop(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activez la localisation pour utiliser Ma position.'),
            backgroundColor: _fofanaGreen,
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission de localisation refusée.'),
            backgroundColor: _fofanaGreen,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        controller.text =
            'Ma position (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})';
        _syncFareAmount();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer la position actuelle.'),
          backgroundColor: _fofanaGreen,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
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

    if (date == null) return;
    setState(() {
      _travelDate = date;
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
    });
  }

  void _showCityPicker({
    required String title,
    required TextEditingController controller,
    bool includeCurrentLocation = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    itemCount:
                        _collectorBeninCities.length +
                        (includeCurrentLocation ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (includeCurrentLocation && index == 0) {
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            leading: const Icon(
                              Icons.my_location_rounded,
                              color: _fofanaGreen,
                            ),
                            title: const Text(
                              'Ma position',
                              style: TextStyle(
                                color: _deepBlue,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            onTap: () => _useCurrentLocation(controller),
                          ),
                        );
                      }

                      final cityIndex = includeCurrentLocation
                          ? index - 1
                          : index;
                      final city = _collectorBeninCities[cityIndex];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: _fofanaGreen,
                          ),
                          title: Text(
                            city,
                            style: const TextStyle(
                              color: _deepBlue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              controller.text = city;
                              _syncFareAmount();
                            });
                            Navigator.pop(context);
                          },
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

  void _switchLocations() {
    final first = _departController.text;
    setState(() {
      _departController.text = _destinationController.text;
      _destinationController.text = first;
      _syncFareAmount();
    });
  }

  Future<void> _confirmReservation() async {
    if (_departController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _travelDate == null) {
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
        builder: (_) => _CollectorPaymentDetailsPage(
          departure: _departController.text.trim(),
          destination: _destinationController.text.trim(),
          date:
              '${_travelDate!.day.toString().padLeft(2, '0')} ${_monthName(_travelDate!.month)} ${_travelDate!.year}',
          priceAmount: _currentAmount(),
          passengers: _passengerCount,
          time: '10:00',
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  String _monthName(int month) {
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
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/coli1.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0x99060E27),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.vertical(
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
                        child: _CollectorHeaderIconButton(
                          icon: Icons.arrow_back_rounded,
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
                  Container(
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
                      'Réservation percepteur',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReservationForm(),
                    const SizedBox(height: 18),
                    if (_CollectorReservationStore.reservations.isNotEmpty)
                      ..._CollectorReservationStore.reservations.map(
                        (item) => _CollectorReservationCard(item: item),
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
                    _CollectorCityField(
                      controller: _departController,
                      label: 'De',
                      hint: 'Ville de départ',
                      isFirst: true,
                      onTap: () => _showCityPicker(
                        title: 'Choisir la ville de départ',
                        controller: _departController,
                        includeCurrentLocation: true,
                      ),
                    ),
                    _CollectorCityField(
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
          _CollectorSmallField(
            label: 'Date de départ',
            value: _dateController.text.isEmpty
                ? 'Sélectionner une date'
                : _dateController.text,
            icon: Icons.calendar_month_rounded,
            onTap: _pickDate,
          ),
          const SizedBox(height: 14),
          if (_destinationController.text.isNotEmpty) ...[
            _CollectorTextInput(
              controller: _amountController,
              label: 'Montant',
              icon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
              suffixText: 'CFA',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 14),
          ],
          _CollectorPassengerCard(
            count: _passengerCount,
            onMinus: () {
              if (_passengerCount > 1) {
                setState(() {
                  _passengerCount -= 1;
                  _syncFareAmount();
                });
              }
            },
            onPlus: () {
              if (_passengerCount < 8) {
                setState(() {
                  _passengerCount += 1;
                  _syncFareAmount();
                });
              }
            },
          ),
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
}

class _CollectorCityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isFirst;
  final VoidCallback onTap;

  const _CollectorCityField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 68, 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: isFirst
                ? BorderSide(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF16A34A),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorSmallField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorSmallField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(icon, size: 18, color: deepBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 14.5,
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
}

class _CollectorPassengerCard extends StatelessWidget {
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _CollectorPassengerCard({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: deepBlue, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          _CollectorStepperButton(icon: Icons.remove, onTap: onMinus),
          const SizedBox(width: 10),
          Text(
            '$count',
            style: const TextStyle(
              color: deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          _CollectorStepperButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _CollectorStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorStepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.18),
          ),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF0B4F2A)),
      ),
    );
  }
}

class _CollectorPaymentDetailsPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final int priceAmount;
  final int passengers;
  final String time;

  const _CollectorPaymentDetailsPage({
    required this.departure,
    required this.destination,
    required this.date,
    required this.priceAmount,
    required this.passengers,
    this.time = '10:00',
  });

  @override
  State<_CollectorPaymentDetailsPage> createState() =>
      _CollectorPaymentDetailsPageState();
}

class _CollectorPaymentDetailsPageState
    extends State<_CollectorPaymentDetailsPage> {
  final TextEditingController _requesterPhoneController =
      TextEditingController();
  final TextEditingController _passengerNameController =
      TextEditingController();

  @override
  void dispose() {
    _requesterPhoneController.dispose();
    _passengerNameController.dispose();
    super.dispose();
  }

  void _finishReservation() {
    final phone = _requesterPhoneController.text.trim();
    final passenger = _passengerNameController.text.trim();

    if (phone.isEmpty || passenger.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter les informations.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CollectorPaymentChoicePage(
          reservation: _buildReservation(
            passengerName: passenger,
            phone: phone,
            status: 'En attente paiement',
          ),
          priceAmount: widget.priceAmount,
        ),
      ),
    );
  }

  _CollectorReservationRecord _buildReservation({
    required String passengerName,
    required String phone,
    required String status,
  }) {
    return _CollectorReservationRecord(
      reference: 'TB${DateTime.now().millisecondsSinceEpoch}',
      departure: widget.departure,
      destination: widget.destination,
      date: widget.date,
      time: widget.time,
      passengerCount: widget.passengers,
      passengerName: passengerName,
      phone: phone,
      price: '${_formatAmount(widget.priceAmount)} CFA',
      busMatricule: _generateBusMatricule(widget.departure, widget.destination),
      status: status,
    );
  }

  String _generateBusMatricule(String departure, String destination) {
    final routeKey =
        '${departure.trim().replaceAll(RegExp(r"[^A-Za-z0-9]"), '').toUpperCase()}_${destination.trim().replaceAll(RegExp(r"[^A-Za-z0-9]"), '').toUpperCase()}';
    final hash = routeKey.hashCode.abs() % 9000 + 1000;
    final suffix = routeKey.length >= 2
        ? routeKey.substring(0, 2)
        : routeKey.padRight(2, 'X');
    return 'BJ-$hash-$suffix';
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
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Confirmation',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectorTripSummaryCard(
                departure: widget.departure,
                destination: widget.destination,
                date: widget.date,
                time: widget.time,
                passengerCount: widget.passengers,
                price: '${_formatAmount(widget.priceAmount)} CFA',
              ),
              const SizedBox(height: 16),
              _CollectorTextInput(
                controller: _passengerNameController,
                label: 'Nom du passager',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              _CollectorTextInput(
                controller: _requesterPhoneController,
                label: 'Téléphone du demandeur',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _finishReservation,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Confirmer la réservation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
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

class _CollectorPaymentChoicePage extends StatefulWidget {
  final _CollectorReservationRecord reservation;
  final int priceAmount;

  const _CollectorPaymentChoicePage({
    required this.reservation,
    required this.priceAmount,
  });

  @override
  State<_CollectorPaymentChoicePage> createState() =>
      _CollectorPaymentChoicePageState();
}

class _CollectorPaymentChoicePageState
    extends State<_CollectorPaymentChoicePage> {
  String _mode = 'cash';
  String? _method;
  final TextEditingController _clientCodeController = TextEditingController();
  bool _paymentRequestSent = false;

  static const Color _deepBlue = Color(0xFF0B4F2A);

  @override
  void dispose() {
    _clientCodeController.dispose();
    super.dispose();
  }

  void _confirmCash() {
    _completeReservation('Confirmée - Cash');
  }

  void _sendPaymentRequest() {
    if (_method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une méthode de paiement.')),
      );
      return;
    }

    setState(() => _paymentRequestSent = true);
    _CollectorNotificationStore.add(
      title: 'Demande de paiement',
      message:
          'Demande envoyée au ${widget.reservation.phone} via ${_methodLabel(_method!)}.',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demande envoyée au ${widget.reservation.phone}. Le client peut saisir son code.',
        ),
        backgroundColor: _deepBlue,
      ),
    );
  }

  void _confirmRemotePayment() {
    if (!_paymentRequestSent || _clientCodeController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez envoyer la demande puis saisir le code client.',
          ),
        ),
      );
      return;
    }

    _completeReservation('Confirmée - ${_methodLabel(_method!)}');
  }

  void _completeReservation(String status) {
    final reservation = widget.reservation.copyWith(status: status);
    _CollectorReservationStore.add(reservation);
    _CollectorNotificationStore.add(
      title: 'Réservation confirmée',
      message:
          '${reservation.passengerName} - ${reservation.departure} vers ${reservation.destination}.',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _CollectorGeneratedTicketPage(reservation: reservation),
      ),
    );
  }

  String _methodLabel(String value) {
    switch (value) {
      case 'moov':
        return 'Moov';
      case 'celtiis':
        return 'Celtiis';
      case 'mtn':
        return 'MTN';
      case 'wave':
        return 'Wave';
      case 'card':
        return 'Carte bancaire';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectorTripSummaryCard(
                departure: widget.reservation.departure,
                destination: widget.reservation.destination,
                date: widget.reservation.date,
                time: widget.reservation.time,
                passengerCount: widget.reservation.passengerCount,
                price: widget.reservation.price,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Mode de règlement',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _CollectorModeButton(
                            label: 'Cash',
                            icon: Icons.payments_rounded,
                            selected: _mode == 'cash',
                            onTap: () => setState(() => _mode = 'cash'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CollectorModeButton(
                            label: 'Autre paiement',
                            icon: Icons.phone_android_rounded,
                            selected: _mode == 'remote',
                            onTap: () => setState(() => _mode = 'remote'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_mode == 'cash')
                      _CollectorCashPaymentPanel(onConfirm: _confirmCash)
                    else
                      _CollectorRemotePaymentPanel(
                        selectedMethod: _method,
                        requestSent: _paymentRequestSent,
                        clientCodeController: _clientCodeController,
                        onMethodTap: (method) => setState(() {
                          _method = method;
                          _paymentRequestSent = false;
                          _clientCodeController.clear();
                        }),
                        onSendRequest: _sendPaymentRequest,
                        onConfirmPayment: _confirmRemotePayment,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectorModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CollectorModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16A34A) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF16A34A)
                : const Color(0xFF0B4F2A).withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF0B4F2A),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF0B4F2A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorCashPaymentPanel extends StatelessWidget {
  final VoidCallback onConfirm;

  const _CollectorCashPaymentPanel({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            "Le percepteur reçoit directement l'argent du client puis confirme la réservation.",
            style: TextStyle(
              color: Color(0xFF5F6B86),
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Confirmer le paiement cash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectorRemotePaymentPanel extends StatelessWidget {
  final String? selectedMethod;
  final bool requestSent;
  final TextEditingController clientCodeController;
  final ValueChanged<String> onMethodTap;
  final VoidCallback onSendRequest;
  final VoidCallback onConfirmPayment;

  const _CollectorRemotePaymentPanel({
    required this.selectedMethod,
    required this.requestSent,
    required this.clientCodeController,
    required this.onMethodTap,
    required this.onSendRequest,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    const methods = [
      ('moov', 'Moov', 'assets/images/logo_moov.png'),
      ('celtiis', 'Celtiis', 'assets/images/logo_celtiis.png'),
      ('mtn', 'MTN', 'assets/images/logo_mtn.png'),
      ('wave', 'Wave', null),
      ('card', 'Carte bancaire', 'assets/images/logo_carte.png'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.3,
          children: methods.map((method) {
            return _CollectorPaymentMethodTile(
              value: method.$1,
              label: method.$2,
              imagePath: method.$3,
              selected: selectedMethod == method.$1,
              onTap: () => onMethodTap(method.$1),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onSendRequest,
            icon: const Icon(Icons.send_to_mobile_rounded),
            label: const Text('Envoyer la demande au client'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B4F2A),
              side: BorderSide(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        if (requestSent) ...[
          const SizedBox(height: 14),
          TextField(
            controller: clientCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              counterText: '',
              labelText: 'Code reçu par le client',
              prefixIcon: const Icon(
                Icons.password_rounded,
                color: Color(0xFF16A34A),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FBFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onConfirmPayment,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Valider le paiement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CollectorPaymentMethodTile extends StatelessWidget {
  final String value;
  final String label;
  final String? imagePath;
  final bool selected;
  final VoidCallback onTap;

  const _CollectorPaymentMethodTile({
    required this.value,
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7EF) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF16A34A)
                : const Color(0xFF0B4F2A).withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _methodIcon(),
              )
            else
              _methodIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodIcon() {
    final icon = value == 'wave'
        ? Icons.waves_rounded
        : Icons.credit_card_rounded;

    return Icon(icon, color: const Color(0xFF16A34A), size: 28);
  }
}

class _CollectorTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;

  const _CollectorTextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.suffixText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: Color(0xFF0B4F2A),
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        prefixIcon: Icon(icon, color: const Color(0xFF16A34A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CollectorTripSummaryCard extends StatelessWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String price;

  const _CollectorTripSummaryCard({
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const Text(
            'Résumé du voyage',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _TicketInfoRow(title: 'Trajet', value: '$departure -> $destination'),
          _TicketInfoRow(title: 'Départ', value: '$date à $time'),
          _TicketInfoRow(title: 'Passagers', value: '$passengerCount'),
          _TicketInfoRow(title: 'Total', value: price),
        ],
      ),
    );
  }
}

class _CollectorGeneratedTicketPage extends StatelessWidget {
  final _CollectorReservationRecord reservation;

  const _CollectorGeneratedTicketPage({required this.reservation});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await _buildTicketPdf();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'ticket_fofana_${reservation.reference}.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de générer le PDF du ticket.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<Uint8List> _buildTicketPdf() async {
    final pdf = pw.Document();
    final deepBlue = PdfColor.fromHex('#0B4F2A');
    final red = PdfColor.fromHex('#16A34A');
    final light = PdfColor.fromHex('#F8FBFF');
    final muted = PdfColor.fromHex('#687089');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#E6EAF2')),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Fofana',
                      style: pw.TextStyle(
                        color: deepBlue,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: light,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        reservation.status,
                        style: pw.TextStyle(
                          color: red,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 28),
                _pdfRow('Passager', reservation.passengerName, deepBlue, muted),
                _pdfRow('Telephone', reservation.phone, deepBlue, muted),
                _pdfRow(
                  'Trajet',
                  '${reservation.departure} -> ${reservation.destination}',
                  deepBlue,
                  muted,
                ),
                _pdfRow(
                  'Depart',
                  '${reservation.date} a ${reservation.time}',
                  deepBlue,
                  muted,
                ),
                _pdfRow(
                  'Passagers',
                  '${reservation.passengerCount}',
                  deepBlue,
                  muted,
                ),
                _pdfRow('Montant', reservation.price, deepBlue, muted),
                pw.Spacer(),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        reservation.reference,
                        style: pw.TextStyle(
                          color: deepBlue,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: reservation.reference,
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(
    String title,
    String value,
    PdfColor deepBlue,
    PdfColor muted,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: deepBlue,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Billet généré',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectorReservationCard(item: reservation),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Code QR du billet',
                      style: TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    QrImageView(
                      data: reservation.reference,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reservation.reference,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Télécharger en PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Retour à la réservation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B4F2A),
                    side: BorderSide(
                      color: const Color(0xFF0B4F2A).withValues(alpha: 0.24),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
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

class _CollectorReservationCard extends StatelessWidget {
  final _CollectorReservationRecord item;

  const _CollectorReservationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.reference,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                item.status,
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TicketInfoRow(
            title: 'Trajet',
            value: '${item.departure} -> ${item.destination}',
          ),
          _TicketInfoRow(title: 'Départ', value: '${item.date} à ${item.time}'),
          _TicketInfoRow(title: 'Passager', value: item.passengerName),
          _TicketInfoRow(title: 'Téléphone', value: item.phone),
          _TicketInfoRow(title: 'Total', value: item.price),
        ],
      ),
    );
  }
}

class _CollectorAttendanceList extends StatelessWidget {
  final String title;
  final String emptyMessage;

  const _CollectorAttendanceList({
    required this.title,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [_CollectorEmptyCard(title: title, message: emptyMessage)],
    );
  }
}

class _CollectorEmptyCard extends StatelessWidget {
  final String title;
  final String message;

  const _CollectorEmptyCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

