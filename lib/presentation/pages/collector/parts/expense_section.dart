part of '../collector_home_page.dart';

// Ecran Depense percepteur et ses widgets de saisie, liste et synthese.

class _CollectorDepenseContent extends StatefulWidget {
  const _CollectorDepenseContent();

  @override
  State<_CollectorDepenseContent> createState() =>
      _CollectorDepenseContentState();
}

class _CollectorDepenseContentState extends State<_CollectorDepenseContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final expenseStore = ExpenseStore();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _CollectorReservationStore.version,
      builder: (context, _, __) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<List<ExpenseModel>>(
                valueListenable: expenseStore.expensesNotifier,
                builder: (context, expenses, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExpenseMenu(expenses),
                    const SizedBox(height: 8),
                    _buildTripHeader(expenses),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      controller: _tabController,
                      children: [_buildOngoingTab(), _buildHistoricalTab()],
                    ),
                    Positioned(
                      right: 16,
                      bottom: 8,
                      child: FloatingActionButton(
                        onPressed: _showAddExpenseSheet,
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(Icons.add_rounded, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ExpenseModel> _activeReservationExpenses(List<ExpenseModel> expenses) {
    final reservation = _latestReservation();
    if (reservation == null) return [];
    return expenses
        .where(
          (expense) => expense.reservationReference == reservation.reference,
        )
        .toList();
  }

  List<ExpenseModel> _historicalReservationExpenses(
    List<ExpenseModel> expenses,
  ) {
    final historicalReferences = _CollectorReservationStore
        .historicalReservations
        .map((reservation) => reservation.reference)
        .toSet();
    return expenses.where((expense) {
      final reference = expense.reservationReference;
      return reference != null && historicalReferences.contains(reference);
    }).toList();
  }

  void _openManualExpenseForReservation(
    _CollectorReservationRecord reservation,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualExpensePage(
          reservationReference: reservation.reference,
          tripRoute: _reservationRoute(reservation),
          busMatricule: reservation.busMatricule,
        ),
      ),
    );
  }

  void _openScannerForReservation(_CollectorReservationRecord reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          reservationReference: reservation.reference,
          tripRoute: _reservationRoute(reservation),
          busMatricule: reservation.busMatricule,
        ),
      ),
    );
  }

  void _showNoActiveReservationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Créez d’abord une réservation pour saisir une dépense.'),
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  void _showAddExpenseSheet() {
    final reservation = _latestReservation();
    if (reservation == null) {
      _showNoActiveReservationMessage();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B4F2A), Color(0xFF168A43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_card_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ajouter dépense',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openScannerForReservation(reservation);
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text('Scanner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B4F2A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openManualExpenseForReservation(reservation);
                          },
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Saisie'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildDashboardHeader(List<ExpenseModel> expenses) {
    final ongoingExpenses = expenses
        .where((expense) => expense.status == 'En cours')
        .toList();
    final totalEnCours = ongoingExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B4F2A), Color(0xFF168A43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B4F2A).withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dépenses percepteur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total en cours',
                          style: TextStyle(
                            color: Color(0xFFEAF7EF),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${totalEnCours.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final reservation = _latestReservation();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScannerPage(
                                reservationReference: reservation?.reference,
                                tripRoute: reservation == null
                                    ? null
                                    : _reservationRoute(reservation),
                                busMatricule: reservation?.busMatricule,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B4F2A),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final reservation = _latestReservation();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManualExpensePage(
                                reservationReference: reservation?.reference,
                                tripRoute: reservation == null
                                    ? null
                                    : _reservationRoute(reservation),
                                busMatricule: reservation?.busMatricule,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Saisie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseMenu(List<ExpenseModel> expenses) {
    final ongoingExpenses = _activeReservationExpenses(expenses);
    final historicalExpenses = _historicalReservationExpenses(expenses);
    final ongoingTotal = ongoingExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );
    final historyTotal = historicalExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          _buildMenuButton(
            selected: _tabController.index == 0,
            icon: Icons.hourglass_top_rounded,
            title: 'En cours',
            detail: '${ongoingTotal.toStringAsFixed(0)} FCFA',
            onTap: () => _tabController.animateTo(0),
          ),
          const SizedBox(width: 10),
          _buildMenuButton(
            selected: _tabController.index == 1,
            icon: Icons.history_rounded,
            title: 'Historique',
            detail: '${historyTotal.toStringAsFixed(0)} FCFA',
            onTap: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeader(List<ExpenseModel> expenses) {
    final isOngoing = _tabController.index == 0;
    final reservation = isOngoing
        ? _CollectorReservationStore.activeReservation
        : _latestHistoricalReservation();

    if (reservation == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox.shrink(),
      );
    }

    final trajet = _reservationRoute(reservation);
    final matricule = reservation.busMatricule;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus_filled_rounded,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trajet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bus: $matricule',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required bool selected,
    required IconData icon,
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    final color = selected ? const Color(0xFF16A34A) : const Color(0xFF64748B);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF7EF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF0B4F2A)
                            : const Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
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

  // ignore: unused_element
  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Onglet "En cours"
  Widget _buildOngoingTab() {
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: expenseStore.expensesNotifier,
      builder: (context, expenses, _) {
        final reservation = _CollectorReservationStore.activeReservation;

        if (reservation == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF16A34A),
                  size: 52,
                ),
                SizedBox(height: 14),
                Text(
                  'Aucune réservation en cours',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Créez une réservation pour saisir les dépenses du trajet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

        final ongoingExpenses = _activeReservationExpenses(expenses)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 86),
          children: [_buildOngoingTripCard(reservation, ongoingExpenses)],
        );
      },
    );
  }

  Widget _buildOngoingTripCard(
    _CollectorReservationRecord reservation,
    List<ExpenseModel> expenses,
  ) {
    final totalAmount = expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showReservationExpenseSheet(reservation, expenses),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_bus_filled_rounded,
                      color: Color(0xFF16A34A),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reservationRoute(reservation),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bus: ${reservation.busMatricule}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${expenses.length} dépense${expenses.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
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

  // Onglet "Historique"
  Widget _buildHistoricalTab() {
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: expenseStore.expensesNotifier,
      builder: (context, expenses, _) {
        final historicalReservations =
            _CollectorReservationStore.historicalReservations;

        if (historicalReservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.history_rounded, color: Color(0xFF16A34A), size: 52),
                SizedBox(height: 14),
                Text(
                  'Aucun historique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Les anciens trajets apparaîtront dès une nouvelle réservation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 86),
          itemCount: historicalReservations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reservation = historicalReservations[index];
            final routeExpenses =
                expenses
                    .where(
                      (expense) =>
                          expense.reservationReference == reservation.reference,
                    )
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return _buildHistoricalReservationCard(reservation, routeExpenses);
          },
        );
      },
    );
  }

  Widget _buildHistoricalReservationCard(
    _CollectorReservationRecord reservation,
    List<ExpenseModel> expenses,
  ) {
    final trajet = _reservationRoute(reservation);
    final totalAmount = expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showReservationExpenseSheet(
          reservation,
          expenses,
          allowAdd: false,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_bus_filled_rounded,
                      color: Color(0xFFEF4444),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trajet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bus: ${reservation.busMatricule}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${expenses.length} dépense${expenses.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total du trajet',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expenses.isEmpty
                          ? 'Ancien trajet'
                          : '${expenses.where((e) => e.status == "Validé").length}/${expenses.length} validées',
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDetail(ExpenseModel expense) {
    final totalAmount = expense.cost * expense.quantity;
    final trajet = _expenseTrajet(expense);
    final matricule = _expenseMatricule(expense);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7EF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Détails dépense',
                          style: TextStyle(
                            color: Color(0xFF0B4F2A),
                            fontSize: 19,
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
                  const SizedBox(height: 14),
                  _buildExpenseDetailRow(Icons.route_rounded, 'Trajet', trajet),
                  _buildExpenseDetailRow(
                    Icons.directions_bus_rounded,
                    'Matricule du bus',
                    matricule,
                  ),
                  _buildExpenseDetailRow(
                    Icons.label_rounded,
                    'Libellé',
                    expense.libelle,
                  ),
                  _buildExpenseDetailRow(
                    Icons.description_rounded,
                    'Description',
                    expense.description.isEmpty
                        ? 'Aucune description'
                        : expense.description,
                  ),
                  _buildExpenseDetailRow(
                    Icons.payments_rounded,
                    'Coût',
                    '${expense.cost.toStringAsFixed(0)} FCFA',
                  ),
                  _buildExpenseDetailRow(
                    Icons.numbers_rounded,
                    'Quantité',
                    '${expense.quantity}',
                  ),
                  _buildExpenseDetailRow(
                    Icons.account_balance_wallet_rounded,
                    'Total',
                    '${totalAmount.toStringAsFixed(0)} FCFA',
                  ),
                  _buildExpenseDetailRow(
                    Icons.sticky_note_2_rounded,
                    'Note',
                    expense.note.isEmpty ? 'Aucune note' : expense.note,
                  ),
                  _buildExpenseDetailRow(
                    Icons.chat_bubble_outline_rounded,
                    'Remarque',
                    expense.qrCode != null
                        ? 'Dépense ajoutée depuis un QR code'
                        : 'Dépense ajoutée en saisie manuelle',
                  ),
                  _buildExpenseDetailRow(
                    Icons.schedule_rounded,
                    'Date et heure',
                    _formatDate(expense.createdAt),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReservationExpenseSheet(
    _CollectorReservationRecord reservation,
    List<ExpenseModel> expenses, {
    bool allowAdd = true,
  }) {
    final sortedExpenses = [...expenses]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final totalAmount = sortedExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );
    final trajet = _reservationRoute(reservation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.directions_bus_filled_rounded,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trajet,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0B4F2A),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bus: ${reservation.busMatricule}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (allowAdd) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openScannerForReservation(reservation);
                            },
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const Text('Scanner'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openManualExpenseForReservation(reservation);
                            },
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Saisie'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0B4F2A),
                              side: const BorderSide(color: Color(0xFF16A34A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sortedExpenses.length} dépense${sortedExpenses.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${totalAmount.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            color: Color(0xFF0B4F2A),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: sortedExpenses.isEmpty
                        ? Center(
                            child: Text(
                              allowAdd
                                  ? 'Aucune dépense saisie pour ce trajet.'
                                  : 'Aucune dépense enregistrée pour cet ancien trajet.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: sortedExpenses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final expense = sortedExpenses[index];
                              return _buildExpenseListTile(expense);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseListTile(ExpenseModel expense) {
    final expenseTotal = expense.cost * expense.quantity;

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showExpenseDetail(expense),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      expense.libelle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: expense.status == "Validé"
                          ? const Color(0xFFEAF7EF)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expense.status,
                      style: TextStyle(
                        color: expense.status == "Validé"
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFB45309),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (expense.description.isNotEmpty) ...[
                Text(
                  expense.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${expense.quantity}x ${expense.cost.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${expenseTotal.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(expense.createdAt),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0B4F2A), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _expenseTrajet(ExpenseModel expense) {
    final route = expense.tripRoute?.trim();
    if (route != null && route.isNotEmpty) return route;
    final description = expense.description.trim();
    if (description.isNotEmpty) return description;
    return 'Trajet non renseigné';
  }

  String _expenseMatricule(ExpenseModel expense) {
    final matricule = expense.busMatricule?.trim();
    if (matricule != null && matricule.isNotEmpty) return matricule;
    final source = '${expense.libelle} ${expense.description} ${expense.note}';
    final match = RegExp(
      r'(?:matricule|bus)\s*[:\-]?\s*([A-Za-z0-9\- ]{3,})',
      caseSensitive: false,
    ).firstMatch(source);
    final value = match?.group(1)?.trim();
    if (value != null && value.isNotEmpty) return value;
    return 'Matricule non renseigné';
  }

  _CollectorReservationRecord? _latestReservation() {
    return _CollectorReservationStore.activeReservation;
  }

  _CollectorReservationRecord? _latestHistoricalReservation() {
    final reservations = _CollectorReservationStore.historicalReservations;
    if (reservations.isEmpty) return null;
    return reservations.first;
  }

  String _reservationRoute(_CollectorReservationRecord reservation) {
    return '${reservation.departure} -> ${reservation.destination}';
  }

  // ignore: unused_element
  Widget _buildModernExpenseCard(ExpenseModel expense) {
    final statusColor = _getStatusColor(expense.status);
    final fromQr = expense.qrCode != null;
    final trajet = _expenseTrajet(expense);
    final matricule = _expenseMatricule(expense);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showExpenseDetail(expense),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: statusColor.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      fromQr
                          ? Icons.qr_code_2_rounded
                          : Icons.receipt_long_rounded,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.libelle,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        if (expense.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            expense.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.route_rounded,
                                    color: Color(0xFFE53935),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      trajet,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_bus_rounded,
                                    color: Color(0xFFE53935),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Bus: $matricule',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // n'affiche pas le label 'En cours' sur la carte
                  if (expense.status != 'En cours')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        expense.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Color(0xFF94A3B8),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _formatDate(expense.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        fromQr
                            ? Icons.qr_code_rounded
                            : Icons.edit_note_rounded,
                        color: const Color(0xFF64748B),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        fromQr ? 'QR' : 'Manuel',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Carte de dépense
  // ignore: unused_element
  Widget _buildExpenseCard(ExpenseModel expense) {
    final totalAmount = expense.cost * expense.quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Libellé et montant total
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.libelle,
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (expense.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expense.description,
                        style: const TextStyle(
                          color: Color(0xFF5F6B86),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${totalAmount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Détails: coût, quantité
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${expense.cost.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'par unité',
                        style: TextStyle(
                          color: Color(0xFF5F6B86),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${expense.quantity}',
                        style: const TextStyle(
                          color: Color(0xFFFF9500),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'quantité',
                        style: TextStyle(
                          color: Color(0xFF5F6B86),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (expense.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Note: ${expense.note}',
                style: const TextStyle(
                  color: Color(0xFF5F6B86),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Date et statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(expense.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF9AA4BA),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.qrCode != null ? 'QR détecté' : 'Entrée manuelle',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    expense.status,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense.status,
                  style: TextStyle(
                    color: _getStatusColor(expense.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (expense.status == 'En cours') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ExpenseStore().updateExpenseStatus(expense.id, 'Validé');
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ExpenseStore().updateExpenseStatus(expense.id, 'Rejeté');
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Rejeter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "En cours":
        return const Color(0xFFFF9500);
      case "Historique":
        return const Color(0xFF16A34A);
      case "Validé":
        return const Color(0xFF16A34A);
      case "Rejeté":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF5F6B86);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hours:$minutes';
  }
}

