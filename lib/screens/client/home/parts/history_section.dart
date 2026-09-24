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
  String _ticketStatus = 'passé';
  bool _isLoading = true;
  String? _loadError;

  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  List<_ReservationItem> _reservations = [];
  List<_ReservationItem> _allTickets = [];

  List<_ReservationItem> get _tickets => _allTickets
      .where((item) => _normalizedStatus(item.status) == _ticketStatus)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  String _normalizedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'en_cours' ||
        normalized == 'en cours' ||
        normalized == 'encours') {
      return 'en_cours';
    }
    if (normalized.contains('attente')) return 'en_attente';
    if (normalized.contains('annul')) return 'annulé';
    if (normalized.contains('pass')) return 'passé';
    if (normalized.contains('termin')) return 'terminé';
    if (normalized == 'passe') return 'passé';
    if (normalized == 'annule') return 'annulé';
    if (normalized.contains('utilis')) return 'passé'; //
    return 'en_cours';
  }

  _ReservationItem _itemFromJson(Map<String, dynamic> json) {
    final ligne = json['ligne'] as Map<String, dynamic>?;
    final paymentStatus = _normalizeStatusValue(json['statut_paiement']);
    
    final ticketStatus = _normalizedStatus(
      json['statut']?.toString() ?? 'en_cours',
    );
    final mecef = json['mecef_response'] is Map
        ? Map<String, dynamic>.from(json['mecef_response'] as Map)
        : const <String, dynamic>{};
    return _ReservationItem(
      ticketId: int.tryParse(json['id']?.toString() ?? ''),
      voyageId: int.tryParse(json['voyage_id']?.toString() ?? ''),
      reference: json['reference']?.toString() ?? '',
      departure: ligne?['trajet_depart']?.toString() ?? '',
      destination: ligne?['trajet_arrivee']?.toString() ?? '',
      date: _formatTravelDate(json['date_voyage']?.toString() ?? ''),
      time: _formatTravelTime(json['heure_voyage']?.toString() ?? ''),
      seat: 'x${json['nbre_place'] ?? 1}',
      price: _formatMoney(json['tarif_total']),
      amountBase: _formatMoney(json['montant_base'] ?? json['tarif_total']),
      taxAmount: _formatMoney(json['montant_taxe'] ?? 0),
      taxRate: json['taxe_taux']?.toString() ?? '0',
      passengerCount: int.tryParse(json['nbre_place']?.toString() ?? '') ?? 1,
      beneficiaryName:
          '${json['prenom_passager'] ?? ''} ${json['nom_passager'] ?? ''}'.trim(),
      requesterPhone: json['numero_passager']?.toString() ?? '',
      beneficiaryPhone: json['numero_passager']?.toString() ?? '',
      issuerName: _issuerName(json['emetteur']),
      qrData: _isPaidPaymentStatus(paymentStatus)
          ? _mecefQrData(json['mecef_response'])
          : null,
      mecefCode: mecef['code_mecef']?.toString(),
      mecefNim: mecef['nim']?.toString(),
      mecefCounters: mecef['counters']?.toString(),
      mecefDate: mecef['date_mecef']?.toString(),
      isPaymentPending: paymentStatus != 'paye' &&
          paymentStatus != 'paid' &&
          paymentStatus != 'success' &&
          paymentStatus != 'successful',
      status: _isPaidPaymentStatus(paymentStatus)
          ? ticketStatus
          : 'en_attente',
    );
  }

  bool _isPaidPaymentStatus(String status) {
    return status == 'paye' ||
        status == 'paid' ||
        status == 'success' ||
        status == 'successful';
  }

  String? _mecefQrData(dynamic rawResponse) {
    if (rawResponse is! Map) return null;
    final response = Map<String, dynamic>.from(rawResponse);
    final status = _normalizeStatusValue(response['status']);
    if (status != 'confirmed') return null;
    final qrCode = response['qr_code']?.toString().trim();
    if (qrCode != null && qrCode.isNotEmpty && qrCode != 'null') {
      return qrCode;
    }
    final code = response['code_mecef']?.toString().trim();
    return code == null || code.isEmpty || code == 'null' ? null : code;
  }

  String _normalizeStatusValue(dynamic value) {
    return value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll(RegExp(r'[\s-]+'), '_') ??
        '';
  }

  String _formatMoney(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    final raw = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final parts = raw.split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)} ',
    );
    return '${parts.length == 1 ? grouped : '$grouped,${parts[1]}'} FCFA';
  }

  String _issuerName(dynamic value) {
    if (value is! Map) return '';
    final emetteur = Map<String, dynamic>.from(value);
    return '${emetteur['prenom'] ?? ''} ${emetteur['nom'] ?? ''}'.trim();
  }

  String _formatTravelDate(String value) {
    final raw = value.trim();
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (match != null) {
      return '${match.group(3)}/${match.group(2)}/${match.group(1)}';
    }
    final slashMatch = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(raw);
    if (slashMatch != null) {
      return '${slashMatch.group(1)!.padLeft(2, '0')}/${slashMatch.group(2)!.padLeft(2, '0')}/${slashMatch.group(3)}';
    }
    return raw;
  }

  String _formatTravelTime(String value) {
    final raw = value.trim();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match != null) {
      return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
    }
    final hourMatch = RegExp(r'^(\d{1,2})h(\d{0,2})$').firstMatch(raw);
    if (hourMatch != null) {
      return '${hourMatch.group(1)!.padLeft(2, '0')}:${(hourMatch.group(2)!.isEmpty ? '00' : hourMatch.group(2)!).padLeft(2, '0')}';
    }
    return raw;
  }

Future<void> _loadHistory({bool showLoader = true}) async {
  if (showLoader && mounted) {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
  }

  try {
    final rows = await TicketService().getHistoriqueClient();

    final items = rows
        .map(_itemFromJson)
        .where((item) => item.reference.isNotEmpty)
        .toList();

    if (!mounted) return;

    final reservations = items
        .where(
          (item) =>
              item.status == 'en_attente' ||
              item.status == 'en_cours',
        )
        .toList()
      ..sort(
        (a, b) => (a.status == 'en_attente' ? 1 : 0).compareTo(
          b.status == 'en_attente' ? 1 : 0,
        ),
      );

    setState(() {
      _allTickets = items;
      _reservations = reservations;
      _isLoading = false;
      _loadError = null;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _loadError = error.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
    });
  }
}



  Future<void> _openReservationTicket(_ReservationItem reservation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReservationTicketPage(reservation: reservation),
      ),
    );
    if (mounted) await _loadHistory();
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
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_loadError != null)
                        _buildEmptyState(
                          title: 'Historique indisponible',
                          message: _loadError!,
                        )
                      else if (_scope == _HistoryScope.reservations)
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
            (item) => _ReservationSummaryCard(
              item: item,
              onPay: item.isPaymentPending
                  ? () => _openReservationTicket(item)
                  : null,
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
        _buildStatusTabs(),
        const SizedBox(height: 14),
        if (_tickets.isEmpty)
          _buildEmptyState(
            title: 'Aucun billet dans cette catégorie',
            message: 'Les billets correspondants apparaîtront ici.',
          )
        else
          ..._tickets.map(
            (item) => _ReservationCard(
              item: item,
              onTicketNow: null,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusTabs() {
    const statuses = ['passé', 'annulé', 'terminé'];
    const labels = {
      'passé': 'Passé',
      'annulé': 'Annulé',
      'terminé': 'Terminé',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final selected = status == _ticketStatus;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[status]!),
              selected: selected,
              onSelected: (_) => setState(() => _ticketStatus = status),
              selectedColor: _fofanaGreen,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _deepBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
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
  final int? ticketId;
  final int? voyageId;
  final String reference;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final String seat;
  final String price;
  final String amountBase;
  final String taxAmount;
  final String taxRate;
  final int passengerCount;
  final String beneficiaryName;
  final String requesterPhone;
  final String beneficiaryPhone;
  final String issuerName;
  final String? qrData;
  final String? mecefCode;
  final String? mecefNim;
  final String? mecefCounters;
  final String? mecefDate;
  final bool isPaymentPending;
  final String status;

  const _ReservationItem({
    this.ticketId,
    this.voyageId,
    required this.reference,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.seat,
    required this.price,
    this.amountBase = '0 FCFA',
    this.taxAmount = '0 FCFA',
    this.taxRate = '0',
    required this.passengerCount,
    required this.beneficiaryName,
    required this.requesterPhone,
    required this.beneficiaryPhone,
    this.issuerName = '',
    this.qrData,
    this.mecefCode,
    this.mecefNim,
    this.mecefCounters,
    this.mecefDate,
    required this.isPaymentPending,
    required this.status,
  });

  String get route => '$departure → $destination';

  _ReservationItem copyWith({
    int? ticketId,
    int? voyageId,
    String? departure,
    String? destination,
    String? date,
    String? time,
    String? seat,
    String? price,
    String? amountBase,
    String? taxAmount,
    String? taxRate,
    int? passengerCount,
    String? beneficiaryName,
    String? requesterPhone,
    String? beneficiaryPhone,
    String? issuerName,
    String? qrData,
    String? mecefCode,
    String? mecefNim,
    String? mecefCounters,
    String? mecefDate,
    bool? isPaymentPending,
    String? status,
  }) {
    return _ReservationItem(
      ticketId: ticketId ?? this.ticketId,
      voyageId: voyageId ?? this.voyageId,
      reference: reference,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      time: time ?? this.time,
      seat: seat ?? this.seat,
      price: price ?? this.price,
      amountBase: amountBase ?? this.amountBase,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      passengerCount: passengerCount ?? this.passengerCount,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      beneficiaryPhone: beneficiaryPhone ?? this.beneficiaryPhone,
      issuerName: issuerName ?? this.issuerName,
      qrData: qrData ?? this.qrData,
      mecefCode: mecefCode ?? this.mecefCode,
      mecefNim: mecefNim ?? this.mecefNim,
      mecefCounters: mecefCounters ?? this.mecefCounters,
      mecefDate: mecefDate ?? this.mecefDate,
      isPaymentPending: isPaymentPending ?? this.isPaymentPending,
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

class _ReservationSummaryCard extends StatelessWidget {
  final _ReservationItem item;
  final VoidCallback? onPay;

  const _ReservationSummaryCard({required this.item, this.onPay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          _TicketVisual(
            departure: item.departure,
            destination: item.destination,
            date: item.date,
            time: item.time,
            passengerCount: item.passengerCount,
            ticketIndex: 1,
            beneficiaryName: item.beneficiaryName,
            total: item.price,
            reference: item.reference,
            qrData: item.qrData,
            mecefCode: item.mecefCode,
            mecefNim: item.mecefNim,
            mecefCounters: item.mecefCounters,
            primaryActionLabel: '',
            showCancelAction: false,
          ),
          if (onPay != null) ...[
            const SizedBox(height: 12),
            _ReservationPaymentCard(
              amount: item.price,
              onPay: onPay!,
            ),
          ],
          if (onPay == null && item.qrData != null) ...[
            const SizedBox(height: 12),
            _PrintTicketButton(item: item),
          ],
        ],
      ),
    );
  }
}

class _PrintTicketButton extends StatelessWidget {
  final _ReservationItem item;

  const _PrintTicketButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await _printTicket(item);
          } catch (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  error.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.print_rounded),
        label: const Text(
          'Imprimer le billet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
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
                  'Procéder au paiement',
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
        onSave: (updated) async {
          await _updateReservation(updated);
        },
      ),
    );
  }

  void _showPaymentSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentMethodSheet(
      total: _reservation.price,
      ticketReference: _reservation.reference, // ⬅️ AJOUT
      onPaymentConfirmed: () {
        setState(() {
          _reservation = _reservation.copyWith(status: 'Confirmée');
        });
      },
    ),
  );
}

  Future<void> _confirmCancel() async {
    final shouldCancel = await _showCancelReservationDialog(context);
    if (shouldCancel != true) return;

    final ticketId = _reservation.ticketId;
    if (ticketId == null) {
      _showActionError('Réservation introuvable sur le serveur.');
      return;
    }

    try {
      await TicketService().annulerClient(ticketId);
    } catch (error) {
      _showActionError(error.toString().replaceFirst('Exception: ', ''));
      return;
    }

    _HistoryRepository.removeReservation(_reservation.reference);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée.')));
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
      _HistoryRepository.updateReservation(updated);
      if (mounted) setState(() => _reservation = updated);
    } catch (error) {
      _showActionError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showActionError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                    if (_reservation.isPaymentPending) ...[
                      _ReservationPaymentCard(
                        amount: _reservation.price,
                        onPay: _showPaymentSheet,
                      ),
                      const SizedBox(height: 20),
                    ],
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
                      qrData: _reservation.qrData,
                      primaryActionLabel: '',
                      onEdit: _editReservation,
                      onCancel: _confirmCancel,
                    ),
                    if (!_reservation.isPaymentPending &&
                        _reservation.qrData != null) ...[
                      const SizedBox(height: 12),
                      _PrintTicketButton(item: _reservation),
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

Future<void> _printTicket(_ReservationItem ticket) async {
  final qrData = ticket.qrData;
  if (qrData == null || qrData.isEmpty) return;

  final settings = await TicketPrintSettingsService().getSettings();
  if (!settings.enabled) {
    throw Exception('L’impression des billets est désactivée.');
  }

  final qrImageData = await QrPainter(
    data: qrData,
    version: QrVersions.auto,
    gapless: true,
  ).toImageData(480, format: ui.ImageByteFormat.png);
  if (qrImageData == null) {
    throw Exception('Impossible de préparer le QR code du billet.');
  }

  final document = pw.Document();
  final qrImage = pw.MemoryImage(qrImageData.buffer.asUint8List());
  pw.MemoryImage? logoImage;
  final logoUrl = settings.agencyLogo;
  if (logoUrl != null && logoUrl.startsWith('http')) {
    try {
      final logoResponse = await http
          .get(Uri.parse(logoUrl))
          .timeout(const Duration(seconds: 5));
      if (logoResponse.statusCode == 200 && logoResponse.bodyBytes.isNotEmpty) {
        logoImage = pw.MemoryImage(logoResponse.bodyBytes);
      }
    } catch (_) {
      logoImage = null;
    }
  }
  if (logoImage == null) {
    try {
      final logoBytes = await rootBundle.load(
        'assets/images/logo_fofana_no_background.png',
      );
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }
  }
  final accent = PdfColor.fromHex(settings.accentColor);
  final pageFormat =
      settings.width == '58mm' ? PdfPageFormat.roll57 : PdfPageFormat.roll80;
  final cancellationNotice =
      'Annulation possible jusqu\'à ${settings.cancellationDelayDays} jour${settings.cancellationDelayDays > 1 ? 's' : ''} avant le départ. '
      'Au-delà, une retenue de ${settings.cancellationPenaltyPercent}% peut être appliquée sur le remboursement.';

  document.addPage(
    pw.Page(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: pw.Font.courier(),
        bold: pw.Font.courierBold(),
      ),
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _printTornEdge(pageFormat.width),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(12.8, 12.8, 12.8, 6.4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
          if (logoImage != null)
            pw.Center(
              child: pw.Container(
                width: 32,
                height: 32,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.ClipOval(child: pw.Image(logoImage)),
              ),
            ),
          pw.Center(
            child: pw.Text(
              settings.agencyName.toUpperCase(),
              style: pw.TextStyle(
                color: PdfColors.grey800,
                fontSize: 9.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 0.8),
          pw.Center(
            child: pw.Text(
              ticket.mecefCode?.isNotEmpty == true
                  ? 'FACTURE NORMALISÉE'
                  : (settings.headerText.isEmpty
                      ? settings.title
                      : settings.headerText),
              style: pw.TextStyle(
                color: accent,
                fontSize: 11.2,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          if (settings.showEmetteur)
            _printRow('Émetteur', settings.agencyName),
          if (settings.showContact && settings.telephone.isNotEmpty)
            _printRow('Tél', settings.telephone),
          if (settings.showContact && settings.email.isNotEmpty)
            _printRow('Email', settings.email),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'N° ${ticket.reference}',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 8,
                ),
              ),
              pw.Text(
                _printDate(DateTime.now()),
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 8,
                ),
              ),
            ],
          ),
          _printDashedLine(accent),
          _printRow('Passager', ticket.beneficiaryName),
          _printRouteRow(ticket.departure, ticket.destination),
          _printRow('Départ', '${ticket.date} · ${ticket.time}'),
          _printRow('Places', '${ticket.passengerCount} place(s)'),
          if (ticket.beneficiaryPhone.isNotEmpty)
            _printRow('Tél', ticket.beneficiaryPhone),
          _printDashedLine(accent),
          _printRow('Montant HT', ticket.amountBase),
          _printRow('Taxe (${ticket.taxRate}%)', ticket.taxAmount),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL TTC',
                  style: pw.TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  ticket.price,
                  style: pw.TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (settings.showEnregistrePar && ticket.issuerName.isNotEmpty)
            _printCentered(
              'Facture enregistrée par : ${ticket.issuerName}',
              PdfColors.grey500,
              7,
            ),
          if (settings.showDgi) ...[
            pw.SizedBox(height: 6),
            if (ticket.mecefCode?.isNotEmpty == true)
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'ÉLÉMENTS DE SÉCURITÉ DGI',
                      style: pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (ticket.mecefCode?.isNotEmpty == true)
                      _printSingleLineRow('CODE', ticket.mecefCode!),
                    if (ticket.mecefNim?.isNotEmpty == true)
                      _printRow('NIM', ticket.mecefNim!),
                    if (ticket.mecefCounters?.isNotEmpty == true)
                      _printRow('COMPTEURS', ticket.mecefCounters!),
                    if (ticket.mecefDate?.isNotEmpty == true)
                      _printRow('DATE', _printMecefDate(ticket.mecefDate!)),
                  ],
                ),
              )
            else
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                    style: pw.BorderStyle.dashed,
                  ),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'REÇU SIMPLE\n(Document non normalisé DGI)',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      color: PdfColors.grey500,
                      fontSize: 7,
                    ),
                  ),
                ),
              ),
          ],
          if (settings.showBarcode) ...[
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Container(
                width: 77.76,
                height: 77.76,
                padding: const pw.EdgeInsets.all(6.48),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(9.6),
                  ),
                ),
                child: pw.Image(qrImage, width: 58.32, height: 58.32),
              ),
            ),
            pw.SizedBox(height: 6.4),
            pw.Center(
              child: pw.Text(
                ticket.mecefCode?.isNotEmpty == true
                    ? 'VÉRIFIER SUR EFACTURE.IMPOTS.BJ'
                    : ticket.reference,
                style: pw.TextStyle(
                  color: accent,
                  fontSize: 6.4,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
          pw.SizedBox(height: 6.4),
          pw.Center(
            child: pw.Text(
              settings.footerText,
              style: pw.TextStyle(              fontSize: 8,
              color: PdfColors.grey600,
              ),
            ),
          ),
          if (settings.showCancellationNotice) ...[
            pw.SizedBox(height: 3.2),
            pw.Center(
              child: pw.Text(
                cancellationNotice,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 6.4),
              ),
            ),
          ],
              ],
            ),
          ),
          _printTornEdge(pageFormat.width),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (_) async => document.save(),
    name: 'billet-${ticket.reference}.pdf',
    format: pageFormat,
    usePrinterSettings: true,
  );
}

pw.Widget _printTornEdge(double width) {
  return pw.SizedBox(
    height: 7,
    width: width,
    child: pw.CustomPaint(
      size: PdfPoint(width, 7),
      painter: (canvas, size) {
        const teeth = 16;
        final toothWidth = size.x / teeth;
        canvas
          ..setFillColor(PdfColors.grey400)
          ..moveTo(0, 0);
        for (var i = 0; i < teeth; i++) {
          final x1 = i * toothWidth + toothWidth / 2;
          final x2 = (i + 1) * toothWidth;
          canvas
            ..lineTo(x1, size.y)
            ..lineTo(x2, 0);
        }
        canvas
          ..lineTo(size.x, size.y)
          ..lineTo(0, size.y)
          ..fillPath();
      },
    ),
  );
}

pw.Widget _printRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColors.grey500,
              fontSize: 8.8,
            ),
          ),
        ),
        pw.Expanded(
          flex: 7,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 8.8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _printSingleLineRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 7.5),
          ),
        ),
        pw.Expanded(
          flex: 7,
          child: pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _printRouteRow(String departure, String destination) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            'Trajet',
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 7.5),
          ),
        ),
        pw.Expanded(
          flex: 7,
          child: pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  departure,
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                  child: pw.SizedBox(
                    width: 10,
                    height: 8,
                    child: pw.CustomPaint(
                      painter: (canvas, size) {
                        canvas
                          ..setStrokeColor(PdfColors.grey800)
                          ..setLineWidth(1)
                          ..moveTo(0, size.y / 2)
                          ..lineTo(size.x - 3, size.y / 2)
                          ..strokePath()
                          ..moveTo(size.x - 5, 1)
                          ..lineTo(size.x, size.y / 2)
                          ..lineTo(size.x - 5, size.y - 1)
                          ..closePath()
                          ..setFillColor(PdfColors.grey800)
                          ..fillPath();
                      },
                    ),
                  ),
                ),
                pw.Text(
                  destination,
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _printDashedLine(PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5.6),
    child: pw.Container(
      height: 0.8,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColors.grey500,
            width: 0.8,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    ),
  );
}

String _printMecefDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${_printDate(parsed)} ${parsed.hour.toString().padLeft(2, '0')}:'
      '${parsed.minute.toString().padLeft(2, '0')}';
}

pw.Widget _printCentered(String value, PdfColor color, double fontSize) {
  return pw.Center(
    child: pw.Text(
      value,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(color: color, fontSize: fontSize),
    ),
  );
}

String _printDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
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
        onSave: (updated) async{
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

class _TicketVisual extends StatelessWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String beneficiaryName;
  final String total;
  final String reference;
  final String? qrData;
  final String? mecefCode;
  final String? mecefNim;
  final String? mecefCounters;
  final String primaryActionLabel;
  final int ticketIndex;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
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
    this.qrData,
    this.mecefCode,
    this.mecefNim,
    this.mecefCounters,
    required this.primaryActionLabel,
    required this.ticketIndex,
    this.onEdit,
    this.onCancel,
    this.showCancelAction = true,
    this.editActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    const muted = Color(0xFF9AA3B8);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
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
          if (qrData != null && qrData!.isNotEmpty) ...[
            const SizedBox(height: 26),
            _TicketQrCode(data: qrData!),
            const SizedBox(height: 12),
            Text(
              'Référence : $reference',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: deepBlue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Divider(color: deepBlue.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 20),
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
