import 'package:flutter/material.dart';
import 'package:code_initial/presentation/pages/collector/parts/menu_profile_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/notifications_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/voyage_menu_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/history_news_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/assignments_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/ticket_validation_section.dart';
import 'package:code_initial/presentation/pages/controller/controller_history_section.dart';
import 'package:code_initial/presentation/pages/controller/controller_profile_section.dart';
// Page racine de l espace controleur.
// Les trois actions metier du voyage reutilisent exactement les pages du
// percepteur; seuls le shell, l'historique des scans et le profil changent.

class ControllerHomePage extends StatefulWidget {
  const ControllerHomePage({super.key});

  @override
  State<ControllerHomePage> createState() => ControllerHomePageState();
}

class ControllerHomePageState extends State<ControllerHomePage> {
  int _currentIndex = 0;

  final List<CollectorTab> _tabs = const [
    CollectorTab('Voyage', Icons.directions_bus_filled_rounded),
    CollectorTab('Historique', Icons.history_rounded),
    CollectorTab('Profil', Icons.person_rounded),
  ];

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ControllerMainMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];
    const navigationGreen = Color(0xFF16A34A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFFFFFFF), Color(0xFFFFF9F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CollectorHeaderIconButton(
                        icon: Icons.menu_rounded,
                        onTap: _openMainMenu,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_fofana_no_background.png',
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CollectorHeaderIconButton(
                        icon: Icons.qr_code_scanner_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TicketValidationPage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Espace controleur',
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTab.title,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: ControllerTabContent(tab: currentTab)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: navigationGreen.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == _currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? navigationGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF7B849B),
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tab.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF7B849B),
                              fontSize: 10.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ControllerTabContent extends StatelessWidget {
  final CollectorTab tab;

  const ControllerTabContent({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    switch (tab.title) {
      case 'Voyage':
        return const ControllerVoyageContent();
      case 'Historique':
        return const ControllerHistoryTabContent();
      case 'Profil':
        return const ControllerProfileTabContent();
      default:
        return const SizedBox.shrink();
    }
  }
}

class ControllerVoyageContent extends StatelessWidget {
  const ControllerVoyageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        CollectorNewsSection(),
        SizedBox(height: 22),
        ControllerVoyageMenu(),
      ],
    );
  }
}

class ControllerVoyageMenu extends StatelessWidget {
  const ControllerVoyageMenu({super.key});

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
        CollectorMenuButton(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Affectation',
          isWide: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CollectorAssignmentsPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CollectorMenuButton(
                icon: Icons.login_rounded,
                label: 'Connexion',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CollectorConnectionPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CollectorMenuButton(
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

class ControllerMainMenuSheet extends StatelessWidget {
  const ControllerMainMenuSheet({super.key});

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
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF58648D),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Controleur Fofana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              CollectorMenuOptionTile(
                icon: Icons.account_circle_outlined,
                title: 'Profil',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              CollectorMenuOptionTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Mes affectations',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const CollectorAssignmentsPage(),
                    ),
                  );
                },
              ),
              CollectorMenuOptionTile(
                icon: Icons.history_rounded,
                title: 'Tickets scannes',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const ControllerHistoryPage(),
                    ),
                  );
                },
              ),
              CollectorMenuOptionTile(
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


