import 'package:flutter/material.dart';

/// Page racine de l'espace chauffeur.
/// Garde le même shell (header, onglets, bottom nav) que PercepteurHomePage.
class ChauffeurHomePage extends StatefulWidget {
  const ChauffeurHomePage({super.key});

  @override
  State<ChauffeurHomePage> createState() => _ChauffeurHomePageState();
}

class ChauffeurTab {
  final String title;
  final IconData icon;
  const ChauffeurTab(this.title, this.icon);
}

class _ChauffeurHomePageState extends State<ChauffeurHomePage> {
  int _currentIndex = 0;

  // ⚠️ À adapter selon les vraies fonctionnalités du chauffeur
  final List<ChauffeurTab> _tabs = const [
    ChauffeurTab('Trajet', Icons.alt_route_rounded),
    ChauffeurTab('Colis', Icons.inventory_2_rounded),
    ChauffeurTab('Historique', Icons.history_rounded),
    ChauffeurTab('Profil', Icons.person_rounded),
  ];

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChauffeurMainMenuSheet(),
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
                      child: _ChauffeurHeaderIconButton(
                        icon: Icons.menu_rounded,
                        onTap: _openMainMenu,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_fofana_no_background.png',
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: _ChauffeurNotificationIconButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Espace chauffeur',
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
                Expanded(child: _ChauffeurTabContent(tab: currentTab)),
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
                      border: isActive
                          ? Border.all(color: Colors.white.withValues(alpha: 0.30))
                          : null,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: navigationGreen.withValues(alpha: 0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isActive ? Colors.white : const Color(0xFF7B849B),
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
                              color: isActive ? Colors.white : const Color(0xFF7B849B),
                              fontSize: 10.8,
                              fontWeight: isActive ? FontWeight.w900 : FontWeight.w800,
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

/// Contenu affiché selon l'onglet sélectionné.
/// ⚠️ Placeholder — à remplacer par le vrai contenu métier de chaque onglet.
class _ChauffeurTabContent extends StatelessWidget {
  final ChauffeurTab tab;
  const _ChauffeurTabContent({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Contenu : ${tab.title}',
        style: const TextStyle(
          color: Color(0xFF5F6B86),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChauffeurHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ChauffeurHeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0B4F2A).withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF0B4F2A)),
        onPressed: onTap,
      ),
    );
  }
}

class _ChauffeurNotificationIconButton extends StatelessWidget {
  const _ChauffeurNotificationIconButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0B4F2A).withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0B4F2A)),
        onPressed: () {
          // à brancher plus tard sur la vraie section notifications chauffeur
        },
      ),
    );
  }
}

/// Menu principal (bottom sheet), ouvert via l'icône ☰.
/// ⚠️ Placeholder minimal — à enrichir (déconnexion, paramètres, etc.)
class _ChauffeurMainMenuSheet extends StatelessWidget {
  const _ChauffeurMainMenuSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Menu chauffeur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0B4F2A),
              ),
            ),
            SizedBox(height: 20),
            // TODO : ajouter les options réelles (profil, déconnexion, etc.)
          ],
        ),
      ),
    );
  }
}