import 'package:flutter/material.dart';
import 'package:code_initial/menus/menu_controleur/menu_controleur.dart';
import 'package:code_initial/screens/percepteur/parts/history_news_section.dart';
import 'package:code_initial/screens/percepteur/parts/notifications_section.dart';
import 'package:code_initial/screens/percepteur/parts/ticket_validation_section.dart';
import 'package:code_initial/screens/controleur/controleur_history_section.dart';
import 'package:code_initial/screens/controleur/controleur_profile_section.dart';

// Page racine de l espace controleur.
// Les trois actions metier du voyage reutilisent exactement les pages du
// percepteur; seuls le shell, l'historique des scans et le profil changent.

class ControleurHomePage extends StatefulWidget {
  const ControleurHomePage({super.key});

  @override
  State<ControleurHomePage> createState() => ControleurHomePageState();
}

class ControleurHomePageState extends State<ControleurHomePage> {
  int _currentIndex = 0;

  final List<PercepteurTab> _tabs = const [
    PercepteurTab('Voyage', Icons.directions_bus_filled_rounded),
    PercepteurTab('Historique', Icons.history_rounded),
    PercepteurTab('Profil', Icons.person_rounded),
  ];

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ControleurMainMenuSheet(),
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
                      child: PercepteurHeaderIconButton(
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
                      child: PercepteurHeaderIconButton(
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
                Expanded(child: ControleurTabContent(tab: currentTab)),
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

class ControleurTabContent extends StatelessWidget {
  final PercepteurTab tab;

  const ControleurTabContent({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    switch (tab.title) {
      case 'Voyage':
        return const ControleurVoyageContent();
      case 'Historique':
        return const ControleurHistoryTabContent();
      case 'Profil':
        return const ControleurProfileTabContent();
      default:
        return const SizedBox.shrink();
    }
  }
}
