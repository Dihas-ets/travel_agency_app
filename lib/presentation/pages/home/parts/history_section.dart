part of '../home_page.dart';

// Historique client: reservations, billets et composants visuels associes.

enum _HistoryScope { reservations, tickets }

class _HistoryPage extends StatefulWidget {
  const _HistoryPage();

  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  _HistoryScope _scope = _HistoryScope.reservations;

  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  List<_ReservationItem> get _reservations => _HistoryRepository.reservations;
  List<_TicketItem> get _tickets => _HistoryRepository.tickets;

  Future<void> _openReservationTicket(_ReservationItem reservation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReservationTicketPage(reservation: reservation),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Menu non disponible sur cette page',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_fofana_no_background.png',
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _HeaderIconButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Aucune notification'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      const _NewsSection(),
                      const SizedBox(height: 18),
                      _buildScopeSwitcher(),
                      const SizedBox(height: 18),
                      if (_scope == _HistoryScope.reservations)
                        _buildReservationSection()
                      else
                        _buildTicketSection(),
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

  Widget _buildScopeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Row(
        children: [
          _buildScopeButton(
            label: 'Mes réservations',
            selected: _scope == _HistoryScope.reservations,
            onTap: () => setState(() => _scope = _HistoryScope.reservations),
          ),
          _buildScopeButton(
            label: 'Mes billets',
            selected: _scope == _HistoryScope.tickets,
            onTap: () => setState(() => _scope = _HistoryScope.tickets),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? _fofanaGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : _deepBlue,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mes réservations',
          style: TextStyle(
            color: _deepBlue,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        if (_reservations.isEmpty)
          _buildEmptyState(
            title: 'Aucune réservation pour le moment',
            message: 'Réservez un trajet pour retrouver vos réservations ici.',
          )
        else
          ..._reservations.map(
            (item) => _ReservationCard(
              item: item,
              onTicketNow: () => _openReservationTicket(item),
            ),
          ),
      ],
    );
  }

  Widget _buildTicketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mes billets',
          style: TextStyle(
            color: _deepBlue,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        if (_tickets.isEmpty)
          _buildEmptyState(
            title: 'Aucun billet disponible',
            message: 'Vos billets apparaîtront ici après une réservation.',
          )
        else
          ..._tickets.map(
            (item) => _TicketCard(item: item, onChanged: () => setState(() {})),
          ),
      ],
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _deepBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: _deepBlue.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationItem {
  final String reference;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final String seat;
  final String price;
  final int passengerCount;
  final String beneficiaryName;
  final String requesterPhone;
  final String beneficiaryPhone;
  final String status;

  const _ReservationItem({
    required this.reference,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.seat,
    required this.price,
    required this.passengerCount,
    required this.beneficiaryName,
    required this.requesterPhone,
    required this.beneficiaryPhone,
    required this.status,
  });

  String get route => '$departure → $destination';

  _ReservationItem copyWith({
    String? departure,
    String? destination,
    String? date,
    String? time,
    String? seat,
    String? price,
    int? passengerCount,
    String? beneficiaryName,
    String? requesterPhone,
    String? beneficiaryPhone,
    String? status,
  }) {
    return _ReservationItem(
      reference: reference,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      time: time ?? this.time,
      seat: seat ?? this.seat,
      price: price ?? this.price,
      passengerCount: passengerCount ?? this.passengerCount,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      beneficiaryPhone: beneficiaryPhone ?? this.beneficiaryPhone,
      status: status ?? this.status,
    );
  }
}

class _TicketItem {
  final String code;
  final String departure;
  final String destination;
  final String passenger;
  final int passengerCount;
  final int ticketIndex;
  final String date;
  final String time;
  final String seat;
  final String price;
  final String reference;
  final String gate;

  const _TicketItem({
    required this.code,
    required this.departure,
    required this.destination,
    required this.passenger,
    required this.passengerCount,
    required this.ticketIndex,
    required this.date,
    required this.time,
    required this.seat,
    required this.price,
    required this.reference,
    required this.gate,
  });

  String get route => '$departure → $destination';
}

class _ReservationCard extends StatelessWidget {
  final _ReservationItem item;
  final VoidCallback? onTicketNow;

  const _ReservationCard({required this.item, this.onTicketNow});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF16A34A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.route,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Réf. ${item.reference}',
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HistoryInfoChip(
                  label: item.date,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HistoryInfoChip(
                  label: item.time,
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HistoryInfoChip(
                  label: item.seat,
                  icon: Icons.event_seat_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.price,
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                item.route,
                style: const TextStyle(
                  color: Color(0xFF5F6B86),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          if (onTicketNow != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTicketNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Billet maintenant',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTicketNow == null) return card;

    return InkWell(
      onTap: onTicketNow,
      borderRadius: BorderRadius.circular(22),
      child: card,
    );
  }
}

class _ReservationTicketPage extends StatefulWidget {
  final _ReservationItem reservation;

  const _ReservationTicketPage({required this.reservation});

  @override
  State<_ReservationTicketPage> createState() => _ReservationTicketPageState();
}

class _ReservationTicketPageState extends State<_ReservationTicketPage> {
  late _ReservationItem _reservation;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
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

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodSheet(total: _reservation.price),
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
              'Billet',
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

class _ReprogramPage extends StatefulWidget {
  const _ReprogramPage();

  @override
  State<_ReprogramPage> createState() => _ReprogramPageState();
}

class _ReprogramPageState extends State<_ReprogramPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _ticketNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isForSomeoneElse = false;
  _TicketItem? _foundTicket;
  String? _searchMessage;

  @override
  void dispose() {
    _ticketNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  _TicketItem? _findTicket(String rawNumber) {
    final query = _normalize(rawNumber);
    final queryDigits = _digitsOnly(rawNumber);
    if (query.isEmpty) return null;

    for (final ticket in _HistoryRepository.tickets) {
      final ticketNumber = '${ticket.reference}${ticket.ticketIndex}';
      final candidates = <String>[
        ticket.code,
        '${ticket.code}${ticket.ticketIndex}',
        ticket.reference,
        ticketNumber,
      ];

      final hasMatch = candidates.any((candidate) {
        return _normalize(candidate) == query ||
            (queryDigits.isNotEmpty && _digitsOnly(candidate) == queryDigits);
      });
      if (hasMatch) return ticket;
    }
    return null;
  }

  void _searchTicket() {
    final ticketNumber = _ticketNumberController.text.trim();
    final phone = _phoneController.text.trim();

    if (ticketNumber.isEmpty) {
      setState(() {
        _foundTicket = null;
        _searchMessage = 'Veuillez saisir le numéro du billet.';
      });
      return;
    }

    if (_isForSomeoneElse && phone.isEmpty) {
      setState(() {
        _foundTicket = null;
        _searchMessage = 'Veuillez saisir le numéro de téléphone.';
      });
      return;
    }

    final ticket = _findTicket(ticketNumber);
    setState(() {
      _foundTicket = ticket;
      _searchMessage = ticket == null ? 'Aucun billet trouvé.' : null;
    });
  }

  void _editFoundTicket() {
    final ticket = _foundTicket;
    if (ticket == null) return;

    final reservation = _HistoryRepository.reservations.firstWhere(
      (item) => item.reference == ticket.reference,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          setState(() {
            _foundTicket = _findTicket(_ticketNumberController.text.trim());
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Reprogrammation',
              style: TextStyle(
                color: _deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _deepBlue.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReprogramTextField(
                            controller: _ticketNumberController,
                            label: 'Numéro du billet',
                            hint: 'Ex: 17600000000001',
                            icon: Icons.confirmation_number_rounded,
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () => setState(
                              () => _isForSomeoneElse = !_isForSomeoneElse,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FBFF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _deepBlue.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _isForSomeoneElse,
                                    activeColor: _fofanaGreen,
                                    onChanged: (value) => setState(
                                      () => _isForSomeoneElse = value ?? false,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Reprogrammer pour quelqu’un',
                                      style: TextStyle(
                                        color: _deepBlue,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isForSomeoneElse) ...[
                            const SizedBox(height: 14),
                            PhoneLoginField(controller: _phoneController),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _searchTicket,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _fofanaGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Rechercher',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_searchMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _searchMessage!,
                        style: const TextStyle(
                          color: _fofanaGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (_foundTicket != null) ...[
                      const SizedBox(height: 18),
                      _TicketVisual(
                        departure: _foundTicket!.departure,
                        destination: _foundTicket!.destination,
                        date: _foundTicket!.date,
                        time: _foundTicket!.time,
                        passengerCount: _foundTicket!.passengerCount,
                        ticketIndex: _foundTicket!.ticketIndex,
                        beneficiaryName: _foundTicket!.passenger,
                        total: _foundTicket!.price,
                        reference: _foundTicket!.reference,
                        primaryActionLabel: '',
                        onEdit: _editFoundTicket,
                        showPrimaryAction: false,
                        showCancelAction: false,
                        editActionLabel: 'Modifier',
                      ),
                    ],
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

class _ReprogramTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _ReprogramTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: deepBlue),
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        labelStyle: const TextStyle(
          color: deepBlue,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9AA3B8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: deepBlue.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final _TicketItem item;
  final VoidCallback onChanged;

  const _TicketCard({required this.item, required this.onChanged});

  void _editReservation(BuildContext context) {
    final reservation = _HistoryRepository.reservations.firstWhere(
      (item) => item.reference == this.item.reference,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          onChanged();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _TicketVisual(
        departure: item.departure,
        destination: item.destination,
        date: item.date,
        time: item.time,
        passengerCount: item.passengerCount,
        ticketIndex: item.ticketIndex,
        beneficiaryName: item.passenger,
        total: item.price,
        reference: item.reference,
        primaryActionLabel: '',
        onEdit: () => _editReservation(context),
        compact: true,
        showPrimaryAction: false,
        showCancelAction: false,
        editActionLabel: 'Modifier',
      ),
    );
  }
}

class _TicketVisual extends StatelessWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String beneficiaryName;
  final String total;
  final String reference;
  final String primaryActionLabel;
  final int ticketIndex;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final bool compact;
  final bool showPrimaryAction;
  final bool showCancelAction;
  final String? editActionLabel;

  const _TicketVisual({
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.beneficiaryName,
    required this.total,
    required this.reference,
    required this.primaryActionLabel,
    required this.ticketIndex,
    this.onPrimaryAction,
    this.onEdit,
    this.onCancel,
    this.compact = false,
    this.showPrimaryAction = true,
    this.showCancelAction = true,
    this.editActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    const muted = Color(0xFF9AA3B8);

    return Container(
      padding: EdgeInsets.fromLTRB(20, compact ? 22 : 28, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: deepBlue.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TicketRouteCity(label: 'De', city: departure),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: muted.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 1.5,
                        color: muted.withValues(alpha: 0.35),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 1.5,
                        color: muted.withValues(alpha: 0.35),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: muted,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'N° $ticketIndex',
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TicketRouteCity(
                  label: 'À',
                  city: destination,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TicketInfoBlock(
                      label: 'Date de départ',
                      value: date,
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'Heure de départ',
                      value: time,
                      icon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'Bénéficiaire',
                      value: beneficiaryName,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TicketInfoBlock(
                      label: 'Nbr de places',
                      value: 'x$passengerCount',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'N° de billet',
                      value: '#${reference.replaceAll(RegExp(r'[^0-9]'), '')}',
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: Color(0xFF99A4C0)),
                        SizedBox(width: 8),
                        Icon(Icons.ac_unit_rounded, color: Color(0xFF99A4C0)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'Total',
                      value: total,
                      valueColor: red,
                      valueSize: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _TicketQrCode(
            data: '$reference-$ticketIndex-$departure-$destination',
          ),
          const SizedBox(height: 20),
          Divider(color: deepBlue.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 20),
          if (showPrimaryAction) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  disabledBackgroundColor: red.withValues(alpha: 0.82),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  primaryActionLabel,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (showCancelAction)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Annuler ma réservation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: deepBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.edit_rounded, color: red, size: 27),
                  ),
                ),
              ],
            )
          else if (onEdit != null)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 21),
                label: Text(
                  editActionLabel ?? 'Modifier',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _TicketRouteCity extends StatelessWidget {
  final String label;
  final String city;
  final bool alignEnd;

  const _TicketRouteCity({
    required this.label,
    required this.city,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFADB4C4),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TicketInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color valueColor;
  final double valueSize;

  const _TicketInfoBlock({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor = const Color(0xFF0B4F2A),
    this.valueSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA6ADBE),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFD67A3A), size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: valueSize,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TicketQrCode extends StatelessWidget {
  final String data;

  const _TicketQrCode({required this.data});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0B4F2A);

    return Center(
      child: Container(
        width: 118,
        height: 118,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dark.withValues(alpha: 0.12)),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: dark),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: dark,
          ),
        ),
      ),
    );
  }
}

class _HistoryInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HistoryInfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF5F6B86)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

