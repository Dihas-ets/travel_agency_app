import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:code_initial/presentation/pages/tarifs/tarifs_page.dart';
import 'package:code_initial/widgets/tarifs/tarifs_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final ScrollController _accountScrollController = ScrollController();

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
  void dispose() {
    _accountScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];
    final isHomeTab = _currentIndex == 0;
    final isVoyageTab = _currentIndex == 1;
    final isProfileTab = _currentIndex == 3;

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

                  if (!isHomeTab && !isProfileTab) ...[
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
                          : isProfileTab
                          ? _AccountMenuView(
                              key: const ValueKey('profile-account'),
                              scrollController: _accountScrollController,
                              onBack: () => setState(() => _currentIndex = 0),
                            )
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

  static const Color _stmRed = Color(0xFFF80C0D);
  static const Color _deepBlue = Color(0xFF060663);

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

  void _swapCities() {
    final departure = _departureController.text;
    setState(() {
      _departureController.text = _destinationController.text;
      _destinationController.text = departure;
    });
  }

  void _showCityPicker({
    required String title,
    required TextEditingController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.76,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _deepBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _stmRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: _stmRed,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_BeninCityField._beninCities.length} villes disponibles au Bénin',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7B849B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    itemCount: _BeninCityField._beninCities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final city = _BeninCityField._beninCities[index];
                      final isSelected = controller.text.trim() == city;

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() => controller.text = city);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? _stmRed.withValues(alpha: 0.34)
                                    : _deepBlue.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.location_on_outlined,
                                  color: isSelected ? _stmRed : _deepBlue,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A2E),
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTarifsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TarifsPage(
          initialDepart: _departureController.text,
          initialDestination: _destinationController.text,
        ),
      ),
    );
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _deepBlue.withValues(alpha: 0.07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    CityField(
                      controller: _departureController,
                      label: 'De',
                      hint: 'Ville de départ',
                      isFirst: true,
                      onTap: () => _showCityPicker(
                        title: 'Choisir la ville de départ',
                        controller: _departureController,
                      ),
                    ),
                    CityField(
                      controller: _destinationController,
                      label: 'À',
                      hint: 'Ville de destination',
                      isFirst: false,
                      onTap: () => _showCityPicker(
                        title: 'Choisir la ville d’arrivée',
                        controller: _destinationController,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _swapCities,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _stmRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: _stmRed.withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _openTarifsPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _stmRed,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _stmRed.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Recherche',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 4),
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
    'Sèmè-Kpodji',
    'Akpro-Missérété',
    'Adjarra',
    'Avrankou',
    'Dangbo',
    'Adjohoun',
    'Bonou',
    'Abomey',
    'Dassa-Zoumè',
    'Glazoué',
    'Savè',
    'Bantè',
    'Allada',
    'Toffo',
    'Tori-Bossito',
    'Zè',
    'Bohicon',
    'Covè',
    'Zagnanado',
    'Zogbodomey',
    'Za-Kpota',
    'Ouinhi',
    'Agbangnizoun',
    'Djidja',
    'Kétou',
    'Pobè',
    'Sakété',
    'Ifangni',
    'Savalou',
    'Ouidah',
    'Grand-Popo',
    'Comè',
    'Athiémé',
    'Lokossa',
    'Dogbo',
    'Aplahoué',
    'Azovè',
    'Klouékanmè',
    'Djakotomey',
    'Toviklin',
    'Lalo',
    'Kandi',
    'Banikoara',
    'Gogounou',
    'Ségbana',
    'Karimama',
    'Parakou',
    'Tchaourou',
    'Nikki',
    'N’Dali',
    'Pèrèrè',
    'Kalalé',
    'Sinendé',
    'Djougou',
    'Bassila',
    'Copargo',
    'Ouaké',
    'Natitingou',
    'Kouandé',
    'Matéri',
    'Cobly',
    'Boukoumbé',
    'Kérou',
    'Péhunco',
    'Toucountouna',
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

class _NewsArticle {
  final String category;
  final String title;
  final String date;
  final String image;
  final String excerpt;
  final List<String> body;

  const _NewsArticle({
    required this.category,
    required this.title,
    required this.date,
    required this.image,
    required this.excerpt,
    required this.body,
  });
}

const List<_NewsArticle> _stmNewsArticles = [
  _NewsArticle(
    category: 'Annonces',
    title: 'Nouveau départ sur Gouré',
    date: '28/03/2026',
    image: 'assets/images/welcome_image.jpg',
    excerpt:
        'STM renforce son réseau avec un nouveau départ pensé pour faciliter les déplacements réguliers.',
    body: [
      'STM informe son aimable clientèle de la mise en place d’un nouveau départ sur l’axe Gouré afin de rendre les voyages plus simples, plus réguliers et plus confortables.',
      'Cette nouvelle desserte répond à la demande des voyageurs qui souhaitent mieux organiser leurs déplacements entre les grandes villes et les localités desservies par STM.',
      'Les clients sont invités à se rapprocher des agences STM pour confirmer les horaires, les disponibilités et les conditions de réservation.',
    ],
  ),
  _NewsArticle(
    category: 'Annonces',
    title: "Renforcement des départs sur l'axe Tchaourou",
    date: '25/03/2026',
    image: 'assets/images/onboarding1.png',
    excerpt:
        'De nouveaux horaires sont ajoutés pour offrir plus de flexibilité aux voyageurs.',
    body: [
      'Pour mieux accompagner les besoins de mobilité, STM annonce un renforcement progressif des départs sur l’axe Tchaourou.',
      'Cette organisation permet aux voyageurs de choisir des créneaux plus adaptés à leurs programmes personnels, professionnels ou familiaux.',
      'Les équipes en agence restent disponibles pour orienter les clients et les aider à choisir le départ le plus pratique.',
    ],
  ),
  _NewsArticle(
    category: 'Presse',
    title: 'STM modernise l’accueil dans ses agences',
    date: '18/03/2026',
    image: 'assets/images/onboarding2.png',
    excerpt:
        'Un parcours client plus fluide est déployé pour améliorer l’achat de tickets et l’information voyageur.',
    body: [
      'STM poursuit l’amélioration de l’expérience client dans ses agences avec des espaces plus lisibles, un accueil renforcé et une meilleure orientation des voyageurs.',
      'L’objectif est de réduire l’attente, d’améliorer la qualité des informations et de rendre chaque étape du voyage plus agréable.',
      'Cette modernisation s’inscrit dans une démarche continue de qualité de service.',
    ],
  ),
  _NewsArticle(
    category: 'Conseils',
    title: 'Bien préparer son voyage avec STM',
    date: '12/03/2026',
    image: 'assets/images/onboarding3.png',
    excerpt:
        'Quelques réflexes simples pour voyager sereinement et éviter les oublis avant le départ.',
    body: [
      'Avant chaque départ, STM recommande aux voyageurs de vérifier leur ticket, leur pièce d’identité et l’heure de présentation en agence.',
      'Il est conseillé d’arriver suffisamment tôt afin d’effectuer les formalités sans stress et d’embarquer dans de bonnes conditions.',
      'Pour les bagages et colis, les équipes STM peuvent préciser les règles applicables selon le trajet choisi.',
    ],
  ),
  _NewsArticle(
    category: 'Communiqués',
    title: 'Suivi des colis disponible dans les agences STM',
    date: '08/03/2026',
    image: 'assets/images/logo_stm.jpeg',
    excerpt:
        'Les clients peuvent obtenir des informations sur leurs colis directement auprès des points STM.',
    body: [
      'STM rappelle à sa clientèle que le suivi des colis est disponible auprès de ses agences et points de contact.',
      'Les clients sont invités à conserver leurs références d’envoi afin de faciliter les vérifications et accélérer la prise en charge.',
      'Ce service accompagne les voyageurs et expéditeurs dans une logique de proximité et de fiabilité.',
    ],
  ),
];

class _NewsSection extends StatefulWidget {
  const _NewsSection();

  @override
  State<_NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<_NewsSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _pageIndex = (_pageIndex + 1) % _stmNewsArticles.length);
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

    void openDetail(_NewsArticle article) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _NewsDetailPage(article: article)),
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
                  color: deepBlue,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _NewsListPage()),
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
            itemCount: _stmNewsArticles.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = _stmNewsArticles[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _NewsHeroTile(
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
          children: List.generate(_stmNewsArticles.length, (i) {
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

class _NewsListPage extends StatefulWidget {
  const _NewsListPage();

  @override
  State<_NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<_NewsListPage> {
  late final PageController _pageController;
  Timer? _timer;
  int _pageIndex = 0;
  String _category = 'Tous';

  List<String> get _categories => const [
    'Tous',
    'Annonces',
    'Presse',
    'Communiqués',
    'Conseils',
  ];

  List<_NewsArticle> get _filteredArticles {
    if (_category == 'Tous') return _stmNewsArticles;
    return _stmNewsArticles
        .where((article) => article.category == _category)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_pageIndex + 1) % _stmNewsArticles.take(3).length;
      setState(() => _pageIndex = next);
      _pageController.animateToPage(
        next,
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

  void _openDetail(_NewsArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _NewsDetailPage(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFF80C0D);
    const deepBlue = Color(0xFF060663);
    final filtered = _filteredArticles;
    final recent = _stmNewsArticles.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderIconButton(
                      icon: Icons.menu_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_stm_no_background.png',
                    height: 58,
                    fit: BoxFit.contain,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aucune notification')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Actualités',
              style: TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _category;

                  return ChoiceChip(
                    selected: isSelected,
                    label: Text(category),
                    onSelected: (_) => setState(() => _category = category),
                    selectedColor: const Color(0xFFFFEADC),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? red.withValues(alpha: 0.22)
                          : Colors.transparent,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? red : deepBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
                      child: Text(
                        'Plus récents :',
                        style: TextStyle(
                          color: deepBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 178,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: recent.length,
                        onPageChanged: (value) {
                          setState(() => _pageIndex = value);
                        },
                        itemBuilder: (context, index) {
                          final article = recent[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _NewsRecentCard(
                              article: article,
                              onTap: () => _openDetail(article),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(recent.length, (i) {
                        final isActive = i == _pageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 34 : 14,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? red
                                : deepBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 14),
                      child: Text(
                        'Articles pour vous :',
                        style: TextStyle(
                          color: deepBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    ...filtered.map(
                      (article) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: _NewsArticleTile(
                          article: article,
                          onTap: () => _openDetail(article),
                        ),
                      ),
                    ),
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

class _NewsHeroTile extends StatelessWidget {
  final _NewsArticle article;
  final VoidCallback onTap;
  final bool compact;

  const _NewsHeroTile({
    required this.article,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFF80C0D);

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
                child: _NewsCategoryPill(category: article.category),
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
                    color: red,
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

class _NewsRecentCard extends StatelessWidget {
  final _NewsArticle article;
  final VoidCallback onTap;

  const _NewsRecentCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF060663);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  article.image,
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 104,
                    height: 104,
                    color: const Color(0xFFF8FBFF),
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NewsCategoryPill(category: article.category, light: true),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publié le ${article.date}',
                      style: const TextStyle(
                        color: Color(0xFF8B93A6),
                        fontSize: 14.5,
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
}

class _NewsArticleTile extends StatelessWidget {
  final _NewsArticle article;
  final VoidCallback onTap;

  const _NewsArticleTile({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF060663);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: deepBlue.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  article.image,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96,
                    height: 96,
                    color: const Color(0xFFF8FBFF),
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NewsCategoryPill(category: article.category, light: true),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Publié le ${article.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B93A6),
                        fontSize: 13.5,
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
}

class _NewsCategoryPill extends StatelessWidget {
  final String category;
  final bool light;

  const _NewsCategoryPill({required this.category, this.light = false});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFF80C0D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: light ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: red.withValues(alpha: light ? 0.62 : 0.78)),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: red,
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NewsDetailPage extends StatelessWidget {
  final _NewsArticle article;

  const _NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFF80C0D);
    const deepBlue = Color(0xFF060663);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _HeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_stm_no_background.png',
                      height: 58,
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _HeaderIconButton(
                        icon: Icons.share_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Partage bientôt disponible'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.18,
                        child: Image.asset(
                          article.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white,
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _NewsCategoryPill(category: article.category),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_rounded, color: red, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Publié le ${article.date}',
                          style: const TextStyle(
                            color: Color(0xFF7B849B),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      article.excerpt,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontSize: 15.5,
                        height: 1.48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: deepBlue.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: red.withValues(alpha: 0.11),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Les horaires et disponibilités sont à confirmer auprès des agences STM.',
                              style: TextStyle(
                                color: deepBlue,
                                fontSize: 13.8,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    ...article.body.map(
                      (paragraph) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          paragraph,
                          style: const TextStyle(
                            color: Color(0xFF26304D),
                            fontSize: 16,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Retour aux actualités'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
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
      padding: EdgeInsets.fromLTRB(18, 10, 18, 34 + bottomInset),
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
          const SizedBox(height: 16),

          // ✅ Photo/icon modifiable
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0xFF58648D),
                  backgroundImage: _pickedImage == null
                      ? null
                      : FileImage(File(_pickedImage!.path)),
                  child: _pickedImage == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 74,
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

          const SizedBox(height: 18),
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
      padding: const EdgeInsets.all(14),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF80C0D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations personnelles',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF060663),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Photo, nom, prénom et contacts',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF5F6B86),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
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
                child: TextButton.icon(
                  onPressed: _toggleEdit,
                  icon: Icon(
                    _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                    size: 18,
                  ),
                  label: Text(_isEditing ? 'Enregistrer' : 'Modifier'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF80C0D),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    visualDensity: VisualDensity.compact,
                  ),
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
      padding: const EdgeInsets.all(14),
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
      childAspectRatio: 1.05,
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
      padding: const EdgeInsets.all(12),
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
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 11.5,
              height: 1.12,
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
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(13),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF060663), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF060663),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
