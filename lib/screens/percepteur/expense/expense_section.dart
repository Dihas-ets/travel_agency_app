import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fofanavoyage/models/expense_model.dart';
import 'package:fofanavoyage/models/store/expense_store.dart';
import 'package:fofanavoyage/screens/percepteur/parts/reservation_flow.dart';
import 'package:fofanavoyage/screens/percepteur/expense/manual_expense_page.dart';
import 'package:fofanavoyage/screens/percepteur/expense/qr_scanner_page.dart';
import 'package:fofanavoyage/services/cash_service.dart';

// Ecran de consultation des depenses du percepteur et de leur synthese.

class PercepteurDepenseContent extends StatefulWidget {
  const PercepteurDepenseContent({super.key});

  @override
  State<PercepteurDepenseContent> createState() =>
      _PercepteurDepenseContentState();
}

class _PercepteurDepenseContentState extends State<PercepteurDepenseContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final expenseStore = ExpenseStore();
  final CashService _cashService = CashService();
  bool _showPercepteurBalance = false;
  CashSummary? _cashSummary;
  String? _cashError;
  bool _cashLoading = true;
  bool _expensesLoading = true;
  String? _expenseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadCashSummary();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (mounted) {
      setState(() {
        _expensesLoading = true;
        _expenseError = null;
      });
    }
    try {
      await expenseStore.refresh();
      if (!mounted) return;
      setState(() => _expensesLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _expensesLoading = false;
        _expenseError = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('FormatException: ', '');
      });
    }
  }

  Future<void> _loadCashSummary() async {
    setState(() {
      _cashLoading = true;
      _cashError = null;
    });
    try {
      final summary = await _cashService.getSummary();
      if (!mounted) return;
      setState(() {
        _cashSummary = summary;
        _cashLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cashLoading = false;
        _cashError = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
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
                    _buildWalletCard(),
                    const SizedBox(height: 8),
                    _buildExpenseMenu(expenses),
                    const SizedBox(height: 10),
                    _buildAssignmentHeader(),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            heroTag: 'scan-expense-invoice',
                            tooltip: 'Scanner une facture',
                            onPressed: _openScanner,
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            child: const Icon(Icons.qr_code_scanner_rounded),
                          ),
                          const SizedBox(height: 12),
                          FloatingActionButton.extended(
                            heroTag: 'create-manual-expense',
                            onPressed: _openManualExpense,
                            backgroundColor: const Color(0xFF0B4F2A),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Saisie manuelle'),
                          ),
                        ],
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

  List<ExpenseModel> _ongoingExpenses(List<ExpenseModel> expenses) {
    return expenses.where((expense) => expense.isDraft).toList();
  }

  List<ExpenseModel> _historicalExpenses(List<ExpenseModel> expenses) {
    return expenses.where((expense) => !expense.isDraft).toList();
  }

  Future<void> _openScanner() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );
  }

  Future<void> _openManualExpense() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ManualExpensePage()),
    );
    if (created == true) {
      await _loadExpenses();
    }
  }

  void _openRechargePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _PercepteurWalletRechargePage(),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDashboardHeader(List<ExpenseModel> expenses) {
    final ongoingExpenses = expenses
        .where((expense) => expense.isDraft)
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
                          'Total brouillon',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseMenu(List<ExpenseModel> expenses) {
    final ongoingExpenses = _ongoingExpenses(expenses);
    final historicalExpenses = _historicalExpenses(expenses);
    final ongoingTotal = ongoingExpenses.fold<double>(
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
            title: 'Brouillons',
            detail: '${ongoingTotal.toStringAsFixed(0)} FCFA',
            onTap: () => _tabController.animateTo(0),
          ),
          const SizedBox(width: 10),
          _buildMenuButton(
            selected: _tabController.index == 1,
            icon: Icons.history_rounded,
            title: 'Historique',
            detail:
                '${historicalExpenses.length} dépense${historicalExpenses.length > 1 ? 's' : ''}',
            onTap: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    final balanceText = _cashLoading
        ? 'Chargement...'
        : _cashError != null
        ? 'Indisponible'
        : _showPercepteurBalance
        ? '${(_cashSummary?.balance ?? 0).toStringAsFixed(0)} FCFA'
        : '****** FCFA';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B4F2A), Color(0xFF168A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solde percepteur',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balanceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _showPercepteurBalance ? 'Cacher' : 'Afficher',
              onPressed: () => setState(
                () => _showPercepteurBalance = !_showPercepteurBalance,
              ),
              icon: Icon(
                _showPercepteurBalance
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 42,
              height: 42,
              child: ElevatedButton(
                onPressed: _openRechargePage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B4F2A),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentHeader() {
    return const SizedBox.shrink();
  }

  // ignore: unused_element
  Widget _buildTripHeader(List<ExpenseModel> expenses) {
    final isOngoing = _tabController.index == 0;
    final reservation = isOngoing
        ? PercepteurReservationStore.activeReservation
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

  // Brouillons en attente de traitement.
  Widget _buildOngoingTab() {
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: expenseStore.expensesNotifier,
      builder: (context, expenses, _) {
        final ongoingExpenses = _ongoingExpenses(expenses)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (_expensesLoading && expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_expenseError != null && expenses.isEmpty) {
          return _buildExpenseLoadError();
        }
        if (ongoingExpenses.isEmpty) {
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
                  'Aucun brouillon en attente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Les dépenses soumises en brouillon apparaîtront ici.',
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
          itemCount: ongoingExpenses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            return _buildModernExpenseCard(ongoingExpenses[index]);
          },
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildOngoingTripCard(
    PercepteurReservationRecord reservation,
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
        final historicalExpenses = _historicalExpenses(expenses)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (_expensesLoading && expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_expenseError != null && expenses.isEmpty) {
          return _buildExpenseLoadError();
        }
        if (historicalExpenses.isEmpty) {
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
                  'Les dépenses validées ou rejetées apparaîtront ici.',
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
          itemCount: historicalExpenses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            return _buildModernExpenseCard(historicalExpenses[index]);
          },
        );
      },
    );
  }

  Widget _buildExpenseLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFB42318),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              _expenseError ?? 'Impossible de charger les dépenses.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadExpenses,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHistoricalReservationCard(
    PercepteurReservationRecord reservation,
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
                          : '${expenses.where((e) => e.status == "validé").length}/${expenses.length} validées',
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
              child: SingleChildScrollView(
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
                    _buildExpenseDetailRow(
                      Icons.numbers_rounded,
                      'Code',
                      expense.code,
                    ),
                    _buildExpenseDetailRow(
                      Icons.verified_rounded,
                      'Statut',
                      expense.statusLabel,
                    ),
                    _buildExpenseDetailRow(
                      Icons.storefront_rounded,
                      'Fournisseur',
                      expense.supplierName ?? 'Non renseigné',
                    ),
                    _buildExpenseDetailRow(
                      Icons.business_rounded,
                      'Agence',
                      expense.agencyName ?? 'Agence ${expense.agencyId ?? '-'}',
                    ),
                    for (final item in expense.items) ...[
                      _buildExpenseDetailRow(
                        Icons.receipt_long_rounded,
                        item.designation,
                        '${item.quantity} ${item.unit} × ${item.unitPrice.toStringAsFixed(2)} HT · '
                        '${item.amountTtc.toStringAsFixed(2)} TTC',
                      ),
                    ],
                    _buildExpenseDetailRow(
                      Icons.account_balance_wallet_rounded,
                      'Total TTC',
                      '${expense.totalAmount.toStringAsFixed(2)} FCFA',
                    ),
                    _buildExpenseDetailRow(
                      Icons.sticky_note_2_rounded,
                      'Note',
                      expense.note.isEmpty ? 'Aucune note' : expense.note,
                    ),
                    _buildExpenseDetailRow(
                      Icons.source_rounded,
                      'Source',
                      expense.source == 'mecef_verified'
                          ? 'Facture MECeF vérifiée'
                          : 'Saisie manuelle',
                    ),
                    _buildExpenseDetailRow(
                      Icons.schedule_rounded,
                      'Date',
                      _formatDate(expense.createdAt),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReservationExpenseSheet(
    PercepteurReservationRecord reservation,
    List<ExpenseModel> expenses,
  ) {
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
                              'Aucune dépense enregistrée pour ce trajet.',
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
                                const SizedBox(height: 12),
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
              Text(
                expense.libelle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: expense.status == "validé"
                        ? const Color(0xFFEAF7EF)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    expense.statusLabel,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      color: expense.status == "validé"
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFB45309),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
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
                    '${_quantityLabel(expense)} x ${expense.cost.toStringAsFixed(0)} FCFA',
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

  String _quantityLabel(ExpenseModel expense) {
    final unit = expense.quantityUnit.trim();
    if (unit.isEmpty) return '${expense.quantity}';
    return '${expense.quantity} $unit';
  }

  PercepteurReservationRecord? _latestHistoricalReservation() {
    final reservations = PercepteurReservationStore.historicalReservations;
    if (reservations.isEmpty) return null;
    return reservations.first;
  }

  String _reservationRoute(PercepteurReservationRecord reservation) {
    return '${reservation.departure} -> ${reservation.destination}';
  }

  // ignore: unused_element
  Widget _buildModernExpenseCard(ExpenseModel expense) {
    final statusColor = _getStatusColor(expense.status);
    final firstItem = expense.items.isEmpty ? null : expense.items.first;

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
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      expense.source == 'mecef_verified'
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
                          expense.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstItem?.designation ?? 'Dépense sans ligne',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    expense.statusLabel,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (expense.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  expense.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
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
                  Text(
                    '${expense.totalAmount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    expense.source == 'mecef_verified'
                        ? Icons.qr_code_rounded
                        : Icons.edit_note_rounded,
                    color: const Color(0xFF64748B),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    expense.source == 'mecef_verified'
                        ? 'Facture MECeF'
                        : 'Saisie manuelle',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${expense.items.length} ligne${expense.items.length == 1 ? '' : 's'}',
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
                        _quantityLabel(expense),
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
                  expense.statusLabel,
                  style: TextStyle(
                    color: _getStatusColor(expense.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "brouillon":
        return const Color(0xFFFF9500);
      case "validé":
        return const Color(0xFF16A34A);
      case "rejeté":
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

class _PercepteurWalletRechargePage extends StatefulWidget {
  const _PercepteurWalletRechargePage();

  @override
  State<_PercepteurWalletRechargePage> createState() =>
      _PercepteurWalletRechargePageState();
}

class _PercepteurWalletRechargePageState
    extends State<_PercepteurWalletRechargePage> {
  final _amountController = TextEditingController();
  static final Uri _feexPayApiUri = Uri.parse('https://api.feexpay.me');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openFeexPay() async {
    final opened = await launchUrl(
      _feexPayApiUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir la page FeexPay."),
          backgroundColor: Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const deepGreen = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recharge portefeuille',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: deepGreen,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: deepGreen.withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.add_card_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recharger le solde',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Le paiement est finalisé sur la page FeexPay.',
                          style: TextStyle(
                            color: Color(0xFFD8F3E2),
                            fontSize: 13.4,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                ),
                decoration: InputDecoration(
                  labelText: 'Montant a recharger',
                  hintText: 'Ex: 50000',
                  suffixText: 'FCFA',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(Icons.payments_rounded, color: green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: green, width: 1.4),
                  ),
                  labelStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _openFeexPay,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Recharger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
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
