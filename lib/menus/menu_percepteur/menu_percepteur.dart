import 'package:flutter/material.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/services/cash_service.dart';
import 'package:code_initial/services/staff_ticket_service.dart';
import 'package:code_initial/screens/percepteur/parts/assignments_section.dart';
import 'package:code_initial/screens/percepteur/parts/history_news_section.dart';
import 'package:code_initial/screens/percepteur/parts/ticket_validation_section.dart';
import 'package:code_initial/screens/percepteur/parts/reservation_flow.dart';
// Menu Voyage percepteur et boutons d action d acces rapide.

class PercepteurVoyageContent extends StatelessWidget {
  const PercepteurVoyageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        PercepteurLiveOverview(),
        SizedBox(height: 22),
        PercepteurVoyageMenu(),
      ],
    );
  }
}

class PercepteurLiveOverview extends StatefulWidget {
  const PercepteurLiveOverview({super.key});

  @override
  State<PercepteurLiveOverview> createState() => _PercepteurLiveOverviewState();
}

class _PercepteurLiveOverviewState extends State<PercepteurLiveOverview> {
  late Future<_PercepteurOverviewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadOverview();
  }

  Future<_PercepteurOverviewData> _loadOverview() async {
    try {
      final tickets = await StaffTicketService().getTicketsDuJour();
      final summary = await CashService().getSummary();
      final user = SessionStore.currentUser;
      return _PercepteurOverviewData(
        fullName: user?.fullName ?? 'Chargement...',
        role: user?.role ?? 'staff',
        ticketCount: tickets.length,
        balance: summary.balance,
      );
    } catch (_) {
      final user = SessionStore.currentUser;
      return _PercepteurOverviewData(
        fullName: user?.fullName ?? 'Utilisateur',
        role: user?.role ?? 'staff',
        ticketCount: 0,
        balance: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PercepteurOverviewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _PercepteurOverviewData();
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue, ${data.fullName}',
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rôle : ${data.role.toUpperCase()}',
                style: const TextStyle(
                  color: Color(0xFF5F6B86),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      label: 'Tickets du jour',
                      value: '${data.ticketCount}',
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoPill(
                      label: 'Caisse',
                      value: '${data.balance.toStringAsFixed(0)} F',
                      color: const Color(0xFF0B4F2A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PercepteurOverviewData {
  final String fullName;
  final String role;
  final int ticketCount;
  final double balance;

  const _PercepteurOverviewData({
    this.fullName = 'Utilisateur',
    this.role = 'staff',
    this.ticketCount = 0,
    this.balance = 0,
  });
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class PercepteurVoyageMenu extends StatelessWidget {
  const PercepteurVoyageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Menu',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        MenuPercepteurButton(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Affectations',
          isWide: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PercepteurAssignmentsPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MenuPercepteurButton(
                icon: Icons.login_rounded,
                label: 'Connexion',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PercepteurConnectionPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MenuPercepteurButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Validation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TicketValidationPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MenuPercepteurButton(
                icon: Icons.confirmation_number_rounded,
                label: 'Réservation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PercepteurReservationPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MenuPercepteurButton(
                icon: Icons.history_rounded,
                label: 'Historique',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PercepteurHistoryPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MenuPercepteurButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const MenuPercepteurButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: isWide ? 84 : 124),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 16 : 14,
            vertical: isWide ? 14 : 15,
          ),
          decoration: BoxDecoration(
            color: isWide ? const Color(0xFFF8FBFF) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: green.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: green.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  children: [
                    MenuPercepteurButtonIcon(icon: icon),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: green,
                      size: 22,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MenuPercepteurButtonIcon(icon: icon),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class MenuPercepteurButtonIcon extends StatelessWidget {
  final IconData icon;

  const MenuPercepteurButtonIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: green.withValues(alpha: 0.20)),
      ),
      child: Icon(icon, color: green, size: 26),
    );
  }
}
