import 'package:flutter/material.dart';
import 'package:code_initial/models/user_model.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/menus/menu_percepteur/menu_percepteur.dart';
import 'package:code_initial/menus/menu_percepteur/menu_profil_percepteur.dart';
import 'package:code_initial/screens/percepteur/parts/assignments_section.dart';
import 'package:code_initial/screens/percepteur/parts/ticket_validation_section.dart';
import 'package:code_initial/screens/controleur/controleur_history_section.dart';
import 'package:code_initial/services/staff_ticket_service.dart';

class ControleurVoyageContent extends StatelessWidget {
  const ControleurVoyageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        ControleurLiveOverview(),
        SizedBox(height: 22),
        ControleurVoyageMenu(),
      ],
    );
  }
}

class ControleurLiveOverview extends StatefulWidget {
  const ControleurLiveOverview({super.key});

  @override
  State<ControleurLiveOverview> createState() => _ControleurLiveOverviewState();
}

class _ControleurLiveOverviewState extends State<ControleurLiveOverview> {
  late Future<_ControleurOverviewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadOverview();
  }

  Future<_ControleurOverviewData> _loadOverview() async {
    try {
      final tickets = await StaffTicketService().getTicketsDuJour();
      final user = SessionStore.currentUser;
      return _ControleurOverviewData(
        fullName: user?.fullName ?? 'Chargement...',
        role: user?.role ?? 'controlleur',
        ticketCount: tickets.length,
      );
    } catch (_) {
      final user = SessionStore.currentUser;
      return _ControleurOverviewData(
        fullName: user?.fullName ?? 'Utilisateur',
        role: user?.role ?? 'controlleur',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ControleurOverviewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _ControleurOverviewData();
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
              _InfoPill(
                label: 'Tickets du jour',
                value: '${data.ticketCount}',
                color: const Color(0xFF16A34A),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControleurOverviewData {
  final String fullName;
  final String role;
  final int ticketCount;

  const _ControleurOverviewData({
    this.fullName = 'Utilisateur',
    this.role = 'controlleur',
    this.ticketCount = 0,
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

class ControleurVoyageMenu extends StatelessWidget {
  const ControleurVoyageMenu({super.key});

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
          label: 'Affectation',
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
      ],
    );
  }
}

class ControleurMainMenuSheet extends StatelessWidget {
  const ControleurMainMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.86,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Image.asset(
                'assets/images/logo_fofana_no_background.png',
                height: 62,
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<UserModel?>(
                valueListenable: SessionStore.currentUserNotifier,
                builder: (context, user, _) {
                  final photoUrl = user?.photoUrl;
                  return CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF58648D),
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 58,
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<UserModel?>(
                valueListenable: SessionStore.currentUserNotifier,
                builder: (context, user, _) {
                  return Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName : 'Chargement...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              MenuPercepteurOptionTile(
                icon: Icons.account_circle_outlined,
                title: 'Profil',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              MenuPercepteurOptionTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Mes affectations',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const PercepteurAssignmentsPage(),
                    ),
                  );
                },
              ),
              MenuPercepteurOptionTile(
                icon: Icons.history_rounded,
                title: 'Tickets scannes',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const ControleurHistoryPage(),
                    ),
                  );
                },
              ),
              MenuPercepteurOptionTile(
                icon: Icons.logout_rounded,
                title: 'Deconnexion',
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcomepage', (_) => false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
