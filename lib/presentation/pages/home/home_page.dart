import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:code_initial/presentation/pages/parcel/parcel_pages.dart';
import 'package:code_initial/presentation/pages/parcel/parcel_store.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/presentation/pages/tarifs/tarifs_page.dart';
import 'package:code_initial/widgets/login/login_widgets.dart';
import 'package:code_initial/widgets/tarifs/tarifs_widgets.dart';

const List<String> _beninCities = [
  'Abomey',
  'Abomey-Calavi',
  'Adjohoun',
  'Allada',
  'Aplahoué',
  'Banikoara',
  'Bassila',
  'Bembèrèkè',
  'Bétérou',
  'Bohicon',
  'Bopa',
  'Cotonou',
  'Covè',
  'Comè',
  'Dassa-Zoumè',
  'Djougou',
  'Dogbo',
  'Glazoué',
  'Grand-Popo',
  'Kandi',
  'Kétou',
  'Kouandé',
  'Lokossa',
  'Malanville',
  'Natitingou',
  'Nikki',
  'N’Dali',
  'Ouidah',
  'Parakou',
  'Pobè',
  'Porto-Novo',
  'Sakété',
  'Savè',
  'Savalou',
  'Sèmè-Kpodji',
  'Tanguiéta',
  'Tchaourou',
];

class _HistoryRepository {
  static final List<_ReservationItem> reservations = [];

  static List<_TicketItem> get tickets => reservations.expand((reservation) {
    return List.generate(reservation.passengerCount, (index) {
      final ticketSeat = '${index + 1}A';
      return _TicketItem(
        code: reservation.reference.replaceFirst('TB', 'TK'),
        departure: reservation.departure,
        destination: reservation.destination,
        passenger: reservation.beneficiaryName,
        passengerCount: reservation.passengerCount,
        ticketIndex: index + 1,
        date: reservation.date,
        time: reservation.time,
        seat: ticketSeat,
        price: reservation.price,
        reference: reservation.reference,
        gate:
            'A${ticketSeat.replaceAll(RegExp(r'[^0-9]'), '').padLeft(2, '0')}',
      );
    });
  }).toList();

  static void addReservation(_ReservationItem reservation) {
    reservations.insert(0, reservation);
  }

  static void updateReservation(_ReservationItem reservation) {
    final index = reservations.indexWhere(
      (item) => item.reference == reservation.reference,
    );
    if (index != -1) reservations[index] = reservation;
  }

  static void removeReservation(String reference) {
    reservations.removeWhere((item) => item.reference == reference);
  }
}

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
      headline: 'Bienvenue chez Fofana',
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
      description:
          'Envoyez et suivez vos colis en toute simplicité avec Fofana.',
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
    final isParcelTab = _currentIndex == 2;
    final isProfileTab = _currentIndex == 3;
    const navigationGreen = Color(0xFF16A34A);

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
                        'assets/images/logo_fofana_no_background.png',
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: const _ParcelNotificationIconButton(),
                      ),
                    ],
                  ),

                  SizedBox(height: isHomeTab ? 18 : 24),

                  if (!isHomeTab && !isProfileTab) ...[
                    Text(
                      currentTab.headline,
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
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
                          : isParcelTab
                          ? const ParcelMenuContent(key: ValueKey('parcel'))
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
          // Navigation basse compactée pour éviter l'overflow du bouton Profil.
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            )
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
                              fontWeight: isActive
                                  ? FontWeight.w900
                                  : FontWeight.w800,
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

class _ConnectedHomeContent extends StatefulWidget {
  const _ConnectedHomeContent({super.key});

  @override
  State<_ConnectedHomeContent> createState() => _ConnectedHomeContentState();
}

class _ConnectedHomeContentState extends State<_ConnectedHomeContent> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  bool? _isLocationActive;

  static const Color _fofanaGreen = Color(0xFF16A34A);
  static const Color _deepBlue = Color(0xFF0B4F2A);

  @override
  void initState() {
    super.initState();
    _checkLocationActive();
  }

  Future<void> _checkLocationActive() async {
    if (mounted) setState(() => _isLocationActive = null);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 4));
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if (mounted) setState(() => _isLocationActive = false);
        return;
      }

      var permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 4),
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
        );
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }

      final active =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (mounted) setState(() => _isLocationActive = active);
    } catch (_) {
      if (mounted) setState(() => _isLocationActive = false);
    }
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
                          color: _fofanaGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: _fofanaGreen,
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
                                    ? _fofanaGreen.withValues(alpha: 0.34)
                                    : _deepBlue.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.location_on_outlined,
                                  color: isSelected ? _fofanaGreen : _deepBlue,
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
          onReserve: _openTarifConfirmation,
        ),
      ),
    );
  }

  void _openTarifConfirmation(
    BuildContext context,
    TarifReservationSelection selection,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PaymentDetailsPage(
          departure: selection.departure,
          destination: selection.destination,
          date: selection.date,
          priceAmount: selection.priceAmount,
          passengers: selection.passengerCount,
          time: selection.time,
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
              color: Color(0xFF0B4F2A),
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
            _LocationDisabledCard(
              isLoading: _isLocationActive == null,
              onEnableLocation: _checkLocationActive,
            ),

          const SizedBox(height: 18),

          const _NewsSection(),

          const SizedBox(height: 24),

          const Text(
            'Tarifs',
            style: TextStyle(
              color: Color(0xFFE53935),
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
                          // Cercle de permutation en bleu pour mieux ressortir entre les champs.
                          color: _deepBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: _deepBlue.withValues(alpha: 0.28),
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
                backgroundColor: _fofanaGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _fofanaGreen.withValues(alpha: 0.4),
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
                      activeColor: const Color(0xFF16A34A),
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
            color: Color(0xFF16A34A),
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
  final VoidCallback onEnableLocation;

  const _LocationDisabledCard({
    required this.isLoading,
    required this.onEnableLocation,
  });

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
                    color: Color(0xFFEAF7EF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Localisation requise',
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onEnableLocation,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Activez la localisation pour voir les agences proches.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF5F6B86),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.my_location_rounded,
                                    color: Color(0xFF16A34A),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Réessayer',
                                    style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
  bool _isOpeningMaps = false;

  Future<void> _openGoogleMaps() async {
    if (_isOpeningMaps) return;

    setState(() => _isOpeningMaps = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 6));

      final query =
          'agence Fofana proche @${position.latitude},${position.longitude}';
      final encodedQuery = Uri.encodeComponent(query);
      final appUri = Platform.isAndroid
          ? Uri.parse(
              'geo:${position.latitude},${position.longitude}?q=$encodedQuery',
            )
          : Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
            );
      final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
      );

      final opened = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      ).timeout(const Duration(seconds: 5), onTimeout: () => false);

      if (!opened) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      final fallbackUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=agence%20Fofana%20proche',
      );
      final opened = await launchUrl(
        fallbackUri,
        mode: LaunchMode.externalApplication,
      ).timeout(const Duration(seconds: 5), onTimeout: () => false);

      if (opened || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir Google Maps pour le moment."),
        ),
      );
    } finally {
      if (mounted) setState(() => _isOpeningMaps = false);
    }
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
                    color: Color(0xFFEAF7EF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.map_rounded, color: Color(0xFF0B4F2A)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Agences proches',
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
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

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openGoogleMaps,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: 154,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -20,
                      top: 30,
                      right: 70,
                      child: Transform.rotate(
                        angle: -0.16,
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF3E5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      top: -12,
                      bottom: -10,
                      child: Transform.rotate(
                        angle: 0.34,
                        child: Container(
                          width: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4F6EA),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -28,
                      bottom: 26,
                      left: 112,
                      child: Transform.rotate(
                        angle: 0.1,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF3E5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 36,
                      top: 28,
                      child: _AgencyMapPin(label: 'Agence'),
                    ),
                    const Positioned(
                      right: 42,
                      bottom: 28,
                      child: _AgencyMapPin(label: 'Fofana'),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isOpeningMaps)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF4285F4),
                                ),
                              )
                            else
                              const Icon(
                                Icons.open_in_new_rounded,
                                color: Color(0xFF4285F4),
                                size: 16,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _isOpeningMaps ? 'Ouverture...' : 'Ouvrir Maps',
                              style: const TextStyle(
                                color: Color(0xFF0B4F2A),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyMapPin extends StatelessWidget {
  final String label;

  const _AgencyMapPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Icon(
          Icons.location_on_rounded,
          color: Color(0xFF16A34A),
          size: 34,
        ),
      ],
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

const List<_NewsArticle> _fofanaNewsArticles = [
  _NewsArticle(
    category: 'Annonces',
    title: 'Nouveau départ sur Gouré',
    date: '28/03/2026',
    image: 'assets/images/welcome_image.jpg',
    excerpt:
        'Fofana renforce son réseau avec un nouveau départ pensé pour faciliter les déplacements réguliers.',
    body: [
      'Fofana informe son aimable clientèle de la mise en place d’un nouveau départ sur l’axe Gouré afin de rendre les voyages plus simples, plus réguliers et plus confortables.',
      'Cette nouvelle desserte répond à la demande des voyageurs qui souhaitent mieux organiser leurs déplacements entre les grandes villes et les localités desservies par Fofana.',
      'Les clients sont invités à se rapprocher des agences Fofana pour confirmer les horaires, les disponibilités et les conditions de réservation.',
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
      'Pour mieux accompagner les besoins de mobilité, Fofana annonce un renforcement progressif des départs sur l’axe Tchaourou.',
      'Cette organisation permet aux voyageurs de choisir des créneaux plus adaptés à leurs programmes personnels, professionnels ou familiaux.',
      'Les équipes en agence restent disponibles pour orienter les clients et les aider à choisir le départ le plus pratique.',
    ],
  ),
  _NewsArticle(
    category: 'Presse',
    title: 'Fofana modernise l’accueil dans ses agences',
    date: '18/03/2026',
    image: 'assets/images/onboarding2.png',
    excerpt:
        'Un parcours client plus fluide est déployé pour améliorer l’achat de tickets et l’information voyageur.',
    body: [
      'Fofana poursuit l’amélioration de l’expérience client dans ses agences avec des espaces plus lisibles, un accueil renforcé et une meilleure orientation des voyageurs.',
      'L’objectif est de réduire l’attente, d’améliorer la qualité des informations et de rendre chaque étape du voyage plus agréable.',
      'Cette modernisation s’inscrit dans une démarche continue de qualité de service.',
    ],
  ),
  _NewsArticle(
    category: 'Conseils',
    title: 'Bien préparer son voyage avec Fofana',
    date: '12/03/2026',
    image: 'assets/images/onboarding3.png',
    excerpt:
        'Quelques réflexes simples pour voyager sereinement et éviter les oublis avant le départ.',
    body: [
      'Avant chaque départ, Fofana recommande aux voyageurs de vérifier leur ticket, leur pièce d’identité et l’heure de présentation en agence.',
      'Il est conseillé d’arriver suffisamment tôt afin d’effectuer les formalités sans stress et d’embarquer dans de bonnes conditions.',
      'Pour les bagages et colis, les équipes Fofana peuvent préciser les règles applicables selon le trajet choisi.',
    ],
  ),
  _NewsArticle(
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
      setState(
        () => _pageIndex = (_pageIndex + 1) % _fofanaNewsArticles.length,
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
                  color: Color(0xFFE53935),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _NewsListPage()),
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
            itemCount: _fofanaNewsArticles.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = _fofanaNewsArticles[index];

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
          children: List.generate(_fofanaNewsArticles.length, (i) {
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
    if (_category == 'Tous') return _fofanaNewsArticles;
    return _fofanaNewsArticles
        .where((article) => article.category == _category)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_pageIndex + 1) % _fofanaNewsArticles.take(3).length;
      setState(() => _pageIndex = next);
      if (!_pageController.hasClients) return;
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
    const green = Color(0xFF16A34A);
    const deepBlue = Color(0xFF0B4F2A);
    final filtered = _filteredArticles;
    final recent = _fofanaNewsArticles.take(3).toList();

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
                    'assets/images/logo_fofana_no_background.png',
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
                    selectedColor: green,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? green : Colors.transparent,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : deepBlue,
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
                                ? green
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

class _NewsRecentCard extends StatelessWidget {
  final _NewsArticle article;
  final VoidCallback onTap;

  const _NewsRecentCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

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
    const deepBlue = Color(0xFF0B4F2A);

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
    const green = Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        // Pastille forte pour garder les catégories lisibles sur toutes les images.
        color: light ? green.withValues(alpha: 0.12) : green,
        border: light ? Border.all(color: green.withValues(alpha: 0.22)) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: light ? green : Colors.white,
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
    const green = Color(0xFF16A34A);
    const deepBlue = Color(0xFF0B4F2A);

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
                      'assets/images/logo_fofana_no_background.png',
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
                        const Icon(Icons.event_rounded, color: green, size: 18),
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
                              color: green.withValues(alpha: 0.11),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Les horaires et disponibilités sont à confirmer auprès des agences Fofana.',
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
                          backgroundColor: green,
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

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Vos options de voyage',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _VoyageActionsCard(
              onReservation: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _ReservationPage()),
                );
              },
              onReprogram: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _ReprogramPage()),
                );
              },
              onHistory: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const _HistoryPage()));
              },
              onTarifs: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TarifsPage(
                      onReserve: (context, selection) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _PaymentDetailsPage(
                              departure: selection.departure,
                              destination: selection.destination,
                              date: selection.date,
                              priceAmount: selection.priceAmount,
                              passengers: selection.passengerCount,
                              time: selection.time,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
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
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

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
                    color: green.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: green.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, size: 20, color: green),
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

class _ReservationPage extends StatefulWidget {
  const _ReservationPage();

  @override
  State<_ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<_ReservationPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int _passengerCount = 1;
  DateTime? _travelDate;

  final List<String> _cities = _beninCities;

  List<_ReservationItem> get _confirmedReservations =>
      _HistoryRepository.reservations;

  @override
  void initState() {
    super.initState();
    _departController.text = 'Cotonou';
    _destinationController.text = 'Porto-Novo';
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _fofanaGreen,
            onPrimary: Colors.white,
            onSurface: _deepBlue,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _fofanaGreen),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        _travelDate = date;
        _dateController.text =
            '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
      });
    }
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
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _deepBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _deepBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: _deepBlue.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cities.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      return ListTile(
                        title: Text(
                          city,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          controller.text = city;
                          Navigator.of(context).pop();
                        },
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

  int get _fare {
    if (_departController.text.isEmpty || _destinationController.text.isEmpty) {
      return 0;
    }
    final seed =
        _departController.text.length + _destinationController.text.length;
    final base = 8000 + (seed % 5) * 500;
    return base + _passengerCount * 1200;
  }

  Future<void> _confirmReservation() async {
    if (_departController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _travelDate == null ||
        _passengerCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter tous les champs.')),
      );
      return;
    }

    if (_departController.text == _destinationController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La destination doit être différente du départ.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PaymentDetailsPage(
          departure: _departController.text.trim(),
          destination: _destinationController.text.trim(),
          date:
              '${_travelDate!.day.toString().padLeft(2, '0')} ${_getMonthName(_travelDate!.month)} ${_travelDate!.year}',
          priceAmount: _fare,
          passengers: _passengerCount,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/welcome_image.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0x99060E27),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
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
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_fofana_no_background.png',
                        height: 44,
                        width: 142,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Réserver un billet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const _HistoryPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          'Mes réservations',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F9FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildReservationForm(),
                      const SizedBox(height: 18),
                      if (_confirmedReservations.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Mes réservations',
                              style: TextStyle(
                                color: _deepBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ..._confirmedReservations.map(
                              (item) => _ReservationCard(item: item),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      controller: _departController,
                      label: 'De',
                      hint: 'Ville de départ',
                      isFirst: true,
                      onTap: () => _showCityPicker(
                        title: 'Choisir la ville de départ',
                        controller: _departController,
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
                      onTap: _switchLocations,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _deepBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _deepBlue.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  label: 'Date de départ',
                  value: _dateController.text.isEmpty
                      ? 'Sélectionner une date'
                      : _dateController.text,
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallField(
                  label: 'Retour',
                  value: 'Ajouter un retour',
                  icon: Icons.sync_alt_rounded,
                  disabled: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPassengerCard(),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _confirmReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _fofanaGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Suivant',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchLocations() {
    final first = _departController.text;
    _departController.text = _destinationController.text;
    _destinationController.text = first;
    setState(() {});
  }

  Widget _buildSmallField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: disabled ? Colors.white : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _deepBlue.withValues(alpha: 0.12)),
          boxShadow: disabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: disabled
                    ? const Color(0xFFB4BFD4)
                    : const Color(0xFF5F6B86),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(icon, size: 18, color: _deepBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: _deepBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Passager(s)',
                  style: TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sélectionnez le nombre de voyageurs',
                  style: TextStyle(
                    color: Color(0xFF7F8BAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: () {
                  setState(() {
                    if (_passengerCount > 1) _passengerCount -= 1;
                  });
                },
              ),
              const SizedBox(width: 10),
              Text(
                '$_passengerCount',
                style: const TextStyle(
                  color: _deepBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              _buildStepperButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    if (_passengerCount < 8) _passengerCount += 1;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _deepBlue.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: _deepBlue),
      ),
    );
  }
}

class _PaymentDetailsPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final int priceAmount;
  final int passengers;
  final String time;

  const _PaymentDetailsPage({
    required this.departure,
    required this.destination,
    required this.date,
    required this.priceAmount,
    required this.passengers,
    this.time = '10:00',
  });

  @override
  State<_PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<_PaymentDetailsPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _requesterPhoneController =
      TextEditingController();
  final TextEditingController _beneficiaryFirstNameController =
      TextEditingController();
  final TextEditingController _beneficiaryLastNameController =
      TextEditingController();
  final TextEditingController _beneficiaryPhoneController =
      TextEditingController();

  bool _isForSomeoneElse = false;

  @override
  void dispose() {
    _requesterPhoneController.dispose();
    _beneficiaryFirstNameController.dispose();
    _beneficiaryLastNameController.dispose();
    _beneficiaryPhoneController.dispose();
    super.dispose();
  }

  void _finishReservation() {
    final requesterPhone = _requesterPhoneController.text.trim();
    final beneficiaryFirstName = _beneficiaryFirstNameController.text.trim();
    final beneficiaryLastName = _beneficiaryLastNameController.text.trim();
    final beneficiaryPhone = _beneficiaryPhoneController.text.trim();

    if (requesterPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le numéro demandeur.')),
      );
      return;
    }

    if (_isForSomeoneElse &&
        (beneficiaryFirstName.isEmpty ||
            beneficiaryLastName.isEmpty ||
            beneficiaryPhone.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez compléter les informations du bénéficiaire.'),
        ),
      );
      return;
    }

    final beneficiaryName = _isForSomeoneElse
        ? '$beneficiaryFirstName $beneficiaryLastName'
        : 'Moi-même';
    final reservation = _ReservationItem(
      reference: 'TB${DateTime.now().millisecondsSinceEpoch}',
      departure: widget.departure,
      destination: widget.destination,
      date: widget.date,
      time: widget.time,
      seat: '${(widget.passengers % 12 == 0 ? 12 : widget.passengers)}A',
      price: '${_formatAmount(widget.priceAmount)} CFA',
      passengerCount: widget.passengers,
      beneficiaryName: beneficiaryName,
      requesterPhone: requesterPhone,
      beneficiaryPhone: _isForSomeoneElse ? beneficiaryPhone : requesterPhone,
      status: 'Confirmée',
    );
    _HistoryRepository.addReservation(reservation);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _GeneratedTicketPage(reservation: reservation),
      ),
    );
  }

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _deepBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/logo_fofana_no_background.png',
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Confirmation',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entrez le numéro de téléphone et le destinataire.',
                      style: TextStyle(
                        color: _deepBlue.withValues(alpha: 0.72),
                        fontSize: 14.2,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Numéro de téléphone demandeur :'),
                    const SizedBox(height: 12),
                    PhoneLoginField(controller: _requesterPhoneController),
                    const SizedBox(height: 18),
                    _buildCheckboxCard(),
                    if (_isForSomeoneElse) ...[
                      const SizedBox(height: 22),
                      _buildSectionHeader('Nom et Prénom du bénéficiaire :'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _beneficiaryFirstNameController,
                        label: 'Nom',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _beneficiaryLastNameController,
                        label: 'Prénom',
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('N° du bénéficiaire :'),
                      const SizedBox(height: 12),
                      PhoneLoginField(controller: _beneficiaryPhoneController),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _finishReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fofanaGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Terminer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _deepBlue,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.24),
          width: 1.4,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 16,
          ),
          hintText: label,
          hintStyle: const TextStyle(
            color: Color(0xFF7B849B),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCheckboxCard() {
    return GestureDetector(
      onTap: () => setState(() => _isForSomeoneElse = !_isForSomeoneElse),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isForSomeoneElse
              ? _fofanaGreen.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isForSomeoneElse
                ? _fofanaGreen
                : _deepBlue.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _isForSomeoneElse ? _fofanaGreen : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _deepBlue.withValues(alpha: 0.18)),
              ),
              child: Icon(
                _isForSomeoneElse ? Icons.check : Icons.check_box_outline_blank,
                size: 18,
                color: _isForSomeoneElse ? Colors.white : _deepBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Achat pour quelqu’un',
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 16,
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

class _GeneratedTicketPage extends StatefulWidget {
  final _ReservationItem reservation;

  const _GeneratedTicketPage({required this.reservation});

  @override
  State<_GeneratedTicketPage> createState() => _GeneratedTicketPageState();
}

class _GeneratedTicketPageState extends State<_GeneratedTicketPage> {
  late _ReservationItem _reservation;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodSheet(total: _reservation.price),
    );
  }

  void _editReservation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: _reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          setState(() => _reservation = updated);
        },
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await _showCancelReservationDialog(context);
    if (shouldCancel != true) return;

    _HistoryRepository.removeReservation(_reservation.reference);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée.')));
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    final tickets = List.generate(_reservation.passengerCount, (index) {
      return index + 1;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_fofana_no_background.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const Text(
              'Réservations',
              style: TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_reservation.passengerCount} réservation${_reservation.passengerCount > 1 ? 's' : ''} enregistrée${_reservation.passengerCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...tickets.map(
                      (ticketNumber) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _TicketVisual(
                          departure: _reservation.departure,
                          destination: _reservation.destination,
                          date: _reservation.date,
                          time: _reservation.time,
                          passengerCount: _reservation.passengerCount,
                          ticketIndex: ticketNumber,
                          beneficiaryName: _reservation.beneficiaryName,
                          total: _reservation.price,
                          reference: '${_reservation.reference}$ticketNumber',
                          primaryActionLabel: 'Effectuer le règlement',
                          onPrimaryAction: _showPaymentSheet,
                          onEdit: _editReservation,
                          onCancel: _confirmCancel,
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

class _PaymentMethodSheet extends StatefulWidget {
  final String total;

  const _PaymentMethodSheet({required this.total});

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Effectuer le règlement',
              style: TextStyle(
                color: _deepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE1E4EC)),
              ),
              child: const Row(
                children: [
                  Text('🇧🇯', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text(
                    'Benin',
                    style: TextStyle(
                      color: _deepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              value: 'moov',
              selectedValue: _selectedMethod,
              imagePath: 'assets/images/logo_moov.png',
              onTap: () => setState(() => _selectedMethod = 'moov'),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              value: 'mtn',
              selectedValue: _selectedMethod,
              imagePath: 'assets/images/logo_mtn.png',
              onTap: () => setState(() => _selectedMethod = 'mtn'),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              value: 'celtiis',
              selectedValue: _selectedMethod,
              imagePath: 'assets/images/logo_celtiis.png',
              onTap: () => setState(() => _selectedMethod = 'celtiis'),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _selectedMethod == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Paiement ${widget.total} lancé avec ${_selectedMethod!.toUpperCase()}.',
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _fofanaGreen,
                  disabledBackgroundColor: const Color(0xFFFFBE9D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String imagePath;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.value,
    required this.selectedValue,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A34A)
                : const Color(0xFFE1E4EC),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD8DCE6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const Spacer(),
            Image.asset(imagePath, width: 104, height: 58, fit: BoxFit.contain),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _EditReservationSheet extends StatefulWidget {
  final _ReservationItem reservation;
  final ValueChanged<_ReservationItem> onSave;

  const _EditReservationSheet({
    required this.reservation,
    required this.onSave,
  });

  @override
  State<_EditReservationSheet> createState() => _EditReservationSheetState();
}

class _EditReservationSheetState extends State<_EditReservationSheet> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  late final TextEditingController _departureController;
  late final TextEditingController _destinationController;
  late final TextEditingController _dateController;
  late final TextEditingController _beneficiaryController;
  late final TextEditingController _phoneController;
  late int _passengerCount;

  @override
  void initState() {
    super.initState();
    _departureController = TextEditingController(
      text: widget.reservation.departure,
    );
    _destinationController = TextEditingController(
      text: widget.reservation.destination,
    );
    _dateController = TextEditingController(text: widget.reservation.date);
    _beneficiaryController = TextEditingController(
      text: widget.reservation.beneficiaryName,
    );
    _phoneController = TextEditingController(
      text: widget.reservation.beneficiaryPhone,
    );
    _passengerCount = widget.reservation.passengerCount;
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _beneficiaryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCityPicker(TextEditingController controller, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: _deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _beninCities.length,
                  itemBuilder: (context, index) {
                    final city = _beninCities[index];
                    return ListTile(
                      title: Text(
                        city,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      onTap: () {
                        controller.text = city;
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_departureController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty ||
        _dateController.text.trim().isEmpty ||
        _beneficiaryController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter les champs.')),
      );
      return;
    }

    if (_departureController.text.trim() ==
        _destinationController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La destination doit être différente du départ.'),
        ),
      );
      return;
    }

    widget.onSave(
      widget.reservation.copyWith(
        departure: _departureController.text.trim(),
        destination: _destinationController.text.trim(),
        date: _dateController.text.trim(),
        passengerCount: _passengerCount,
        beneficiaryName: _beneficiaryController.text.trim(),
        beneficiaryPhone: _phoneController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifier la réservation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _EditSheetField(
                controller: _departureController,
                label: 'Ville de départ',
                readOnly: true,
                onTap: () =>
                    _showCityPicker(_departureController, 'Choisir le départ'),
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _destinationController,
                label: 'Ville d’arrivée',
                readOnly: true,
                onTap: () => _showCityPicker(
                  _destinationController,
                  'Choisir l’arrivée',
                ),
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _dateController,
                label: 'Date de départ',
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _beneficiaryController,
                label: 'Bénéficiaire',
              ),
              const SizedBox(height: 12),
              _EditSheetField(
                controller: _phoneController,
                label: 'Téléphone bénéficiaire',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _deepBlue.withValues(alpha: 0.10)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nombre de passagers',
                        style: TextStyle(
                          color: _deepBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _passengerCount > 1
                          ? () => setState(() => _passengerCount--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: _fofanaGreen,
                    ),
                    Text(
                      '$_passengerCount',
                      style: const TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      onPressed: _passengerCount < 8
                          ? () => setState(() => _passengerCount++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: _fofanaGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _fofanaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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

class _EditSheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _EditSheetField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: readOnly
            ? const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF0B4F2A),
              )
            : null,
        labelStyle: const TextStyle(
          color: Color(0xFF7B849B),
          fontWeight: FontWeight.w800,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.6),
        ),
      ),
    );
  }
}

Future<bool?> _showCancelReservationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFF16A34A),
          size: 34,
        ),
      ),
      title: const Text(
        'Annuler la réservation ?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF0B4F2A), fontWeight: FontWeight.w900),
      ),
      content: const Text(
        'Voulez-vous vraiment annuler cette réservation ?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Non',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Oui',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}

enum _HistoryScope { reservations, tickets }

class _HistoryPage extends StatefulWidget {
  const _HistoryPage();

  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  _HistoryScope _scope = _HistoryScope.reservations;

  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  List<_ReservationItem> get _reservations => _HistoryRepository.reservations;
  List<_TicketItem> get _tickets => _HistoryRepository.tickets;

  Future<void> _openReservationTicket(_ReservationItem reservation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReservationTicketPage(reservation: reservation),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Menu non disponible sur cette page',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_fofana_no_background.png',
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F9FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _NewsSection(),
                      const SizedBox(height: 18),
                      _buildScopeSwitcher(),
                      const SizedBox(height: 18),
                      if (_scope == _HistoryScope.reservations)
                        _buildReservationSection()
                      else
                        _buildTicketSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildScopeButton(
            label: 'Mes réservations',
            selected: _scope == _HistoryScope.reservations,
            onTap: () => setState(() => _scope = _HistoryScope.reservations),
          ),
          _buildScopeButton(
            label: 'Mes billets',
            selected: _scope == _HistoryScope.tickets,
            onTap: () => setState(() => _scope = _HistoryScope.tickets),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? _fofanaGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : _deepBlue,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mes réservations',
          style: TextStyle(
            color: _deepBlue,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        if (_reservations.isEmpty)
          _buildEmptyState(
            title: 'Aucune réservation pour le moment',
            message: 'Réservez un trajet pour retrouver vos réservations ici.',
          )
        else
          ..._reservations.map(
            (item) => _ReservationCard(
              item: item,
              onTicketNow: () => _openReservationTicket(item),
            ),
          ),
      ],
    );
  }

  Widget _buildTicketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mes billets',
          style: TextStyle(
            color: _deepBlue,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        if (_tickets.isEmpty)
          _buildEmptyState(
            title: 'Aucun billet disponible',
            message: 'Vos billets apparaîtront ici après une réservation.',
          )
        else
          ..._tickets.map(
            (item) => _TicketCard(item: item, onChanged: () => setState(() {})),
          ),
      ],
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _deepBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: _deepBlue.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationItem {
  final String reference;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final String seat;
  final String price;
  final int passengerCount;
  final String beneficiaryName;
  final String requesterPhone;
  final String beneficiaryPhone;
  final String status;

  const _ReservationItem({
    required this.reference,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.seat,
    required this.price,
    required this.passengerCount,
    required this.beneficiaryName,
    required this.requesterPhone,
    required this.beneficiaryPhone,
    required this.status,
  });

  String get route => '$departure → $destination';

  _ReservationItem copyWith({
    String? departure,
    String? destination,
    String? date,
    String? time,
    String? seat,
    String? price,
    int? passengerCount,
    String? beneficiaryName,
    String? requesterPhone,
    String? beneficiaryPhone,
    String? status,
  }) {
    return _ReservationItem(
      reference: reference,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      time: time ?? this.time,
      seat: seat ?? this.seat,
      price: price ?? this.price,
      passengerCount: passengerCount ?? this.passengerCount,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      beneficiaryPhone: beneficiaryPhone ?? this.beneficiaryPhone,
      status: status ?? this.status,
    );
  }
}

class _TicketItem {
  final String code;
  final String departure;
  final String destination;
  final String passenger;
  final int passengerCount;
  final int ticketIndex;
  final String date;
  final String time;
  final String seat;
  final String price;
  final String reference;
  final String gate;

  const _TicketItem({
    required this.code,
    required this.departure,
    required this.destination,
    required this.passenger,
    required this.passengerCount,
    required this.ticketIndex,
    required this.date,
    required this.time,
    required this.seat,
    required this.price,
    required this.reference,
    required this.gate,
  });

  String get route => '$departure → $destination';
}

class _ReservationCard extends StatelessWidget {
  final _ReservationItem item;
  final VoidCallback? onTicketNow;

  const _ReservationCard({required this.item, this.onTicketNow});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF16A34A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.route,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Réf. ${item.reference}',
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HistoryInfoChip(
                  label: item.date,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HistoryInfoChip(
                  label: item.time,
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HistoryInfoChip(
                  label: item.seat,
                  icon: Icons.event_seat_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.price,
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                item.route,
                style: const TextStyle(
                  color: Color(0xFF5F6B86),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          if (onTicketNow != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTicketNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Billet maintenant',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTicketNow == null) return card;

    return InkWell(
      onTap: onTicketNow,
      borderRadius: BorderRadius.circular(22),
      child: card,
    );
  }
}

class _ReservationTicketPage extends StatefulWidget {
  final _ReservationItem reservation;

  const _ReservationTicketPage({required this.reservation});

  @override
  State<_ReservationTicketPage> createState() => _ReservationTicketPageState();
}

class _ReservationTicketPageState extends State<_ReservationTicketPage> {
  late _ReservationItem _reservation;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
  }

  void _editReservation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: _reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          setState(() => _reservation = updated);
        },
      ),
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodSheet(total: _reservation.price),
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await _showCancelReservationDialog(context);
    if (shouldCancel != true) return;

    _HistoryRepository.removeReservation(_reservation.reference);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée.')));
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    final tickets = List.generate(_reservation.passengerCount, (index) {
      return index + 1;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_fofana_no_background.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const Text(
              'Billet',
              style: TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tickets
                      .map(
                        (ticketNumber) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _TicketVisual(
                            departure: _reservation.departure,
                            destination: _reservation.destination,
                            date: _reservation.date,
                            time: _reservation.time,
                            passengerCount: _reservation.passengerCount,
                            ticketIndex: ticketNumber,
                            beneficiaryName: _reservation.beneficiaryName,
                            total: _reservation.price,
                            reference: '${_reservation.reference}$ticketNumber',
                            primaryActionLabel: 'Effectuer le règlement',
                            onPrimaryAction: _showPaymentSheet,
                            onEdit: _editReservation,
                            onCancel: _confirmCancel,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReprogramPage extends StatefulWidget {
  const _ReprogramPage();

  @override
  State<_ReprogramPage> createState() => _ReprogramPageState();
}

class _ReprogramPageState extends State<_ReprogramPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _ticketNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isForSomeoneElse = false;
  _TicketItem? _foundTicket;
  String? _searchMessage;

  @override
  void dispose() {
    _ticketNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  _TicketItem? _findTicket(String rawNumber) {
    final query = _normalize(rawNumber);
    final queryDigits = _digitsOnly(rawNumber);
    if (query.isEmpty) return null;

    for (final ticket in _HistoryRepository.tickets) {
      final ticketNumber = '${ticket.reference}${ticket.ticketIndex}';
      final candidates = <String>[
        ticket.code,
        '${ticket.code}${ticket.ticketIndex}',
        ticket.reference,
        ticketNumber,
      ];

      final hasMatch = candidates.any((candidate) {
        return _normalize(candidate) == query ||
            (queryDigits.isNotEmpty && _digitsOnly(candidate) == queryDigits);
      });
      if (hasMatch) return ticket;
    }
    return null;
  }

  void _searchTicket() {
    final ticketNumber = _ticketNumberController.text.trim();
    final phone = _phoneController.text.trim();

    if (ticketNumber.isEmpty) {
      setState(() {
        _foundTicket = null;
        _searchMessage = 'Veuillez saisir le numéro du billet.';
      });
      return;
    }

    if (_isForSomeoneElse && phone.isEmpty) {
      setState(() {
        _foundTicket = null;
        _searchMessage = 'Veuillez saisir le numéro de téléphone.';
      });
      return;
    }

    final ticket = _findTicket(ticketNumber);
    setState(() {
      _foundTicket = ticket;
      _searchMessage = ticket == null ? 'Aucun billet trouvé.' : null;
    });
  }

  void _editFoundTicket() {
    final ticket = _foundTicket;
    if (ticket == null) return;

    final reservation = _HistoryRepository.reservations.firstWhere(
      (item) => item.reference == ticket.reference,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          setState(() {
            _foundTicket = _findTicket(_ticketNumberController.text.trim());
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_fofana_no_background.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const Text(
              'Reprogrammation',
              style: TextStyle(
                color: _deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _deepBlue.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReprogramTextField(
                            controller: _ticketNumberController,
                            label: 'Numéro du billet',
                            hint: 'Ex: 17600000000001',
                            icon: Icons.confirmation_number_rounded,
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () => setState(
                              () => _isForSomeoneElse = !_isForSomeoneElse,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FBFF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _deepBlue.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _isForSomeoneElse,
                                    activeColor: _fofanaGreen,
                                    onChanged: (value) => setState(
                                      () => _isForSomeoneElse = value ?? false,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Reprogrammer pour quelqu’un',
                                      style: TextStyle(
                                        color: _deepBlue,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isForSomeoneElse) ...[
                            const SizedBox(height: 14),
                            PhoneLoginField(controller: _phoneController),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _searchTicket,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _fofanaGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Rechercher',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_searchMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _searchMessage!,
                        style: const TextStyle(
                          color: _fofanaGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (_foundTicket != null) ...[
                      const SizedBox(height: 18),
                      _TicketVisual(
                        departure: _foundTicket!.departure,
                        destination: _foundTicket!.destination,
                        date: _foundTicket!.date,
                        time: _foundTicket!.time,
                        passengerCount: _foundTicket!.passengerCount,
                        ticketIndex: _foundTicket!.ticketIndex,
                        beneficiaryName: _foundTicket!.passenger,
                        total: _foundTicket!.price,
                        reference:
                            '${_foundTicket!.reference}${_foundTicket!.ticketIndex}',
                        primaryActionLabel: '',
                        onEdit: _editFoundTicket,
                        showPrimaryAction: false,
                        showCancelAction: false,
                        editActionLabel: 'Modifier',
                      ),
                    ],
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

class _ReprogramTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _ReprogramTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: deepBlue),
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        labelStyle: const TextStyle(
          color: deepBlue,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9AA3B8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: deepBlue.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final _TicketItem item;
  final VoidCallback onChanged;

  const _TicketCard({required this.item, required this.onChanged});

  void _editReservation(BuildContext context) {
    final reservation = _HistoryRepository.reservations.firstWhere(
      (item) => item.reference == this.item.reference,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditReservationSheet(
        reservation: reservation,
        onSave: (updated) {
          _HistoryRepository.updateReservation(updated);
          onChanged();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _TicketVisual(
        departure: item.departure,
        destination: item.destination,
        date: item.date,
        time: item.time,
        passengerCount: item.passengerCount,
        ticketIndex: item.ticketIndex,
        beneficiaryName: item.passenger,
        total: item.price,
        reference: '${item.reference}${item.ticketIndex}',
        primaryActionLabel: '',
        onEdit: () => _editReservation(context),
        compact: true,
        showPrimaryAction: false,
        showCancelAction: false,
        editActionLabel: 'Modifier',
      ),
    );
  }
}

class _TicketVisual extends StatelessWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String beneficiaryName;
  final String total;
  final String reference;
  final String primaryActionLabel;
  final int ticketIndex;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final bool compact;
  final bool showPrimaryAction;
  final bool showCancelAction;
  final String? editActionLabel;

  const _TicketVisual({
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.beneficiaryName,
    required this.total,
    required this.reference,
    required this.primaryActionLabel,
    required this.ticketIndex,
    this.onPrimaryAction,
    this.onEdit,
    this.onCancel,
    this.compact = false,
    this.showPrimaryAction = true,
    this.showCancelAction = true,
    this.editActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    const muted = Color(0xFF9AA3B8);

    return Container(
      padding: EdgeInsets.fromLTRB(20, compact ? 22 : 28, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: deepBlue.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TicketRouteCity(label: 'De', city: departure),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: muted.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 1.5,
                        color: muted.withValues(alpha: 0.35),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 1.5,
                        color: muted.withValues(alpha: 0.35),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: muted,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'N° $ticketIndex',
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TicketRouteCity(
                  label: 'À',
                  city: destination,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TicketInfoBlock(
                      label: 'Date de départ',
                      value: date,
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'Heure de départ',
                      value: time,
                      icon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'Bénéficiaire',
                      value: beneficiaryName,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TicketInfoBlock(
                      label: 'Nbr de places',
                      value: 'x$passengerCount',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'N° de billet',
                      value: '#${reference.replaceAll(RegExp(r'[^0-9]'), '')}',
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: Color(0xFF99A4C0)),
                        SizedBox(width: 8),
                        Icon(Icons.ac_unit_rounded, color: Color(0xFF99A4C0)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _TicketInfoBlock(
                      label: 'Total',
                      value: total,
                      valueColor: red,
                      valueSize: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _TicketQrCode(
            data: '$reference-$ticketIndex-$departure-$destination',
          ),
          const SizedBox(height: 20),
          Divider(color: deepBlue.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 20),
          if (showPrimaryAction) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  disabledBackgroundColor: red.withValues(alpha: 0.82),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  primaryActionLabel,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (showCancelAction)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Annuler ma réservation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: deepBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.edit_rounded, color: red, size: 27),
                  ),
                ),
              ],
            )
          else if (onEdit != null)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 21),
                label: Text(
                  editActionLabel ?? 'Modifier',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _TicketRouteCity extends StatelessWidget {
  final String label;
  final String city;
  final bool alignEnd;

  const _TicketRouteCity({
    required this.label,
    required this.city,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFADB4C4),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TicketInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color valueColor;
  final double valueSize;

  const _TicketInfoBlock({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor = const Color(0xFF0B4F2A),
    this.valueSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA6ADBE),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFD67A3A), size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: valueSize,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TicketQrCode extends StatelessWidget {
  final String data;

  const _TicketQrCode({required this.data});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0B4F2A);

    return Center(
      child: Container(
        width: 118,
        height: 118,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dark.withValues(alpha: 0.12)),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: dark),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: dark,
          ),
        ),
      ),
    );
  }
}

class _HistoryInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HistoryInfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF5F6B86)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
        child: Icon(icon, color: const Color(0xFF0B4F2A)),
      ),
    );
  }
}

class _ParcelNotificationIconButton extends StatelessWidget {
  const _ParcelNotificationIconButton();

  void _showClientNotifications(BuildContext context) {
    final currentPhone = SessionStore.currentClientPhone;
    final notifications = List<ParcelRecord>.from(
      ParcelStore.notifications.where(
        (parcel) => currentPhone == null || parcel.senderPhone == currentPhone,
      ),
    );
    ParcelStore.clearNotifications(senderPhone: currentPhone);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
            ),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (notifications.isEmpty)
                  const _ClientNotificationEmptyState()
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final parcel = notifications[index];
                        return _ClientNotificationTile(
                          parcel: parcel,
                          onTap: () {
                            ParcelStore.markNotificationRead(parcel.code);
                            Navigator.pop(sheetContext);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _ClientNotificationDetailPage(
                                  parcel: parcel,
                                ),
                              ),
                            );
                          },
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ParcelStore.notificationCount,
      builder: (context, _, __) {
        final currentPhone = SessionStore.currentClientPhone;
        final count = ParcelStore.unreadNotificationsCount(
          senderPhone: currentPhone,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => _showClientNotifications(context),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ClientNotificationTile extends StatelessWidget {
  final ParcelRecord parcel;
  final VoidCallback onTap;

  const _ClientNotificationTile({required this.parcel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              _ClientParcelThumbnail(parcel: parcel, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcel.status,
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${parcel.parcelNature} vers ${parcel.destinationCity}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFE53935)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientNotificationDetailPage extends StatelessWidget {
  final ParcelRecord parcel;

  const _ClientNotificationDetailPage({required this.parcel});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Détail notification',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            _ClientParcelImage(parcel: parcel),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parcel.status,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Votre colis ${parcel.parcelNature} est enregistré pour ${parcel.destinationCity}.',
                    style: const TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ClientNotificationInfo(
                    icon: Icons.qr_code_2_rounded,
                    label: 'Code colis',
                    value: parcel.code,
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.route_rounded,
                    label: 'Trajet',
                    value:
                        '${parcel.departureCity} - ${parcel.destinationCity}',
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.person_rounded,
                    label: 'Bénéficiaire',
                    value: parcel.recipientFullName,
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.phone_rounded,
                    label: 'Téléphone',
                    value: parcel.recipientPhone,
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.inventory_2_rounded,
                    label: 'Quantité',
                    value: '${parcel.parcelCount} colis',
                  ),
                  if (parcel.attachmentName != null)
                    _ClientNotificationInfo(
                      icon: Icons.attach_file_rounded,
                      label: 'Pièce jointe',
                      value: parcel.attachmentName!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('J’ai compris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientNotificationInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ClientNotificationInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16A34A), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8B93A6),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

class _ClientParcelImage extends StatelessWidget {
  final ParcelRecord parcel;

  const _ClientParcelImage({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path == null || path.trim().isEmpty) {
      return _ClientImageFallback(height: 190, iconSize: 48);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        File(path),
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _ClientImageFallback(height: 190, iconSize: 48),
      ),
    );
  }
}

class _ClientParcelThumbnail extends StatelessWidget {
  final ParcelRecord parcel;
  final double size;

  const _ClientParcelThumbnail({required this.parcel, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path == null || path.trim().isEmpty) {
      return _ClientImageFallback(height: size, width: size, iconSize: 22);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _ClientImageFallback(height: size, width: size, iconSize: 22),
      ),
    );
  }
}

class _ClientImageFallback extends StatelessWidget {
  final double height;
  final double? width;
  final double iconSize;

  const _ClientImageFallback({
    required this.height,
    this.width,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.22),
        ),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: const Color(0xFFE53935),
        size: iconSize,
      ),
    );
  }
}

class _ClientNotificationEmptyState extends StatelessWidget {
  const _ClientNotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: const Text(
        'Aucune notification pour le moment',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF5F6B86),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
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

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/welcomepage', (_) => false);
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
                    onLogoutTap: _logout,
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
  final VoidCallback onLogoutTap;

  const _MainMenuView({
    required this.scrollController,
    required this.onClose,
    required this.onAccountTap,
    required this.onTermsTap,
    required this.onLogoutTap,
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
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
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
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Image.asset(
            'assets/images/logo_fofana_no_background.png',
            height: 62,
          ),
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 62),
          ),
          const SizedBox(height: 16),
          const Text(
            'Client Fofana',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
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
          _MenuOptionTile(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
            onTap: onLogoutTap,
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Fermer le menu'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0B4F2A),
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
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
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
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
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
                  color: Color(0xFF0B4F2A),
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
  XFile? _pickedAvatar;

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 900,
    );
    if (file == null || !mounted) return;
    setState(() => _pickedAvatar = file);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 42 + bottomInset),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: widget.onBack,
              ),
              const Expanded(
                child: Text(
                  'Mon compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 52),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 68,
                  backgroundColor: const Color(0xFF58648D),
                  backgroundImage: _pickedAvatar == null
                      ? null
                      : FileImage(File(_pickedAvatar!.path)),
                  child: _pickedAvatar == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 88,
                        )
                      : null,
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF0B4F2A), size: 25),
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
              color: Color(0xFF0B4F2A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "L'utilisation de l'application Fofana implique le respect des règles de réservation, de paiement et de transport. Les informations saisies doivent être exactes afin de faciliter les voyages, les colis et l'assistance client.",
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
    _nameController = TextEditingController(text: 'Client Fofana');
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
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Carte profil agrandie pour rendre les champs et les actions plus lisibles.
      padding: const EdgeInsets.all(18),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations personnelles',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF0B4F2A),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Photo, nom, prénom et contacts',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF5F6B86),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: _toggleEdit,
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      size: 21,
                    ),
                    label: Text(_isEditing ? 'Enregistrer' : 'Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 18),
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
      // Bloc statistiques agrandi pour éviter les libellés trop serrés.
      padding: const EdgeInsets.all(18),
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
              color: Color(0xFF0B4F2A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16),
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
    return Column(
      children: [
        const _AccountStat(
          icon: Icons.calendar_month_rounded,
          title: 'Création du compte',
          value: '11 mai 2026',
          isWide: true,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          // Les trois autres cartes restent en grille compacte et lisible.
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
          children: const [
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
        ),
      ],
    );
  }
}

class _AccountStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isWide;

  const _AccountStat({
    required this.icon,
    required this.title,
    required this.value,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF16A34A), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              // Carte Création sur toute la largeur pour afficher la date complète.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '11 mai 2026',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Création du compte',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 13,
                      height: 1.15,
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: const Color(0xFF16A34A), size: 18),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Libellé sur toute la largeur de la carte pour éviter les coupures à côté de l'icône.
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w800,
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
      // Champs de profil agrandis pour une meilleure lecture et une zone tactile plus confortable.
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFFFF7F7) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? const Color(0xFF16A34A).withValues(alpha: 0.18)
              : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0B4F2A), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 16,
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
