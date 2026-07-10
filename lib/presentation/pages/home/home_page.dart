import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:code_initial/features/parcel/presentation/pages/parcel_pages.dart';
import 'package:code_initial/features/parcel/data/parcel_store.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/presentation/pages/tarifs/tarifs_page.dart';
import 'package:code_initial/widgets/login/login_widgets.dart';
import 'package:code_initial/widgets/tarifs/tarifs_widgets.dart';

part 'parts/location_section.dart';
part 'parts/news_section.dart';
part 'parts/reservation_flow.dart';
part 'parts/history_section.dart';
part 'parts/menu_account_section.dart';

// Page racine de l espace client: conserve les imports, les constantes partagees et le shell principal.

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

  static List<_TicketItem> get tickets {
    return reservations.map((reservation) {
      final ticketSeat = reservation.seat;
      return _TicketItem(
        code: reservation.reference.replaceFirst('TB', 'TK'),
        departure: reservation.departure,
        destination: reservation.destination,
        passenger: reservation.beneficiaryName,
        passengerCount: reservation.passengerCount,
        ticketIndex: 1,
        date: reservation.date,
        time: reservation.time,
        seat: ticketSeat,
        price: reservation.price,
        reference: reservation.reference,
        gate:
            'A${ticketSeat.replaceAll(RegExp(r'[^0-9]'), '').padLeft(2, '0')}',
      );
    }).toList();
  }

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
          onCreateReservation: _openReservationFromTarif,
        ),
      ),
    );
  }

  void _openReservationFromTarif(
    BuildContext context,
    TarifReservationSelection selection,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReservationPage(
          initialDeparture: selection.departure,
          initialDestination: selection.destination,
          initialDateLabel: selection.date,
          initialTime: selection.time,
          initialPassengerCount: selection.passengerCount,
          initialPriceAmount: selection.priceAmount,
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
