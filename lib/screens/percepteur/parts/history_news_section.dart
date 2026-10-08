import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fofanavoyage/screens/percepteur/parts/reservation_flow.dart';
import 'package:fofanavoyage/screens/percepteur/parts/percepteur_ticket_print_page.dart';
import 'package:fofanavoyage/services/ticket_service.dart';
import 'package:fofanavoyage/services/staff_ticket_service.dart';

// Historique percepteur et actualites affichees dans l espace percepteur.

enum PercepteurHistoryScope {
  reservationsAgence,
  enCours,
  enAttente,
  payes,
  present,
  absent,
  annules,
}

class PercepteurHistoryPage extends StatefulWidget {
  const PercepteurHistoryPage({super.key});

  @override
  State<PercepteurHistoryPage> createState() => PercepteurHistoryPageState();
}

class PercepteurHistoryPageState extends State<PercepteurHistoryPage> {
  PercepteurHistoryScope _scope = PercepteurHistoryScope.reservationsAgence;
  List<PercepteurReservationRecord> _agencyTickets = [];
  List<PercepteurReservationRecord> _emittedTickets = [];
  bool _loadingAgencyTickets = true;
  bool _loadingEmittedTickets = true;
  String? _agencyHistoryError;
  String? _emittedHistoryError;
  int? _cancellingTicketId;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    await Future.wait([_loadAgencyTickets(), _loadEmittedTickets()]);
  }

  Future<void> _loadAgencyTickets() async {
    setState(() {
      _loadingAgencyTickets = true;
      _agencyHistoryError = null;
    });
    try {
      final tickets = await TicketService().getTicketsClientsAgence();
      if (!mounted) return;
      setState(() {
        _agencyTickets = tickets
            .map(PercepteurReservationRecord.fromTicket)
            .toList();
        _loadingAgencyTickets = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _agencyHistoryError = error.toString().replaceFirst('Exception: ', '');
        _loadingAgencyTickets = false;
      });
    }
  }

  Future<void> _loadEmittedTickets() async {
    setState(() {
      _loadingEmittedTickets = true;
      _emittedHistoryError = null;
    });
    try {
      final tickets = await TicketService().getTicketsEmis();
      if (!mounted) return;
      setState(() {
        _emittedTickets = tickets
            .map(PercepteurReservationRecord.fromTicket)
            .toList();
        _loadingEmittedTickets = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _emittedHistoryError = error.toString().replaceFirst('Exception: ', '');
        _loadingEmittedTickets = false;
      });
    }
  }

  Future<void> _cancelTicket(PercepteurReservationRecord ticket) async {
    final ticketId = ticket.ticketId;
    if (ticketId == null || _cancellingTicketId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: Text(
          'Voulez-vous annuler le ticket ${ticket.reference} ? Un avoir sera créé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler le ticket'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancellingTicketId = ticketId);
    try {
      final result = await StaffTicketService().annulerTicket(ticketId);
      await _loadTickets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Ticket annulé et avoir créé.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancellingTicketId = null);
    }
  }

  void _showTicketDetails(PercepteurReservationRecord ticket) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails du ticket',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0B4F2A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _ticketDetail('Référence', ticket.reference),
              _ticketDetail('Statut', ticket.status),
              _ticketDetail(
                'Paiement',
                ticket.paymentStatus?.isNotEmpty == true
                    ? ticket.paymentStatus!
                    : 'Non renseigné',
              ),
              _ticketDetail('Passager', ticket.passengerName),
              _ticketDetail('Téléphone', ticket.phone),
              _ticketDetail(
                'Trajet',
                '${ticket.departure} → ${ticket.destination}',
              ),
              _ticketDetail(
                'Départ',
                '${formatPercepteurTicketDate(ticket.date)} à '
                    '${formatPercepteurTicketTime(ticket.time)}',
              ),
              _ticketDetail('Nombre de places', '${ticket.passengerCount}'),
              _ticketDetail('Bus', ticket.busMatricule),
              _ticketDetail('Montant total', ticket.price),
              if (ticket.baseAmount != null)
                _ticketDetail(
                  'Montant HT',
                  '${ticket.baseAmount!.toStringAsFixed(0)} FCFA',
                ),
              if (ticket.taxAmount != null)
                _ticketDetail(
                  'Taxe',
                  '${ticket.taxAmount!.toStringAsFixed(0)} FCFA'
                      '${ticket.taxRate == null ? '' : ' (${ticket.taxRate!.toStringAsFixed(2)} %)'}',
                ),
              if (ticket.issuerName.isNotEmpty)
                _ticketDetail('Émis par', ticket.issuerName),
              if (ticket.mecefCode?.isNotEmpty == true)
                _ticketDetail('Code MECeF', ticket.mecefCode!),
              if (ticket.mecefNim?.isNotEmpty == true)
                _ticketDetail('NIM', ticket.mecefNim!),
              if (ticket.mecefCounters?.isNotEmpty == true)
                _ticketDetail('Compteurs MECeF', ticket.mecefCounters!),
              if (ticket.mecefDate?.isNotEmpty == true)
                _ticketDetail(
                  'Date MECeF',
                  formatPercepteurMecefDate(ticket.mecefDate!),
                ),
              if (ticket.mecefDate?.isNotEmpty == true)
                _ticketDetail(
                  'Heure MECeF',
                  formatPercepteurMecefTime(ticket.mecefDate!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _printTicket(PercepteurReservationRecord ticket) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PercepteurTicketPrintPage(ticket: ticket.toPrintMap()),
      ),
    );
  }

  Widget _ticketDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5F6B86)),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: Color(0xFF0B4F2A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    final agencyReservations = _agencyTickets
        .where((ticket) => !_isCancelled(ticket))
        .toList();
    final cancelledByIdentity = <String, PercepteurReservationRecord>{};
    for (final ticket in [..._agencyTickets, ..._emittedTickets]) {
      if (!_isCancelled(ticket)) continue;
      final identity = ticket.ticketId != null
          ? 'id:${ticket.ticketId}'
          : 'reference:${ticket.reference}';
      cancelledByIdentity.putIfAbsent(identity, () => ticket);
    }
    final cancelledTickets = cancelledByIdentity.values.toList();
    final allTicketsByIdentity = <String, PercepteurReservationRecord>{};
    for (final ticket in [..._agencyTickets, ..._emittedTickets]) {
      final identity = ticket.ticketId != null
          ? 'id:${ticket.ticketId}'
          : 'reference:${ticket.reference}';
      allTicketsByIdentity.putIfAbsent(identity, () => ticket);
    }
    final allTickets = allTicketsByIdentity.values.toList();
    final inProgressTickets = _ticketsWithStatus(allTickets, 'en_cours');
    final pendingTickets = _ticketsWithStatus(allTickets, 'en_attente');
    final paidTickets = _ticketsWithStatus(allTickets, 'paye');
    final presentTickets = _ticketsWithStatus(allTickets, 'present');
    final absentTickets = _ticketsWithStatus(allTickets, 'absent');
    final cancellationErrors = [
      _agencyHistoryError,
      _emittedHistoryError,
    ].whereType<String>().where((error) => error.isNotEmpty).toList();
    final statusLoading = _loadingAgencyTickets || _loadingEmittedTickets;
    final selectedTickets = switch (_scope) {
      PercepteurHistoryScope.reservationsAgence => agencyReservations,
      PercepteurHistoryScope.enCours => inProgressTickets,
      PercepteurHistoryScope.enAttente => pendingTickets,
      PercepteurHistoryScope.payes => paidTickets,
      PercepteurHistoryScope.present => presentTickets,
      PercepteurHistoryScope.absent => absentTickets,
      PercepteurHistoryScope.annules => cancelledTickets,
    };
    final selectedTitle = switch (_scope) {
      PercepteurHistoryScope.reservationsAgence =>
        'Aucune réservation pour cette agence',
      PercepteurHistoryScope.enCours => 'Aucun ticket en cours',
      PercepteurHistoryScope.enAttente => 'Aucun ticket en attente',
      PercepteurHistoryScope.payes => 'Aucun ticket payé',
      PercepteurHistoryScope.present => 'Aucun passager présent',
      PercepteurHistoryScope.absent => 'Aucun passager absent',
      PercepteurHistoryScope.annules => 'Aucun ticket annulé',
    };
    final selectedMessage = switch (_scope) {
      PercepteurHistoryScope.reservationsAgence =>
        'Les réservations des clients au départ de l’agence '
            'd’affectation apparaîtront ici.',
      PercepteurHistoryScope.enCours =>
        'Les tickets au statut « en_cours » apparaîtront ici.',
      PercepteurHistoryScope.enAttente =>
        'Les tickets au statut « en_attente » apparaîtront ici.',
      PercepteurHistoryScope.payes =>
        'Les tickets au statut « paye » apparaîtront ici.',
      PercepteurHistoryScope.present =>
        'Les tickets validés, utilisés ou embarqués apparaîtront ici.',
      PercepteurHistoryScope.absent =>
        'Les tickets au statut « absent » apparaîtront ici.',
      PercepteurHistoryScope.annules =>
        'Les tickets au statut « annule » apparaîtront ici.',
    };
    final selectedIsAgency =
        _scope == PercepteurHistoryScope.reservationsAgence;
    final selectedIsCancelled = _scope == PercepteurHistoryScope.annules;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Historique voyage',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _HistoryTab(
                      icon: Icons.storefront_rounded,
                      label: 'Agence',
                      count: agencyReservations.length,
                      selected: selectedIsAgency,
                      onTap: () => _selectScope(
                        PercepteurHistoryScope.reservationsAgence,
                      ),
                    ),
                    _HistoryTab(
                      icon: Icons.pending_actions_rounded,
                      label: 'En cours',
                      count: inProgressTickets.length,
                      selected: _scope == PercepteurHistoryScope.enCours,
                      onTap: () => _selectScope(PercepteurHistoryScope.enCours),
                    ),
                    _HistoryTab(
                      icon: Icons.hourglass_top_rounded,
                      label: 'En attente',
                      count: pendingTickets.length,
                      selected: _scope == PercepteurHistoryScope.enAttente,
                      onTap: () =>
                          _selectScope(PercepteurHistoryScope.enAttente),
                    ),
                    _HistoryTab(
                      icon: Icons.payments_rounded,
                      label: 'Payés',
                      count: paidTickets.length,
                      selected: _scope == PercepteurHistoryScope.payes,
                      onTap: () => _selectScope(PercepteurHistoryScope.payes),
                    ),
                    _HistoryTab(
                      icon: Icons.how_to_reg_rounded,
                      label: 'Présents',
                      count: presentTickets.length,
                      selected: _scope == PercepteurHistoryScope.present,
                      onTap: () => _selectScope(PercepteurHistoryScope.present),
                    ),
                    _HistoryTab(
                      icon: Icons.person_off_rounded,
                      label: 'Absents',
                      count: absentTickets.length,
                      selected: _scope == PercepteurHistoryScope.absent,
                      onTap: () => _selectScope(PercepteurHistoryScope.absent),
                    ),
                    _HistoryTab(
                      icon: Icons.cancel_rounded,
                      label: 'Annulés',
                      count: cancelledTickets.length,
                      selected: selectedIsCancelled,
                      onTap: () => _selectScope(PercepteurHistoryScope.annules),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PercepteurReservationList(
                  reservations: selectedTickets,
                  isLoading: selectedIsAgency
                      ? _loadingAgencyTickets
                      : statusLoading,
                  error: selectedIsAgency
                      ? _agencyHistoryError
                      : cancellationErrors.isEmpty
                      ? null
                      : cancellationErrors.join('\n'),
                  emptyTitle: selectedTitle,
                  emptyMessage: selectedMessage,
                  onRetry: selectedIsAgency ? _loadAgencyTickets : _loadTickets,
                  onCancel: _cancelTicket,
                  onView: _showTicketDetails,
                  onPrint: _printTicket,
                  cancellingTicketId: _cancellingTicketId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCancelled(PercepteurReservationRecord ticket) {
    return _normalizeStatus(ticket.rawStatus) == 'annule';
  }

  List<PercepteurReservationRecord> _ticketsWithStatus(
    List<PercepteurReservationRecord> tickets,
    String status,
  ) {
    return tickets
        .where((ticket) => _normalizeStatus(ticket.rawStatus) == status)
        .toList();
  }

  String _normalizeStatus(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('û', 'u')
        .replaceAll(' ', '_');

    return switch (normalized) {
      'annulee' => 'annule',
      'utilise' || 'valide' || 'embarque' || 'present' => 'present',
      'en_cours' => 'en_cours',
      'en_attente' => 'en_attente',
      'paye' => 'paye',
      _ => normalized,
    };
  }

  void _selectScope(PercepteurHistoryScope scope) {
    setState(() => _scope = scope);
  }
}

class PercepteurReservationList extends StatelessWidget {
  final List<PercepteurReservationRecord> reservations;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRetry;
  final Future<void> Function(PercepteurReservationRecord ticket) onCancel;
  final void Function(PercepteurReservationRecord ticket) onView;
  final void Function(PercepteurReservationRecord ticket) onPrint;
  final int? cancellingTicketId;
  final String emptyTitle;
  final String emptyMessage;

  const PercepteurReservationList({
    super.key,
    required this.reservations,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onCancel,
    required this.onView,
    required this.onPrint,
    required this.cancellingTicketId,
    this.emptyTitle = 'Aucune réservation',
    this.emptyMessage =
        'Les réservations faites par le percepteur apparaîtront ici.',
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            Column(
              children: [
                PercepteurEmptyCard(
                  title: 'Historique indisponible',
                  message: error!,
                ),
                TextButton.icon(
                  onPressed: () => onRetry(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            )
          else if (reservations.isEmpty)
            PercepteurEmptyCard(title: emptyTitle, message: emptyMessage)
          else
            ...reservations.map(
              (item) => PercepteurReservationCard(
                item: item,
                onCancel: item.canCancel ? () => onCancel(item) : null,
                onView: () => onView(item),
                onPrint: item.canPrint ? () => onPrint(item) : null,
                isCancelling: cancellingTicketId == item.ticketId,
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int count;

  const _HistoryTab({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: const Color(0xFF16A34A),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? const Color(0xFF16A34A)
              : deepBlue.withValues(alpha: 0.18),
        ),
        shape: const StadiumBorder(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : deepBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : deepBlue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : deepBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : deepBlue,
                  fontSize: 10,
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

class PercepteurNewsArticle {
  final String category;
  final String title;
  final String date;
  final String image;
  final String excerpt;
  final List<String> body;

  const PercepteurNewsArticle({
    required this.category,
    required this.title,
    required this.date,
    required this.image,
    required this.excerpt,
    required this.body,
  });
}

const List<PercepteurNewsArticle> percepteurNewsArticles = [
  PercepteurNewsArticle(
    category: 'Annonces',
    title: 'Nouveau départ sur Gouré',
    date: '28/03/2026',
    image: 'assets/images/coli1.jpg',
    excerpt:
        'Fofana renforce son réseau avec un nouveau départ pensé pour faciliter les déplacements réguliers.',
    body: [
      'Fofana informe son aimable clientèle de la mise en place d’un nouveau départ sur l’axe Gouré afin de rendre les voyages plus simples, plus réguliers et plus confortables.',
      'Cette nouvelle desserte répond à la demande des voyageurs qui souhaitent mieux organiser leurs déplacements entre les grandes villes et les localités desservies par Fofana.',
      'Les clients sont invités à se rapprocher des agences Fofana pour confirmer les horaires, les disponibilités et les conditions de réservation.',
    ],
  ),
  PercepteurNewsArticle(
    category: 'Annonces',
    title: "Renforcement des départs sur l'axe Tchaourou",
    date: '25/03/2026',
    image: 'assets/images/coli2.jpg',
    excerpt:
        'De nouveaux horaires sont ajoutés pour offrir plus de flexibilité aux voyageurs.',
    body: [
      'Pour mieux accompagner les besoins de mobilité, Fofana annonce un renforcement progressif des départs sur l’axe Tchaourou.',
      'Cette organisation permet aux voyageurs de choisir des créneaux plus adaptés à leurs programmes personnels, professionnels ou familiaux.',
      'Les équipes en agence restent disponibles pour orienter les clients et les aider à choisir le départ le plus pratique.',
    ],
  ),
  PercepteurNewsArticle(
    category: 'Presse',
    title: 'Fofana modernise l’accueil dans ses agences',
    date: '18/03/2026',
    image: 'assets/images/coli3.jpg',
    excerpt:
        'Un parcours client plus fluide est déployé pour améliorer l’achat de tickets et l’information voyageur.',
    body: [
      'Fofana poursuit l’amélioration de l’expérience client dans ses agences avec des espaces plus lisibles, un accueil renforcé et une meilleure orientation des voyageurs.',
      'L’objectif est de réduire l’attente, d’améliorer la qualité des informations et de rendre chaque étape du voyage plus agréable.',
      'Cette modernisation s’inscrit dans une démarche continue de qualité de service.',
    ],
  ),
  PercepteurNewsArticle(
    category: 'Conseils',
    title: 'Bien préparer son voyage avec Fofana',
    date: '12/03/2026',
    image: 'assets/images/coli4.jpg',
    excerpt:
        'Quelques réflexes simples pour voyager sereinement et éviter les oublis avant le départ.',
    body: [
      'Avant chaque départ, Fofana recommande aux voyageurs de vérifier leur ticket, leur pièce d’identité et l’heure de présentation en agence.',
      'Il est conseillé d’arriver suffisamment tôt afin d’effectuer les formalités sans stress et d’embarquer dans de bonnes conditions.',
      'Pour les bagages et colis, les équipes Fofana peuvent préciser les règles applicables selon le trajet choisi.',
    ],
  ),
  PercepteurNewsArticle(
    category: 'Communiqués',
    title: 'Suivi des colis disponible dans les agences Fofana',
    date: '08/03/2026',
    image: 'assets/images/logo_fofana.png',
    excerpt:
        'Les clients peuvent obtenir des informations sur leurs colis directement auprès des points Fofana.',
    body: [
      'Fofana rappelle à sa clientèle que le suivi des colis est disponible auprès de ses agences et points de contact.',
      'Les clients sont invités à conserver leurs références d’envoi afin de faciliter les vérifications et accélérer la prise en charge.',
      'Ce service accompagne les voyageurs et expéditeurs dans une logique de proximité et de fiabilité.',
    ],
  ),
];

class PercepteurNewsSection extends StatefulWidget {
  const PercepteurNewsSection({super.key});

  @override
  State<PercepteurNewsSection> createState() => PercepteurNewsSectionState();
}

class PercepteurNewsSectionState extends State<PercepteurNewsSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(
        () => _pageIndex = (_pageIndex + 1) % percepteurNewsArticles.length,
      );
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    void openDetail(PercepteurNewsArticle article) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PercepteurNewsDetailPage(article: article),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actualités',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PercepteurNewsListPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Voir plus',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 138,
          child: PageView.builder(
            controller: _pageController,
            itemCount: percepteurNewsArticles.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = percepteurNewsArticles[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: PercepteurNewsHeroTile(
                  article: item,
                  compact: true,
                  onTap: () => openDetail(item),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(percepteurNewsArticles.length, (i) {
            final isActive = i == _pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 10,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? green : Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class PercepteurNewsHeroTile extends StatelessWidget {
  final PercepteurNewsArticle article;
  final VoidCallback onTap;
  final bool compact;

  const PercepteurNewsHeroTile({
    super.key,
    required this.article,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                article.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF8FBFF),
                  child: const Icon(Icons.image_not_supported_rounded),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: 0.43)),
              Positioned(
                left: 12,
                top: 12,
                child: PercepteurNewsCategoryPill(category: article.category),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: compact ? 14 : 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Publié le ${article.date}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      article.title,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 14.2 : 18,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 13.2,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
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

class PercepteurNewsCategoryPill extends StatelessWidget {
  final String category;

  const PercepteurNewsCategoryPill({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class PercepteurNewsListPage extends StatelessWidget {
  const PercepteurNewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actualités',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          itemCount: percepteurNewsArticles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final article = percepteurNewsArticles[index];
            return SizedBox(
              height: 178,
              child: PercepteurNewsHeroTile(
                article: article,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PercepteurNewsDetailPage(article: article),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PercepteurNewsDetailPage extends StatelessWidget {
  final PercepteurNewsArticle article;

  const PercepteurNewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actualité',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            SizedBox(
              height: 230,
              child: PercepteurNewsHeroTile(article: article, onTap: () {}),
            ),
            const SizedBox(height: 18),
            Text(
              article.title,
              style: const TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publié le ${article.date}',
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.excerpt,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ...article.body.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  paragraph,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PercepteurTab {
  final String title;
  final IconData icon;

  const PercepteurTab(this.title, this.icon);
}
