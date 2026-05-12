import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:code_initial/presentation/pages/tarifs/tarifs_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<_HomeTab> _tabs = const [
    _HomeTab(
      title: 'Accueil',
      icon: Icons.home_rounded,
      headline: 'Bienvenue chez STM',
      description:
          'Réservez vos voyages, suivez vos colis et gérez votre profil.',
    ),
    _HomeTab(
      title: 'Voyage',
      icon: Icons.directions_bus_filled_rounded,
      headline: 'Vos voyages',
      description:
          'Consultez les destinations, les horaires et préparez votre trajet.',
    ),
    _HomeTab(
      title: 'Colis',
      icon: Icons.inventory_2_rounded,
      headline: 'Vos colis',
      description: 'Envoyez et suivez vos colis en toute simplicité avec STM.',
    ),
    _HomeTab(
      title: 'Profil',
      icon: Icons.person_rounded,
      headline: 'Votre profil',
      description:
          'Retrouvez vos informations personnelles et vos préférences.',
    ),
  ];

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MainMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];
    final isHomeTab = _currentIndex == 0;
    final isVoyageTab = _currentIndex == 1;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FBFF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFF9F5),
                ],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
          SafeArea(
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
                        child: _HeaderIconButton(
                          icon: Icons.menu_rounded,
                          onTap: _openMainMenu,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_stm_no_background.png',
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

                  SizedBox(height: isHomeTab ? 18 : 24),

                  if (!isHomeTab) ...[
                    Text(
                      currentTab.headline,
                      style: const TextStyle(
                        color: Color(0xFF060663),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTab.description,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontSize: 14.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isHomeTab
                          ? const _ConnectedHomeContent(key: ValueKey('home'))
                          : isVoyageTab
                          ? const _VoyageTabContent(key: ValueKey('voyage'))
                          : _HomeTabContent(
                              key: ValueKey(currentTab.title),
                              tab: currentTab,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF060663).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == _currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF060663)
                          : Colors.transparent,
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
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF7B849B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
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

class _ConnectedHomeContent extends StatefulWidget {
  const _ConnectedHomeContent({super.key});

  @override
  State<_ConnectedHomeContent> createState() => _ConnectedHomeContentState();
}

class _ConnectedHomeContentState extends State<_ConnectedHomeContent> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  bool? _isLocationActive;

  @override
  void initState() {
    super.initState();
    _checkLocationActive();
  }

  Future<void> _checkLocationActive() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLocationActive = false);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final active =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (mounted) setState(() => _isLocationActive = active);
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bonjour, bienvenue',
            style: TextStyle(
              color: Color(0xFF060663),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Trouvez une agence proche, suivez les actualités et consultez vos tarifs au Bénin.',
            style: TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 14.5,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          if (_isLocationActive == true)
            const _AgencyMapCard()
          else
            _LocationDisabledCard(isLoading: _isLocationActive == null),

          const SizedBox(height: 18),

          const _NewsSection(),

          const SizedBox(height: 24),

          const Text(
            'Tarifs',
            style: TextStyle(
              color: Color(0xFF060663),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),

          // ── Champs tarifs : Départ & Destination ───────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Départ
                _BeninCityField(
                  controller: _departureController,
                  label: 'De',
                  hint: 'Ville de départ',
                  onTap: () async {
                    // Ouvre la sélection via la même liste que TarifsPage (Bénin)
                    // (la sélection UI est gérée dans le widget)
                    // On déclenche le picker interne du widget.
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE6E9F2)),

                // Destination
                _BeninCityField(
                  controller: _destinationController,
                  label: 'À',
                  hint: 'Ville de destination',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bouton rechercher
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TarifsPage(
                      initialDepart: _departureController.text,
                      initialDestination: _destinationController.text,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text('Rechercher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF80C0D),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeninCityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _BeninCityField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  // Liste Bénin (à adapter si vous avez une liste officielle interne)
  static const List<String> _beninCities = <String>[
    'Cotonou',
    'Porto-Novo',
    'Abomey-Calavi',
    'Abomey',
    'Allada',
    'Bohicon',
    'Kétou',
    'Savalou',
    'Ouidah',
    'Lokossa',
    'Kandi',
    'Parakou',
    'Djougou',
    'Natitingou',
    'Bembèrèkè',
    'Malanville',
    'Tanguiéta',
  ];

  Future<void> _showCityPicker(BuildContext context, String pickerTitle) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final picked = controller.text.trim();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pickerTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _beninCities.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final city = _beninCities[index];
                    final isSelected = picked == city;

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) {
                        controller.text = city;
                        Navigator.pop(context);
                      },
                      activeColor: const Color(0xFFF80C0D),
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        city,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFF80C0D),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: controller,
                  readOnly: true,
                  showCursor: false,
                  onTap: () async {
                    onTap();
                    await _showCityPicker(
                      context,
                      label == 'De'
                          ? 'Choisir la ville de départ'
                          : 'Choisir la ville d’arrivée',
                    );
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _AgencyMapCard extends StatefulWidget {
  const _AgencyMapCard();

  @override
  State<_AgencyMapCard> createState() => _AgencyMapCardState();
}

class _LocationDisabledCard extends StatelessWidget {
  final bool isLoading;

  const _LocationDisabledCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF3FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    color: Color(0xFF060663),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Localisation requise',
                  style: TextStyle(
                    color: Color(0xFF060663),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF060663).withValues(alpha: 0.08),
              ),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Activez la localisation pour voir les agences proches.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5F6B86),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyMapCardState extends State<_AgencyMapCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF3FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.map_rounded, color: Color(0xFF060663)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Agences proches',
                  style: const TextStyle(
                    color: Color(0xFF060663),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                'Google Maps',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Zone "maps" (placeholder sans lib maps)
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF060663).withValues(alpha: 0.08),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_rounded,
                size: 54,
                color: Color(0xFF060663),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsSection extends StatefulWidget {
  const _NewsSection();

  @override
  State<_NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<_NewsSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _pageIndex = 0;

  final List<Map<String, String>> _news = const [
    {
      'title': 'STM : Ouverture de nouvelles agences à Cotonou',
      'date': '10 mai 2026',
      'image': 'assets/images/welcome_image.jpg',
    },
    {
      'title': 'Réduction transport cette semaine au Bénin',
      'date': '08 mai 2026',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Suivez vos colis en temps réel avec STM',
      'date': '06 mai 2026',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Conseils voyage : préparez vos documents essentiels',
      'date': '04 mai 2026',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _pageIndex = (_pageIndex + 1) % _news.length);
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
    const red = Color(0xFFF80C0D);
    const deepBlue = Color(0xFF060663);

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
                  color: deepBlue,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voir plus des actualités (à implémenter)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red, width: 1.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Voir plus',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
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
            itemCount: _news.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = _news[index];
              final imagePath =
                  item['image'] ?? 'assets/images/welcome_image.jpg';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF8FBFF),
                          child: const Icon(Icons.image_not_supported_rounded),
                        ),
                      ),

                      // overlay lisibilité
                      Container(color: Colors.black.withValues(alpha: 0.42)),

                      // petit cadre rouge sur le haut (brutaliste)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 12,
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: red.withValues(alpha: 0.65),
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.newspaper_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['date'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // texte en bas
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.2,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // indicateur de slide simple (petits points)
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_news.length, (i) {
            final isActive = i == _pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 10,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? red : Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Placeholder minimal, pour éviter de dépendre d’un fichier externe inconnu.
class TarifsPlaceholderCard extends StatelessWidget {
  const TarifsPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Liste des tarifs (placeholder)',
        style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  final _HomeTab tab;

  const _HomeTabContent({required super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          tab.description,
          style: const TextStyle(
            color: Color(0xFF5F6B86),
            fontSize: 14.5,
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VoyageTabContent extends StatelessWidget {
  const _VoyageTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _NewsSection(),

            const SizedBox(height: 18),

            _VoyageActionsCard(
              onReservation: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reservation (à implémenter)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onReprogram: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reprogrammation (à implémenter)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onHistory: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historique (à implémenter)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onTarifs: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TarifsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VoyageActionsCard extends StatelessWidget {
  final VoidCallback onReservation;
  final VoidCallback onReprogram;
  final VoidCallback onHistory;
  final VoidCallback onTarifs;

  const _VoyageActionsCard({
    required this.onReservation,
    required this.onReprogram,
    required this.onHistory,
    required this.onTarifs,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF060663);
    const red = Color(0xFFF80C0D);

    Widget actionTile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: deepBlue.withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: red.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, size: 20, color: red),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepBlue,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vos options voyage',
              style: TextStyle(
                color: deepBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                actionTile(
                  icon: Icons.event_available_rounded,
                  label: 'Reservation',
                  onTap: onReservation,
                ),
                const SizedBox(width: 12),
                actionTile(
                  icon: Icons.schedule_send_rounded,
                  label: 'Reprogrammation',
                  onTap: onReprogram,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                actionTile(
                  icon: Icons.history_rounded,
                  label: 'Historique',
                  onTap: onHistory,
                ),
                const SizedBox(width: 12),
                actionTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Tarifs',
                  onTap: onTarifs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab {
  final String title;
  final IconData icon;
  final String headline;
  final String description;

  const _HomeTab({
    required this.title,
    required this.icon,
    required this.headline,
    required this.description,
  });
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF060663)),
      ),
    );
  }
}

// ===================== MENU (Bottom sheet) =====================

class _MainMenuSheet extends StatefulWidget {
  const _MainMenuSheet();

  @override
  State<_MainMenuSheet> createState() => _MainMenuSheetState();
}

class _MainMenuSheetState extends State<_MainMenuSheet> {
  bool _showAccount = false;

  void _showTerms() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _showAccount
                ? _AccountMenuView(
                    key: const ValueKey('account-view'),
                    scrollController: scrollController,
                    onBack: () => setState(() => _showAccount = false),
                  )
                : _MainMenuView(
                    key: const ValueKey('main-menu-view'),
                    scrollController: scrollController,
                    onClose: () => Navigator.pop(context),
                    onAccountTap: () => setState(() => _showAccount = true),
                    onTermsTap: _showTerms,
                  ),
          ),
        );
      },
    );
  }
}

class _MainMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onClose;
  final VoidCallback onAccountTap;
  final VoidCallback onTermsTap;

  const _MainMenuView({
    required this.scrollController,
    required this.onClose,
    required this.onAccountTap,
    required this.onTermsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF060663).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'v1.0.2',
              style: TextStyle(
                color: const Color(0xFF060663).withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Image.asset('assets/images/logo_stm_no_background.png', height: 62),
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 62),
          ),
          const SizedBox(height: 16),
          const Text(
            'Client STM',
            style: TextStyle(
              color: Color(0xFF060663),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 26),
          const _MenuSectionTitle(
            icon: Icons.grid_view_rounded,
            title: 'Menu principal',
          ),
          const SizedBox(height: 10),
          _MenuOptionTile(
            icon: Icons.account_circle_outlined,
            title: 'Mon compte',
            isSelected: true,
            onTap: onAccountTap,
          ),
          _MenuOptionTile(
            icon: Icons.description_outlined,
            title: "Conditions d'utilisation",
            onTap: onTermsTap,
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Fermer le menu'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF060663),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MenuSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF060663).withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFF57AFC2), size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B849B),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF060663).withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _MenuOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _MenuOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F6FC) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFF47B2A) : Colors.transparent,
              width: 5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF47B2A), size: 27),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF060663),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF7B849B).withValues(alpha: 0.76),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== ACCOUNT VIEW (Fix overflow + editable avatar) =====================

class _AccountMenuView extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;

  const _AccountMenuView({
    required this.scrollController,
    required this.onBack,
    super.key,
  });

  @override
  State<_AccountMenuView> createState() => _AccountMenuViewState();
}

class _AccountMenuViewState extends State<_AccountMenuView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  Future<void> _pickAvatar() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _pickedImage = file);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fix bottom overflow when keyboard opens:
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(24, 12, 24, 28 + bottomInset),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF060663).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: widget.onBack,
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/logo_stm_no_background.png',
                  height: 58,
                ),
              ),
              const SizedBox(width: 46),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Mon compte',
            style: TextStyle(
              color: Color(0xFF060663),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          // ✅ Photo/icon modifiable
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: const Color(0xFF58648D),
                  backgroundImage: _pickedImage == null
                      ? null
                      : FileImage(File(_pickedImage!.path)),
                  child: _pickedImage == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 84,
                        )
                      : null,
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF80C0D),
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const _AccountPanel(),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF060663)),
      ),
    );
  }
}

class _TermsSheet extends StatelessWidget {
  const _TermsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Conditions d'utilisation",
            style: TextStyle(
              color: Color(0xFF060663),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "L'utilisation de l'application STM implique le respect des règles de réservation, de paiement et de transport. Les informations saisies doivent être exactes afin de faciliter les voyages, les colis et l'assistance client.",
            style: TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPanel extends StatefulWidget {
  const _AccountPanel();

  @override
  State<_AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<_AccountPanel> {
  bool _isEditing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Client STM');
    _emailController = TextEditingController(text: 'client@example.com');
    _cityController = TextEditingController(text: 'Cotonou');
    _phoneController = TextEditingController(text: '+229 01 00 00 00 00');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);

    if (_isEditing) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations du compte enregistrées'),
        backgroundColor: Color(0xFF060663),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
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
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFF80C0D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations personnelles',
                      style: TextStyle(
                        color: Color(0xFF060663),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Photo, nom, prénom et contacts',
                      style: TextStyle(
                        color: Color(0xFF5F6B86),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _toggleEdit,
                icon: Icon(
                  _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  size: 18,
                ),
                label: Text(_isEditing ? 'Enregistrer' : 'Modifier'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF80C0D),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _EditableInfoField(
            icon: Icons.badge_rounded,
            title: 'Nom et prénom',
            controller: _nameController,
            enabled: _isEditing,
          ),
          _EditableInfoField(
            icon: Icons.email_rounded,
            title: 'Email',
            controller: _emailController,
            enabled: _isEditing,
          ),
          _EditableInfoField(
            icon: Icons.location_city_rounded,
            title: 'Ville',
            controller: _cityController,
            enabled: _isEditing,
          ),
          _EditableInfoField(
            icon: Icons.phone_rounded,
            title: 'Téléphone',
            controller: _phoneController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 14),
          const _AccountInfoCard(),
        ],
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de compte',
            style: TextStyle(
              color: Color(0xFF060663),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          _AccountStatsGrid(),
        ],
      ),
    );
  }
}

class _AccountStatsGrid extends StatelessWidget {
  const _AccountStatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: const [
        _AccountStat(
          icon: Icons.calendar_month_rounded,
          title: 'Création',
          value: '11 mai 2026',
        ),
        _AccountStat(
          icon: Icons.confirmation_number_rounded,
          title: 'Billets achetés',
          value: '0',
        ),
        _AccountStat(
          icon: Icons.local_shipping_rounded,
          title: 'Envois',
          value: '0',
        ),
        _AccountStat(
          icon: Icons.inventory_2_rounded,
          title: 'Réceptions',
          value: '0',
        ),
      ],
    );
  }
}

class _AccountStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AccountStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFFF80C0D), size: 22),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF060663),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableInfoField extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;
  final bool enabled;

  const _EditableInfoField({
    required this.icon,
    required this.title,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFFFF7F7) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? const Color(0xFFF80C0D).withValues(alpha: 0.18)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF060663), size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 94,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF060663),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
