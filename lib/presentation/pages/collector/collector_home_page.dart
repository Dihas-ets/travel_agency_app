import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:code_initial/presentation/pages/parcel/colis_attente_page.dart';
import 'package:code_initial/presentation/pages/parcel/parcel_pages.dart';
import 'package:code_initial/models/expense_model.dart';
import 'package:code_initial/presentation/pages/expense/expense_store.dart';
import 'package:code_initial/presentation/pages/expense/manual_expense_page.dart';
import 'package:code_initial/presentation/pages/expense/qr_scanner_page.dart';

class CollectorHomePage extends StatefulWidget {
  const CollectorHomePage({super.key});

  @override
  State<CollectorHomePage> createState() => _CollectorHomePageState();
}

class _CollectorHomePageState extends State<CollectorHomePage> {
  int _currentIndex = 0;

  final List<_CollectorTab> _tabs = const [
    _CollectorTab('Voyage', Icons.directions_bus_filled_rounded),
    _CollectorTab('Colis', Icons.inventory_2_rounded),
    _CollectorTab('Depense', Icons.payments_rounded),
    _CollectorTab('Profil', Icons.person_rounded),
  ];

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CollectorMainMenuSheet(),
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
                      child: _CollectorHeaderIconButton(
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
                      child: _CollectorNotificationIconButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Espace percepteur',
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
                Expanded(child: _CollectorTabContent(tab: currentTab)),
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

class _CollectorNotificationStore {
  static final ValueNotifier<int> count = ValueNotifier<int>(3);
  static final List<_CollectorNotificationItem> notifications = [
    _CollectorNotificationItem(
      title: 'Bienvenue',
      message: 'Votre espace percepteur Fofana est prêt.',
      time: 'Maintenant',
    ),
    _CollectorNotificationItem(
      title: 'Voyage',
      message: 'Consultez les réservations et confirmez les paiements.',
      time: 'Aujourd’hui',
    ),
    _CollectorNotificationItem(
      title: 'Colis',
      message: 'Les nouvelles opérations colis apparaîtront ici.',
      time: 'Aujourd’hui',
    ),
  ];

  static void add({
    String title = 'Nouvelle notification',
    String message = 'Une nouvelle opération a été enregistrée.',
  }) {
    notifications.insert(
      0,
      _CollectorNotificationItem(
        title: title,
        message: message,
        time: 'Maintenant',
      ),
    );
    count.value += 1;
  }

  static void clear() => count.value = 0;
}

class _CollectorNotificationItem {
  final String title;
  final String message;
  final String time;

  const _CollectorNotificationItem({
    required this.title,
    required this.message,
    required this.time,
  });
}

class _CollectorProfileData {
  final String fullName;
  final String phone;
  final String agency;
  final String role;

  const _CollectorProfileData({
    required this.fullName,
    required this.phone,
    required this.agency,
    required this.role,
  });

  _CollectorProfileData copyWith({
    String? fullName,
    String? phone,
    String? agency,
    String? role,
  }) {
    return _CollectorProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      role: role ?? this.role,
    );
  }
}

class _CollectorProfileStore {
  static final ValueNotifier<_CollectorProfileData> profile =
      ValueNotifier<_CollectorProfileData>(
        const _CollectorProfileData(
          fullName: 'Percepteur Fofana',
          phone: '+229 01 00 00 00 00',
          agency: 'Cotonou',
          role: 'Percepteur voyage',
        ),
      );

  static void update(_CollectorProfileData data) {
    profile.value = data;
  }
}

class _CollectorParcelRecord {
  final String id;
  final String collectorPhone;
  final String receiverName;
  final String receiverPhone;
  final String image;
  final String destination;
  String status;

  _CollectorParcelRecord({
    required this.id,
    required this.collectorPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.image,
    required this.destination,
    required this.status,
  });
}

class _CollectorColisContent extends StatefulWidget {
  const _CollectorColisContent();

  @override
  State<_CollectorColisContent> createState() => _CollectorColisContentState();
}

class _CollectorColisContentState extends State<_CollectorColisContent> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _green = Color(0xFF16A34A);
  static const Color _mutedText = Color(0xFF5F6B86);

  final List<_CollectorParcelRecord> _availableParcels = [
    _CollectorParcelRecord(
      id: 'CL-2401',
      collectorPhone: '+229 01 61 44 20 90',
      receiverName: 'Aminata Sanni',
      receiverPhone: '+229 01 97 12 43 10',
      image: 'assets/images/coli1.jpg',
      destination: 'Cotonou',
      status: 'En attente',
    ),
    _CollectorParcelRecord(
      id: 'CL-2402',
      collectorPhone: '+229 01 66 30 18 75',
      receiverName: 'Boris Adjovi',
      receiverPhone: '+229 01 62 54 88 03',
      image: 'assets/images/coli3.jpg',
      destination: 'Porto-Novo',
      status: 'En attente',
    ),
    _CollectorParcelRecord(
      id: 'CL-2403',
      collectorPhone: '+229 01 95 70 11 42',
      receiverName: 'Clarisse Hounkpe',
      receiverPhone: '+229 01 68 13 06 54',
      image: 'assets/images/coli4.jpg',
      destination: 'Abomey',
      status: 'En attente',
    ),
  ];

  final List<_CollectorParcelRecord> _transitParcels = [
    _CollectorParcelRecord(
      id: 'CL-2398',
      collectorPhone: '+229 01 64 91 82 77',
      receiverName: 'Didier Koto',
      receiverPhone: '+229 01 91 03 24 78',
      image: 'assets/images/coli2.jpg',
      destination: 'Parakou',
      status: 'Arriver',
    ),
  ];

  String? _selectedPhone;
  String _searchQuery = '';
  int _selectedColisMenuIndex = 0;

  List<_CollectorParcelRecord> get _filteredParcels {
    if (_searchQuery.isEmpty) return _availableParcels;
    final query = _searchQuery.toLowerCase();
    return _availableParcels.where((parcel) {
      return parcel.id.toLowerCase().contains(query) ||
          parcel.receiverName.toLowerCase().contains(query) ||
          parcel.receiverPhone.toLowerCase().contains(query) ||
          parcel.collectorPhone.toLowerCase().contains(query);
    }).toList();
  }

  _CollectorParcelRecord? get _selectedParcel {
    if (_selectedPhone == null) return null;
    for (final parcel in _availableParcels) {
      if (parcel.collectorPhone == _selectedPhone) return parcel;
    }
    return null;
  }

  void _acceptSelectedParcel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer',
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir accepter le colis ${_selectedParcel?.id} ?',
          style: const TextStyle(color: _mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final parcel = _selectedParcel;
              if (parcel == null) return;
              if (_transitParcels.any((item) => item.id == parcel.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Ce colis est deja dans la liste en transit.',
                    ),
                    backgroundColor: _deepBlue,
                  ),
                );
                return;
              }

              setState(() {
                parcel.status = 'Arriver';
                _transitParcels.insert(0, parcel);
                _selectedPhone = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Colis ${parcel.id} accepte.'),
                  backgroundColor: _green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer',
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vider la sélection ?',
          style: TextStyle(color: _mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _selectedPhone = null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _deepBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _removeParcel(_CollectorParcelRecord parcel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer',
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir retirer le colis ${parcel.id} du transit ?',
          style: const TextStyle(color: _mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(
                () =>
                    _transitParcels.removeWhere((item) => item.id == parcel.id),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Colis ${parcel.id} retire du transit.'),
                  backgroundColor: _deepBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(_CollectorParcelRecord parcel) {
    setState(() {
      parcel.status = parcel.status == 'Arriver' ? 'Recuperer' : 'Arriver';
    });
  }

  void _showParcelDetail(_CollectorParcelRecord parcel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          parcel.id,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                parcel.image,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text('Percepteur : ${parcel.collectorPhone}'),
            Text('Recepteur : ${parcel.receiverName}'),
            Text('Telephone : ${parcel.receiverPhone}'),
            Text('Destination : ${parcel.destination}'),
            Text('Statut : ${parcel.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedParcel = _selectedParcel;

    return Column(
      children: [
        _CollectorColisModeTabs(
          selectedIndex: _selectedColisMenuIndex,
          onChanged: (index) => setState(() => _selectedColisMenuIndex = index),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _selectedColisMenuIndex == 0
              ? _buildEmbarquementContent(selectedParcel)
              : const ColisAttentePage(initialTabIndex: 0, showHeader: false),
        ),
      ],
    );
  }

  Widget _buildEmbarquementContent(_CollectorParcelRecord? selectedParcel) {
    return Stack(
      children: [
        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _deepBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _deepBlue.withValues(alpha: 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestion des colis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_transitParcels.length} colis en transit',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: _deepBlue.withValues(alpha: 0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouveau colis à accepter',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Sélectionnez le numéro du percepteur pour afficher les informations du colis.',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 560;
                        final phoneField = DropdownButtonFormField<String>(
                          initialValue: _selectedPhone,
                          isExpanded: true,
                          decoration: _collectorColisInputDecoration(
                            label: 'Numero du recepteur',
                            icon: Icons.phone_rounded,
                          ),
                          items: _filteredParcels
                              .map(
                                (parcel) => DropdownMenuItem(
                                  value: parcel.collectorPhone,
                                  child: Text(parcel.collectorPhone),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedPhone = value),
                        );
                        final receiverField = TextFormField(
                          readOnly: true,
                          initialValue: selectedParcel?.receiverName ?? '',
                          key: ValueKey(selectedParcel?.receiverName ?? ''),
                          decoration: _collectorColisInputDecoration(
                            label: 'Nom du recepteur',
                            icon: Icons.person_rounded,
                          ),
                        );

                        if (compact) {
                          return Column(
                            children: [
                              phoneField,
                              const SizedBox(height: 12),
                              receiverField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: phoneField),
                            const SizedBox(width: 12),
                            Expanded(child: receiverField),
                          ],
                        );
                      },
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        color: const Color(0xFFF8FBFF),
                        child: selectedParcel == null
                            ? const Center(
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  color: _green,
                                  size: 54,
                                ),
                              )
                            : Image.asset(
                                selectedParcel.image,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: selectedParcel == null
                                ? null
                                : _acceptSelectedParcel,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Accepter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _green.withValues(
                                alpha: 0.35,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectedPhone == null
                                ? null
                                : _clearSelection,
                            icon: const Icon(Icons.cleaning_services_rounded),
                            label: const Text('Vider'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _deepBlue,
                              side: BorderSide(
                                color: _deepBlue.withValues(alpha: 0.26),
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Colis en transit',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${_transitParcels.length} élément${_transitParcels.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  labelText: 'Rechercher',
                  hintText: 'ID / Nom / Téléphone / N° de coli',
                  prefixIcon: const Icon(Icons.search_rounded, color: _green),
                  filled: true,
                  fillColor: const Color(0xFFF8FBFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _CollectorTransitParcelTable(
                parcels: _transitParcels,
                onView: _showParcelDetail,
                onRemove: _removeParcel,
                onToggleStatus: _toggleStatus,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 18,
          right: 18,
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SendParcelPage(showModeTabs: false),
              );
            },
            backgroundColor: _green,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _CollectorColisModeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CollectorColisModeTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _CollectorColisModeButton(
            label: 'Embarquement',
            icon: Icons.local_shipping_rounded,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 6),
          _CollectorColisModeButton(
            label: 'Enregistrement',
            icon: Icons.check_circle_rounded,
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _CollectorColisModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CollectorColisModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? green : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : deepBlue.withValues(alpha: 0.72),
                size: 19,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : deepBlue.withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

InputDecoration _collectorColisInputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF16A34A)),
    filled: true,
    fillColor: const Color(0xFFF8FBFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
    ),
  );
}

class _CollectorTransitParcelTable extends StatelessWidget {
  final List<_CollectorParcelRecord> parcels;
  final ValueChanged<_CollectorParcelRecord> onView;
  final ValueChanged<_CollectorParcelRecord> onRemove;
  final ValueChanged<_CollectorParcelRecord> onToggleStatus;

  const _CollectorTransitParcelTable({
    required this.parcels,
    required this.onView,
    required this.onRemove,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);
    const mutedText = Color(0xFF5F6B86);

    if (parcels.isEmpty) {
      return const _CollectorEmptyCard(
        title: 'Aucun colis en transit',
        message: 'Les colis acceptes apparaitront ici.',
      );
    }

    return Column(
      children: List.generate(parcels.length, (index) {
        final parcel = parcels[index];
        final isRecovered = parcel.status == 'Recuperer';

        return Container(
          margin: EdgeInsets.only(bottom: index == parcels.length - 1 ? 0 : 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      parcel.image,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 58,
                        height: 58,
                        color: const Color(0xFFEAF7EF),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parcel.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: deepBlue,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parcel.receiverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: mutedText,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CollectorParcelStatusPill(
                    label: isRecovered ? 'Récupéré' : 'Arrivé',
                    strong: isRecovered,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onView(parcel),
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text('Voir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: deepBlue,
                        side: BorderSide(
                          color: deepBlue.withValues(alpha: 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onToggleStatus(parcel),
                      icon: Icon(
                        isRecovered
                            ? Icons.restart_alt_rounded
                            : Icons.check_circle_rounded,
                        size: 18,
                      ),
                      label: Text(isRecovered ? 'Remettre' : 'Récupérer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => onRemove(parcel),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF7EF),
                      foregroundColor: deepBlue,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Retirer',
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CollectorParcelStatusPill extends StatelessWidget {
  final String label;
  final bool strong;

  const _CollectorParcelStatusPill({required this.label, required this.strong});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: strong
            ? green.withValues(alpha: 0.12)
            : deepBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: strong
              ? green.withValues(alpha: 0.26)
              : deepBlue.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: strong ? green : deepBlue,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CollectorTabContent extends StatelessWidget {
  final _CollectorTab tab;

  const _CollectorTabContent({required this.tab});

  @override
  Widget build(BuildContext context) {
    if (tab.title == 'Voyage') {
      return const _CollectorVoyageContent();
    }
    if (tab.title == 'Colis') {
      return const _CollectorColisContent();
    }
    if (tab.title == 'Depense') {
      return const _CollectorDepenseContent();
    }
    if (tab.title == 'Profil') {
      return const _CollectorProfileTabContent();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
          width: 1.1,
        ),
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
          Icon(tab.icon, color: const Color(0xFF16A34A), size: 34),
          const SizedBox(height: 14),
          Text(
            tab.title,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _descriptionFor(tab.title),
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _descriptionFor(String title) {
    switch (title) {
      case 'Voyage':
        return 'Gestion des voyages et des opérations liées aux tickets.';
      case 'Colis':
        return 'Suivi et traitement des colis confiés au percepteur.';
      case 'Depense':
        return 'Consultation et saisie des dépenses de service.';
      default:
        return 'Informations et paramètres du compte percepteur.';
    }
  }
}

class _CollectorDepenseContent extends StatefulWidget {
  const _CollectorDepenseContent();

  @override
  State<_CollectorDepenseContent> createState() =>
      _CollectorDepenseContentState();
}

class _CollectorDepenseContentState extends State<_CollectorDepenseContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final expenseStore = ExpenseStore();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            builder: (context, expenses, _) => _buildExpenseMenu(expenses),
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
                  child: FloatingActionButton(
                    onPressed: _showAddExpenseSheet,
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B4F2A), Color(0xFF168A43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
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
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_card_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ajouter dépense',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QRScannerPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text('Scanner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B4F2A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ManualExpensePage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Saisie'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
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
      },
    );
  }

  // ignore: unused_element
  Widget _buildDashboardHeader(List<ExpenseModel> expenses) {
    final ongoingExpenses = expenses
        .where((expense) => expense.status == 'En cours')
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
                          'Total en cours',
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRScannerPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B4F2A),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManualExpensePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Saisie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseMenu(List<ExpenseModel> expenses) {
    final ongoingExpenses = expenses
        .where((expense) => expense.status == 'En cours')
        .toList();
    final historicalExpenses = expenses
        .where((expense) => expense.status != 'En cours')
        .toList();
    final ongoingTotal = ongoingExpenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );
    final historyTotal = historicalExpenses.fold<double>(
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
            title: 'En cours',
            detail: '${ongoingTotal.toStringAsFixed(0)} FCFA',
            onTap: () => _tabController.animateTo(0),
          ),
          const SizedBox(width: 10),
          _buildMenuButton(
            selected: _tabController.index == 1,
            icon: Icons.history_rounded,
            title: 'Historique',
            detail: '${historyTotal.toStringAsFixed(0)} FCFA',
            onTap: () => _tabController.animateTo(1),
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

  // Onglet "En cours"
  Widget _buildOngoingTab() {
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: expenseStore.expensesNotifier,
      builder: (context, expenses, _) {
        final ongoingExpenses = expenses
            .where((e) => e.status == 'En cours')
            .toList();

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
                  'Aucune dépense en cours',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ajoutez une nouvelle dépense ou scannez un QR.',
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
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final expense = ongoingExpenses[index];
            return _buildModernExpenseCard(expense);
          },
        );
      },
    );
  }

  // Onglet "Historique"
  Widget _buildHistoricalTab() {
    return ValueListenableBuilder<List<ExpenseModel>>(
      valueListenable: expenseStore.expensesNotifier,
      builder: (context, expenses, _) {
        final historicalExpenses = expenses
            .where((e) => e.status != "En cours")
            .toList();

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
                  'Les dépenses validées apparaîtront ici.',
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
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final expense = historicalExpenses[index];
            return _buildHistoricalExpenseTile(expense);
          },
        );
      },
    );
  }

  Widget _buildHistoricalExpenseTile(ExpenseModel expense) {
    final totalAmount = expense.cost * expense.quantity;
    final trajet = _expenseTrajet(expense);
    final matricule = _expenseMatricule(expense);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showExpenseDetail(expense),
        child: Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Color(0xFF16A34A),
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Bus: $matricule',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(expense.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${totalAmount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
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
    final totalAmount = expense.cost * expense.quantity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
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
                    Icons.route_rounded,
                    'Trajet',
                    _expenseTrajet(expense),
                  ),
                  _buildExpenseDetailRow(
                    Icons.directions_bus_rounded,
                    'Matricule du bus',
                    _expenseMatricule(expense),
                  ),
                  _buildExpenseDetailRow(
                    Icons.label_rounded,
                    'Libellé',
                    expense.libelle,
                  ),
                  _buildExpenseDetailRow(
                    Icons.description_rounded,
                    'Description',
                    expense.description.isEmpty
                        ? 'Aucune description'
                        : expense.description,
                  ),
                  _buildExpenseDetailRow(
                    Icons.payments_rounded,
                    'Coût',
                    '${expense.cost.toStringAsFixed(0)} FCFA',
                  ),
                  _buildExpenseDetailRow(
                    Icons.numbers_rounded,
                    'Quantité',
                    '${expense.quantity}',
                  ),
                  _buildExpenseDetailRow(
                    Icons.account_balance_wallet_rounded,
                    'Total',
                    '${totalAmount.toStringAsFixed(0)} FCFA',
                  ),
                  _buildExpenseDetailRow(
                    Icons.sticky_note_2_rounded,
                    'Note',
                    expense.note.isEmpty ? 'Aucune note' : expense.note,
                  ),
                  _buildExpenseDetailRow(
                    Icons.chat_bubble_outline_rounded,
                    'Remarque',
                    expense.qrCode != null
                        ? 'Dépense ajoutée depuis un QR code'
                        : 'Dépense ajoutée en saisie manuelle',
                  ),
                  _buildExpenseDetailRow(
                    Icons.schedule_rounded,
                    'Date et heure',
                    _formatDate(expense.createdAt),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  String _expenseTrajet(ExpenseModel expense) {
    final description = expense.description.trim();
    if (description.isNotEmpty) return description;
    return 'Trajet non renseigné';
  }

  String _expenseMatricule(ExpenseModel expense) {
    final source = '${expense.libelle} ${expense.description} ${expense.note}';
    final match = RegExp(
      r'(?:matricule|bus)\s*[:\-]?\s*([A-Za-z0-9\- ]{3,})',
      caseSensitive: false,
    ).firstMatch(source);
    final value = match?.group(1)?.trim();
    if (value != null && value.isNotEmpty) return value;
    return 'Matricule non renseigné';
  }

  Widget _buildModernExpenseCard(ExpenseModel expense) {
    final totalAmount = expense.cost * expense.quantity;
    final statusColor = _getStatusColor(expense.status);
    final fromQr = expense.qrCode != null;

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  fromQr ? Icons.qr_code_2_rounded : Icons.receipt_long_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.libelle,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    if (expense.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        expense.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  expense.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF16A34A),
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Montant total',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildExpenseChip(
                icon: Icons.sell_rounded,
                label: 'Unité',
                value: '${expense.cost.toStringAsFixed(0)} FCFA',
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(width: 10),
              _buildExpenseChip(
                icon: Icons.inventory_2_rounded,
                label: 'Quantité',
                value: '${expense.quantity}',
                color: const Color(0xFFFF9500),
              ),
            ],
          ),
          if (expense.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_rounded,
                    color: Color(0xFFFF9500),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      expense.note,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
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
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fromQr ? Icons.qr_code_rounded : Icons.edit_note_rounded,
                    color: const Color(0xFF64748B),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    fromQr ? 'QR' : 'Manuel',
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
        ],
      ),
    );
  }

  Widget _buildExpenseChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                        '${expense.quantity}',
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
                  expense.status,
                  style: TextStyle(
                    color: _getStatusColor(expense.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (expense.status == 'En cours') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ExpenseStore().updateExpenseStatus(expense.id, 'Validé');
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ExpenseStore().updateExpenseStatus(expense.id, 'Rejeté');
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Rejeter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "En cours":
        return const Color(0xFFFF9500);
      case "Historique":
        return const Color(0xFF16A34A);
      case "Validé":
        return const Color(0xFF16A34A);
      case "Rejeté":
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

class _CollectorHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorHeaderIconButton({required this.icon, required this.onTap});

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

class _CollectorNotificationIconButton extends StatefulWidget {
  const _CollectorNotificationIconButton();

  @override
  State<_CollectorNotificationIconButton> createState() =>
      _CollectorNotificationIconButtonState();
}

class _CollectorNotificationIconButtonState
    extends State<_CollectorNotificationIconButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _CollectorNotificationStore.count,
      builder: (context, count, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _CollectorHeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {
                _CollectorNotificationStore.clear();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const _CollectorNotificationsSheet(),
                );
              },
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

class _CollectorNotificationsSheet extends StatelessWidget {
  const _CollectorNotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final notifications = _CollectorNotificationStore.notifications;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.36,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (notifications.isEmpty)
                const _CollectorEmptyCard(
                  title: 'Aucune notification',
                  message: 'Les alertes de réservation apparaîtront ici.',
                )
              else
                ...notifications.map(
                  (item) => _CollectorNotificationTile(
                    item: item,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              _CollectorNotificationDetailPage(item: item),
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
}

class _CollectorNotificationTile extends StatelessWidget {
  final _CollectorNotificationItem item;
  final VoidCallback onTap;

  const _CollectorNotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFE53935),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Color(0xFF9AA4BA),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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

class _CollectorNotificationDetailPage extends StatelessWidget {
  final _CollectorNotificationItem item;

  const _CollectorNotificationDetailPage({required this.item});

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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  const Text(
                    'Message',
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorMainMenuSheet extends StatefulWidget {
  const _CollectorMainMenuSheet();

  @override
  State<_CollectorMainMenuSheet> createState() =>
      _CollectorMainMenuSheetState();
}

enum _CollectorMainMenuTarget { profile, assignments, parcels, terms, logout }

class _CollectorMainMenuSheetState extends State<_CollectorMainMenuSheet> {
  bool _showProfile = false;
  _CollectorMainMenuTarget? _selectedMenu;

  void _selectMenu(_CollectorMainMenuTarget target) {
    setState(() => _selectedMenu = target);
  }

  void _openProfile() {
    setState(() {
      _selectedMenu = _CollectorMainMenuTarget.profile;
      _showProfile = true;
    });
  }

  void _openAssignments() {
    _selectMenu(_CollectorMainMenuTarget.assignments);
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(builder: (_) => const _CollectorAssignmentsPage()),
    );
  }

  void _openParcels() {
    _selectMenu(_CollectorMainMenuTarget.parcels);
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(initialTabIndex: 1),
      ),
    );
  }

  void _showTerms() {
    _selectMenu(_CollectorMainMenuTarget.terms);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CollectorTermsSheet(),
    );
  }

  void _logout() {
    _selectMenu(_CollectorMainMenuTarget.logout);
    Navigator.of(context).pushNamedAndRemoveUntil('/welcomepage', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.76,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _showProfile
                ? _CollectorProfileMenuView(
                    key: const ValueKey('collector-profile'),
                    scrollController: scrollController,
                    onBack: () => setState(() => _showProfile = false),
                  )
                : _CollectorMainMenuView(
                    key: const ValueKey('collector-menu'),
                    scrollController: scrollController,
                    selectedMenu: _selectedMenu,
                    onClose: () => Navigator.pop(context),
                    onProfileTap: _openProfile,
                    onAssignmentsTap: _openAssignments,
                    onParcelsTap: _openParcels,
                    onTermsTap: _showTerms,
                    onLogoutTap: _logout,
                  ),
          ),
        );
      },
    );
  }
}

class _CollectorMainMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final _CollectorMainMenuTarget? selectedMenu;
  final VoidCallback onClose;
  final VoidCallback onProfileTap;
  final VoidCallback onAssignmentsTap;
  final VoidCallback onParcelsTap;
  final VoidCallback onTermsTap;
  final VoidCallback onLogoutTap;

  const _CollectorMainMenuView({
    super.key,
    required this.scrollController,
    required this.selectedMenu,
    required this.onClose,
    required this.onProfileTap,
    required this.onAssignmentsTap,
    required this.onParcelsTap,
    required this.onTermsTap,
    required this.onLogoutTap,
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
            'Percepteur Fofana',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 26),
          const _CollectorMenuSectionTitle(
            icon: Icons.grid_view_rounded,
            title: 'Menu principal',
          ),
          const SizedBox(height: 10),
          _CollectorMenuOptionTile(
            icon: Icons.account_circle_outlined,
            title: 'Profil',
            isSelected: selectedMenu == _CollectorMainMenuTarget.profile,
            onTap: onProfileTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Mes affectations',
            isSelected: selectedMenu == _CollectorMainMenuTarget.assignments,
            onTap: onAssignmentsTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.inventory_2_rounded,
            title: 'Mes colis enregistrés',
            isSelected: selectedMenu == _CollectorMainMenuTarget.parcels,
            onTap: onParcelsTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.description_outlined,
            title: "Conditions d'utilisation",
            isSelected: selectedMenu == _CollectorMainMenuTarget.terms,
            onTap: onTermsTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
            isSelected: selectedMenu == _CollectorMainMenuTarget.logout,
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

class _CollectorMenuSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CollectorMenuSectionTitle({required this.icon, required this.title});

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

class _CollectorMenuOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _CollectorMenuOptionTile({
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
              color: const Color(0xFF0B4F2A).withValues(alpha: 0.42),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorProfileMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;

  const _CollectorProfileMenuView({
    super.key,
    required this.scrollController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 42),
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
              _CollectorRoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/logo_fofana_no_background.png',
                  height: 70,
                ),
              ),
              const SizedBox(width: 52),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Profil percepteur',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 68,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 88),
          ),
          const SizedBox(height: 24),
          const _CollectorProfilePanel(),
        ],
      ),
    );
  }
}

class _CollectorRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorRoundIconButton({required this.icon, required this.onTap});

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

class _CollectorProfilePanel extends StatelessWidget {
  const _CollectorProfilePanel();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_CollectorProfileData>(
      valueListenable: _CollectorProfileStore.profile,
      builder: (context, profile, _) {
        return _CollectorProfileEditor(profile: profile);
      },
    );
  }
}

class _CollectorProfileEditor extends StatefulWidget {
  final _CollectorProfileData profile;

  const _CollectorProfileEditor({required this.profile});

  @override
  State<_CollectorProfileEditor> createState() =>
      _CollectorProfileEditorState();
}

class _CollectorProfileEditorState extends State<_CollectorProfileEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _agencyController;
  late final TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _agencyController = TextEditingController(text: widget.profile.agency);
    _roleController = TextEditingController(text: widget.profile.role);
  }

  @override
  void didUpdateWidget(covariant _CollectorProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.fullName;
      _phoneController.text = widget.profile.phone;
      _agencyController.text = widget.profile.agency;
      _roleController.text = widget.profile.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _agencyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final nextProfile = widget.profile.copyWith(
      fullName: _nameController.text.trim().isEmpty
          ? widget.profile.fullName
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? widget.profile.phone
          : _phoneController.text.trim(),
      agency: _agencyController.text.trim().isEmpty
          ? widget.profile.agency
          : _agencyController.text.trim(),
      role: _roleController.text.trim().isEmpty
          ? widget.profile.role
          : _roleController.text.trim(),
    );

    _CollectorProfileStore.update(nextProfile);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil percepteur mis à jour.'),
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        children: [
          _CollectorProfileEditField(
            icon: Icons.badge_rounded,
            label: 'Nom et prénom',
            controller: _nameController,
          ),
          const SizedBox(height: 14),
          _CollectorProfileEditField(
            icon: Icons.phone_rounded,
            label: 'Téléphone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _CollectorProfileEditField(
            icon: Icons.location_city_rounded,
            label: 'Agence',
            controller: _agencyController,
          ),
          const SizedBox(height: 14),
          _CollectorProfileEditField(
            icon: Icons.work_rounded,
            label: 'Fonction',
            controller: _roleController,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Enregistrer le profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
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
    );
  }
}

class _CollectorProfileEditField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _CollectorProfileEditField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
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
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Color(0xFF0B4F2A),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Color(0xFF5F6B86),
                  fontWeight: FontWeight.w800,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorProfileTabContent extends StatelessWidget {
  const _CollectorProfileTabContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        Center(
          child: CircleAvatar(
            radius: 52,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 66),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Profil percepteur',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 18),
        _CollectorProfilePanel(),
      ],
    );
  }
}

class _CollectorTermsSheet extends StatelessWidget {
  const _CollectorTermsSheet();

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
        mainAxisSize: MainAxisSize.min,
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
            "L'utilisation de l'espace percepteur Fofana implique le respect des règles de validation des tickets, de présence et de traitement des opérations voyage.",
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

class _CollectorVoyageContent extends StatelessWidget {
  const _CollectorVoyageContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        _CollectorNewsSection(),
        SizedBox(height: 22),
        _CollectorVoyageMenu(),
      ],
    );
  }
}

class _CollectorVoyageMenu extends StatelessWidget {
  const _CollectorVoyageMenu();

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
        _CollectorMenuButton(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Affectations',
          isWide: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const _CollectorAssignmentsPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.login_rounded,
                label: 'Connexion',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CollectorConnectionPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Validation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _TicketValidationPage(),
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
              child: _CollectorMenuButton(
                icon: Icons.confirmation_number_rounded,
                label: 'Réservation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CollectorReservationPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.history_rounded,
                label: 'Historique',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CollectorHistoryPage(),
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

class _CollectorMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const _CollectorMenuButton({
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
                    _CollectorMenuButtonIcon(icon: icon),
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
                    _CollectorMenuButtonIcon(icon: icon),
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

class _CollectorMenuButtonIcon extends StatelessWidget {
  final IconData icon;

  const _CollectorMenuButtonIcon({required this.icon});

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

enum _CollectorAssignmentFilter { current, scheduled, past }

enum _CollectorAssignmentPastStatusFilter { all, completed, reassigned, absent }

extension on _CollectorAssignmentPastStatusFilter {
  String get label {
    switch (this) {
      case _CollectorAssignmentPastStatusFilter.all:
        return 'Tous';
      case _CollectorAssignmentPastStatusFilter.completed:
        return 'Effectué';
      case _CollectorAssignmentPastStatusFilter.reassigned:
        return 'Réaffecter';
      case _CollectorAssignmentPastStatusFilter.absent:
        return 'Absent';
    }
  }

  bool matches(String status) {
    switch (this) {
      case _CollectorAssignmentPastStatusFilter.all:
        return true;
      case _CollectorAssignmentPastStatusFilter.completed:
        return status == 'Effectué';
      case _CollectorAssignmentPastStatusFilter.reassigned:
        return status == 'Réaffecter';
      case _CollectorAssignmentPastStatusFilter.absent:
        return status == 'Absent';
    }
  }
}

class _CollectorAssignmentCollector {
  final String name;
  final String phone;

  const _CollectorAssignmentCollector({
    required this.name,
    required this.phone,
  });
}

class _CollectorAssignmentRecord {
  final String date;
  final String time;
  final String busMatricule;
  final String driverName;
  final String driverPhone;
  final String route;
  final String sessionCloseTime;
  final List<_CollectorAssignmentCollector> collectors;
  final String status;

  const _CollectorAssignmentRecord({
    required this.date,
    required this.time,
    required this.busMatricule,
    required this.driverName,
    required this.driverPhone,
    required this.route,
    required this.sessionCloseTime,
    required this.collectors,
    required this.status,
  });
}

class _CollectorAssignmentsPage extends StatefulWidget {
  const _CollectorAssignmentsPage();

  @override
  State<_CollectorAssignmentsPage> createState() =>
      _CollectorAssignmentsPageState();
}

class _CollectorAssignmentsPageState extends State<_CollectorAssignmentsPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  _CollectorAssignmentFilter _filter = _CollectorAssignmentFilter.current;
  _CollectorAssignmentPastStatusFilter _pastStatusFilter =
      _CollectorAssignmentPastStatusFilter.all;

  // Jeu de données local en attendant la connexion à l'API des affectations.
  final List<_CollectorAssignmentRecord> _currentAssignments = const [
    _CollectorAssignmentRecord(
      date: '29 mai 2026',
      time: '08:30',
      busMatricule: 'BJ-6248-RB',
      driverName: 'Karim Soglo',
      driverPhone: '+229 01 66 42 18 09',
      route: 'Cotonou -> Parakou',
      sessionCloseTime: '18:45',
      collectors: [
        _CollectorAssignmentCollector(
          name: 'Awa Mensah',
          phone: '+229 01 64 20 11 90',
        ),
        _CollectorAssignmentCollector(
          name: 'Joel Kpadonou',
          phone: '+229 01 97 44 08 26',
        ),
      ],
      status: 'Session ouverte',
    ),
  ];

  final List<_CollectorAssignmentRecord> _scheduledAssignments = const [
    _CollectorAssignmentRecord(
      date: '31 mai 2026',
      time: '06:00',
      busMatricule: 'BJ-7812-AG',
      driverName: 'Moussa Adjou',
      driverPhone: '+229 01 97 12 44 30',
      route: 'Porto-Novo -> Natitingou',
      sessionCloseTime: '17:30',
      collectors: [
        _CollectorAssignmentCollector(
          name: 'Chancelle Toko',
          phone: '+229 01 62 19 31 45',
        ),
        _CollectorAssignmentCollector(
          name: 'Eric Houngbo',
          phone: '+229 01 69 88 14 77',
        ),
      ],
      status: 'Programmé',
    ),
    _CollectorAssignmentRecord(
      date: '02 juin 2026',
      time: '14:15',
      busMatricule: 'BJ-4589-CD',
      driverName: 'Jean Dossou',
      driverPhone: '+229 01 62 55 70 21',
      route: 'Cotonou -> Djougou',
      sessionCloseTime: '23:00',
      collectors: [
        _CollectorAssignmentCollector(
          name: 'Mariette Hounkanrin',
          phone: '+229 01 60 75 29 10',
        ),
        _CollectorAssignmentCollector(
          name: 'Serge Loko',
          phone: '+229 01 66 13 57 84',
        ),
      ],
      status: 'Programmé',
    ),
  ];

  final List<_CollectorAssignmentRecord> _pastAssignments = const [
    _CollectorAssignmentRecord(
      date: '27 mai 2026',
      time: '07:45',
      busMatricule: 'BJ-3220-TR',
      driverName: 'Rachid Bio',
      driverPhone: '+229 01 61 18 40 33',
      route: 'Cotonou -> Bohicon',
      sessionCloseTime: '16:20',
      collectors: [
        _CollectorAssignmentCollector(
          name: 'Mireille Zinsou',
          phone: '+229 01 65 42 71 88',
        ),
        _CollectorAssignmentCollector(
          name: 'Patrick Tossa',
          phone: '+229 01 91 06 24 35',
        ),
      ],
      status: 'Effectué',
    ),
    _CollectorAssignmentRecord(
      date: '25 mai 2026',
      time: '09:00',
      busMatricule: 'BJ-9301-PL',
      driverName: 'Armand Hounsinou',
      driverPhone: '+229 01 95 72 10 67',
      route: 'Porto-Novo -> Kandi',
      sessionCloseTime: '20:10',
      collectors: [
        _CollectorAssignmentCollector(
          name: 'Nadine Sossa',
          phone: '+229 01 68 77 31 04',
        ),
        _CollectorAssignmentCollector(
          name: 'Abel Gandonou',
          phone: '+229 01 94 50 63 19',
        ),
      ],
      status: 'Réaffecter',
    ),
    _CollectorAssignmentRecord(
      date: '22 mai 2026',
      time: '12:30',
      busMatricule: 'BJ-1077-MK',
      driverName: 'Saturnin Kiki',
      driverPhone: '+229 01 60 30 41 82',
      route: 'Cotonou -> Lokossa',
      sessionCloseTime: '19:00',
      collectors: [
        _CollectorAssignmentCollector(
          name: 'Judith Ahouanvoebla',
          phone: '+229 01 61 33 42 50',
        ),
        _CollectorAssignmentCollector(
          name: 'David Nonvignon',
          phone: '+229 01 96 82 18 73',
        ),
      ],
      status: 'Absent',
    ),
  ];

  List<_CollectorAssignmentRecord> get _records {
    switch (_filter) {
      case _CollectorAssignmentFilter.current:
        return _currentAssignments;
      case _CollectorAssignmentFilter.scheduled:
        return _scheduledAssignments;
      case _CollectorAssignmentFilter.past:
        return _pastAssignments
            .where((assignment) => _pastStatusFilter.matches(assignment.status))
            .toList();
    }
  }

  String get _title {
    switch (_filter) {
      case _CollectorAssignmentFilter.current:
        return 'Affectation en cours';
      case _CollectorAssignmentFilter.scheduled:
        return 'Affectations programmées';
      case _CollectorAssignmentFilter.past:
        return 'Affectations passées';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Absent':
        return const Color(0xFFE11D48);
      case 'Réaffecter':
        return const Color(0xFFF97316);
      case 'Effectué':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF0B4F2A);
    }
  }

  void _selectFilter(_CollectorAssignmentFilter value) {
    setState(() {
      _filter = value;
      if (_filter != _CollectorAssignmentFilter.past) {
        _pastStatusFilter = _CollectorAssignmentPastStatusFilter.all;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_deepBlue, Color(0xFF0E6B39), _fofanaGreen],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CollectorHeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/logo_fofana_black.png',
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mes affectations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suivez vos sessions, vos bus et votre équipe de trajet.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 14.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                children: [
                  _CollectorAssignmentSegmentedControl(
                    selected: _filter,
                    onChanged: _selectFilter,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _title,
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_records.isEmpty
                      ? [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Aucune affectation',
                                style: TextStyle(
                                  color: _deepBlue.withValues(alpha: 0.6),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : _records.map((item) {
                          if (_filter == _CollectorAssignmentFilter.current) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _deepBlue.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _deepBlue.withValues(alpha: 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.busMatricule,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      _CollectorParcelStatusPill(
                                        label: item.status,
                                        strong: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _CollectorAssignmentRoutePanel(
                                    route: item.route,
                                  ),
                                  const SizedBox(height: 12),
                                  _CollectorAssignmentInfoGrid(
                                    children: [
                                      _CollectorAssignmentInfo(
                                        icon: Icons.person_rounded,
                                        label: 'Chauffeur',
                                        value: item.driverName,
                                      ),
                                      _CollectorAssignmentInfo(
                                        icon: Icons.phone_rounded,
                                        label: 'Téléphone chauffeur',
                                        value: item.driverPhone,
                                      ),
                                      _CollectorAssignmentInfo(
                                        icon: Icons.lock_clock_rounded,
                                        label: 'Fin session',
                                        value: item.sessionCloseTime,
                                      ),
                                      _CollectorAssignmentInfo(
                                        icon: Icons.event_rounded,
                                        label: 'Date/Heure',
                                        value: '${item.date}\n${item.time}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Collecteurs affectés :',
                                    style: TextStyle(
                                      color: const Color(0xFF0B4F2A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: item.collectors.map((collector) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Text(
                                          '${collector.name} • ${collector.phone}',
                                          style: const TextStyle(
                                            color: Color(0xFF4B5563),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _deepBlue.withValues(alpha: 0.08),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE53935,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.directions_bus_filled_rounded,
                                  color: Color(0xFFE53935),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                item.busMatricule,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                '${item.route} • ${item.date} • ${item.time}',
                                style: TextStyle(
                                  color: _deepBlue.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    item.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: _statusColor(item.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _CollectorAssignmentDetailPage(
                                        assignment: item,
                                        mode: _filter,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList()),
                  if (_filter == _CollectorAssignmentFilter.past) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _CollectorAssignmentPastStatusFilter.values
                          .map(
                            (status) => ChoiceChip(
                              label: Text(status.label),
                              selected: _pastStatusFilter == status,
                              onSelected: (_) =>
                                  setState(() => _pastStatusFilter = status),
                              selectedColor: _fofanaGreen,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _pastStatusFilter == status
                                    ? Colors.white
                                    : _deepBlue,
                                fontWeight: FontWeight.w800,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorAssignmentSegmentedControl extends StatelessWidget {
  final _CollectorAssignmentFilter selected;
  final ValueChanged<_CollectorAssignmentFilter> onChanged;

  const _CollectorAssignmentSegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _CollectorAssignmentTabButton(
            label: 'En cours',
            icon: Icons.play_circle_fill_rounded,
            selected: selected == _CollectorAssignmentFilter.current,
            onTap: () => onChanged(_CollectorAssignmentFilter.current),
          ),
          _CollectorAssignmentTabButton(
            label: 'Programmer',
            icon: Icons.event_available_rounded,
            selected: selected == _CollectorAssignmentFilter.scheduled,
            onTap: () => onChanged(_CollectorAssignmentFilter.scheduled),
          ),
          _CollectorAssignmentTabButton(
            label: 'Passer',
            icon: Icons.history_rounded,
            selected: selected == _CollectorAssignmentFilter.past,
            onTap: () => onChanged(_CollectorAssignmentFilter.past),
          ),
        ],
      ),
    );
  }
}

class _CollectorAssignmentTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CollectorAssignmentTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF16A34A) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : const Color(0xFF0B4F2A),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF0B4F2A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectorAssignmentDetailPage extends StatelessWidget {
  final _CollectorAssignmentRecord assignment;
  final _CollectorAssignmentFilter mode;

  const _CollectorAssignmentDetailPage({
    required this.assignment,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Détails de l\'affectation'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: deepBlue.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignment.busMatricule,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${assignment.date} · ${assignment.time}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _detailStatusColor(
                            assignment.status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          assignment.status,
                          style: TextStyle(
                            color: _detailStatusColor(assignment.status),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _CollectorAssignmentRoutePanel(route: assignment.route),
                  const SizedBox(height: 18),
                  _CollectorAssignmentInfoGrid(
                    children: [
                      _CollectorAssignmentInfo(
                        icon: Icons.person_rounded,
                        label: 'Chauffeur',
                        value: assignment.driverName,
                      ),
                      _CollectorAssignmentInfo(
                        icon: Icons.phone_rounded,
                        label: 'Téléphone chauffeur',
                        value: assignment.driverPhone,
                      ),
                      _CollectorAssignmentInfo(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Matricule bus',
                        value: assignment.busMatricule,
                      ),
                      _CollectorAssignmentInfo(
                        icon: Icons.lock_clock_rounded,
                        label: 'Fermeture session',
                        value: assignment.sessionCloseTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Collecteurs affectés',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...assignment.collectors.map(
                    (collector) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: green.withValues(alpha: 0.12),
                        child: const Icon(Icons.person, color: green),
                      ),
                      title: Text(
                        collector.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(collector.phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone_rounded),
                        color: deepBlue,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                _CollectorPhoneSheet(collector: collector),
                          );
                        },
                      ),
                    ),
                  ),
                  if (mode == _CollectorAssignmentFilter.current) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Retour'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deepBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _detailStatusColor(String status) {
    switch (status) {
      case 'Absent':
        return const Color(0xFFE11D48);
      case 'Réaffecter':
        return const Color(0xFFF97316);
      case 'Effectué':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF0B4F2A);
    }
  }
}

class _CollectorAssignmentRoutePanel extends StatefulWidget {
  final String route;

  const _CollectorAssignmentRoutePanel({required this.route});

  @override
  State<_CollectorAssignmentRoutePanel> createState() =>
      _CollectorAssignmentRoutePanelState();
}

class _CollectorAssignmentRoutePanelState
    extends State<_CollectorAssignmentRoutePanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: green.withValues(alpha: 0.24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.route_rounded, color: green, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trajet',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.route,
                    maxLines: _expanded ? 4 : 1,
                    overflow: _expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: deepBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorAssignmentInfoGrid extends StatelessWidget {
  final List<_CollectorAssignmentInfo> children;

  const _CollectorAssignmentInfoGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _CollectorAssignmentInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CollectorAssignmentInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16A34A), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13.5,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorPhoneSheet extends StatelessWidget {
  final _CollectorAssignmentCollector collector;

  const _CollectorPhoneSheet({required this.collector});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
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
                  color: deepBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.badge_rounded, color: green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collector.name,
                        style: const TextStyle(
                          color: deepBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Numéro du percepteur',
                        style: TextStyle(
                          color: Color(0xFF607169),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7EF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: green.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_rounded, color: green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      collector.phone,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Compris'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorConnectionPage extends StatefulWidget {
  const _CollectorConnectionPage();

  @override
  State<_CollectorConnectionPage> createState() =>
      _CollectorConnectionPageState();
}

class _CollectorConnectionPageState extends State<_CollectorConnectionPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);
  static const int _initialSessionSeconds = 2 * 60 * 60;
  static const int _initialResendSeconds = 120;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  Timer? _sessionTimer;
  Timer? _resendTimer;
  int _sessionRemaining = _initialSessionSeconds;
  int _resendRemaining = _initialResendSeconds;
  bool _isSessionActive = true;
  bool _showOtpRequest = false;

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _resendTimer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // Chrono principal de la session percepteur : quand il atteint zéro,
  // l'interface bascule automatiquement l'état de session en "Fermée".
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isSessionActive) return;
      if (_sessionRemaining <= 1) {
        setState(() {
          _sessionRemaining = 0;
          _isSessionActive = false;
        });
        _sessionTimer?.cancel();
        return;
      }
      setState(() => _sessionRemaining--);
    });
  }

  // Chrono affiché après une demande d'ouverture : il indique au percepteur
  // quand il pourra demander ou recevoir un nouveau code OTP.
  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendRemaining = _initialResendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_resendRemaining <= 1) {
        setState(() => _resendRemaining = 0);
        _resendTimer?.cancel();
        return;
      }
      setState(() => _resendRemaining--);
    });
  }

  // La demande révèle les six champs OTP et démarre le compte à rebours de
  // renvoi sans activer immédiatement la session.
  void _requestSessionOpening() {
    setState(() => _showOtpRequest = true);
    _startResendTimer();
    _CollectorNotificationStore.add(
      title: 'Ouverture session',
      message: "Demande d'ouverture de session envoyée.",
    );
  }

  // L'activation exige les six chiffres, puis relance une session complète.
  void _activate() {
    final code = _otpControllers.map((item) => item.text.trim()).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir les 6 chiffres du code.'),
        ),
      );
      return;
    }

    setState(() {
      _isSessionActive = true;
      _sessionRemaining = _initialSessionSeconds;
    });
    _startSessionTimer();
    _CollectorNotificationStore.add(
      title: 'Session activée',
      message: 'Votre session percepteur est active.',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session activée avec succès.'),
        backgroundColor: _deepBlue,
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
                    child: _CollectorHeaderIconButton(
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
              'Connexion voyage',
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
                    _CollectorSessionCard(
                      isActive: _isSessionActive,
                      remainingLabel: _formatDuration(_sessionRemaining),
                    ),
                    const SizedBox(height: 18),
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
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _requestSessionOpening,
                              icon: const Icon(Icons.lock_open_rounded),
                              label: const Text(
                                "Demande ouverture de session",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _deepBlue,
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
                          if (_showOtpRequest) ...[
                            const SizedBox(height: 20),
                            const Text(
                              "Code d'activation",
                              style: TextStyle(
                                color: _deepBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: List.generate(
                                _otpControllers.length,
                                (index) => [
                                  if (index == 3)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                          color: _deepBlue,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            index == _otpControllers.length - 1
                                            ? 0
                                            : 6,
                                      ),
                                      child: _CollectorOtpBox(
                                        controller: _otpControllers[index],
                                      ),
                                    ),
                                  ),
                                ],
                              ).expand((items) => items).toList(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Renvoyez le code dans $_resendRemaining s',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF5F6B86),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _activate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _fofanaGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Activer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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

class _CollectorSessionCard extends StatelessWidget {
  final bool isActive;
  final String remainingLabel;

  const _CollectorSessionCard({
    required this.isActive,
    required this.remainingLabel,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    final statusColor = isActive ? red : deepBlue;
    final statusLabel = isActive ? 'Active' : 'Fermée';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
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
                child: Icon(Icons.account_circle_rounded, color: statusColor),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Ma session',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Fermeture dans',
            style: TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            remainingLabel,
            style: TextStyle(
              color: isActive ? deepBlue : red,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorOtpBox extends StatelessWidget {
  final TextEditingController controller;

  const _CollectorOtpBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      maxLength: 1,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        color: Color(0xFF0B4F2A),
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
      ),
    );
  }
}

class _TicketValidationPage extends StatefulWidget {
  const _TicketValidationPage();

  @override
  State<_TicketValidationPage> createState() => _TicketValidationPageState();
}

class _TicketValidationPageState extends State<_TicketValidationPage> {
  String? _scannedCode;
  bool _ticketVisible = false;

  void _showTicket() {
    setState(() {
      _scannedCode ??= 'TK-2026-0487';
      _ticketVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Validation ticket',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        onDetect: (capture) {
                          if (capture.barcodes.isEmpty) return;
                          final value = capture.barcodes.first.rawValue;
                          if (value == null || value.trim().isEmpty) return;
                          setState(() => _scannedCode = value.trim());
                        },
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.18)),
                      Center(
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _scannedCode == null
                                ? 'Placez le QR code du ticket dans le cadre'
                                : 'Code détecté : $_scannedCode',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _showTicket,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (_ticketVisible) ...[
                const SizedBox(height: 16),
                _TicketInfoCard(code: _scannedCode ?? 'TK-2026-0487'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketInfoCard extends StatelessWidget {
  final String code;

  const _TicketInfoCard({required this.code});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.08),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: red,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Infos du ticket',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TicketInfoRow(title: 'Code ticket', value: code),
          const _TicketInfoRow(title: 'Passager', value: 'Client Fofana'),
          const _TicketInfoRow(title: 'Trajet', value: 'Cotonou -> Parakou'),
          const _TicketInfoRow(title: 'Départ', value: '21/05/2026 à 08:30'),
          const _TicketInfoRow(title: 'Siège', value: '12A'),
          const _TicketInfoRow(title: 'Statut', value: 'Ticket valide'),
        ],
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _TicketInfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0B4F2A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> _collectorBeninCities = [
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
  'Cotonou',
  'Dassa-Zoumè',
  'Djougou',
  'Kandi',
  'Lokossa',
  'Natitingou',
  'Ouidah',
  'Parakou',
  'Porto-Novo',
  'Sakété',
  'Savalou',
  'Sèmè-Kpodji',
  'Tchaourou',
];

class _CollectorCityPosition {
  final double latitude;
  final double longitude;

  const _CollectorCityPosition(this.latitude, this.longitude);
}

const Map<String, _CollectorCityPosition> _collectorCityPositions = {
  'Abomey': _CollectorCityPosition(7.1829, 1.9912),
  'Abomey-Calavi': _CollectorCityPosition(6.4485, 2.3557),
  'Adjohoun': _CollectorCityPosition(6.7167, 2.4833),
  'Allada': _CollectorCityPosition(6.6655, 2.1514),
  'Aplahoué': _CollectorCityPosition(6.9333, 1.6833),
  'Banikoara': _CollectorCityPosition(11.2985, 2.4386),
  'Bassila': _CollectorCityPosition(9.0081, 1.6654),
  'Bembèrèkè': _CollectorCityPosition(10.2283, 2.6633),
  'Bétérou': _CollectorCityPosition(9.1992, 2.2586),
  'Bohicon': _CollectorCityPosition(7.1783, 2.0667),
  'Cotonou': _CollectorCityPosition(6.3703, 2.3912),
  'Dassa-Zoumè': _CollectorCityPosition(7.75, 2.1833),
  'Djougou': _CollectorCityPosition(9.7085, 1.6659),
  'Kandi': _CollectorCityPosition(11.1342, 2.9386),
  'Lokossa': _CollectorCityPosition(6.6387, 1.7167),
  'Natitingou': _CollectorCityPosition(10.3042, 1.3796),
  'Ouidah': _CollectorCityPosition(6.3631, 2.0851),
  'Parakou': _CollectorCityPosition(9.3372, 2.6303),
  'Porto-Novo': _CollectorCityPosition(6.4969, 2.6289),
  'Sakété': _CollectorCityPosition(6.7362, 2.6587),
  'Savalou': _CollectorCityPosition(7.9281, 1.9756),
  'Sèmè-Kpodji': _CollectorCityPosition(6.3654, 2.6161),
  'Tchaourou': _CollectorCityPosition(8.8865, 2.5975),
};

class _CollectorReservationRecord {
  final String reference;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String passengerName;
  final String phone;
  final String price;
  final String status;

  const _CollectorReservationRecord({
    required this.reference,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.passengerName,
    required this.phone,
    required this.price,
    required this.status,
  });

  _CollectorReservationRecord copyWith({String? status}) {
    return _CollectorReservationRecord(
      reference: reference,
      departure: departure,
      destination: destination,
      date: date,
      time: time,
      passengerCount: passengerCount,
      passengerName: passengerName,
      phone: phone,
      price: price,
      status: status ?? this.status,
    );
  }
}

class _CollectorReservationStore {
  static final List<_CollectorReservationRecord> reservations = [];

  static void add(_CollectorReservationRecord reservation) {
    reservations.insert(0, reservation);
  }
}

class _CollectorReservationPage extends StatefulWidget {
  const _CollectorReservationPage();

  @override
  State<_CollectorReservationPage> createState() =>
      _CollectorReservationPageState();
}

class _CollectorReservationPageState extends State<_CollectorReservationPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _departController = TextEditingController(
    text: 'Cotonou',
  );
  final TextEditingController _destinationController = TextEditingController(
    text: 'Porto-Novo',
  );
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _passengerCount = 1;
  DateTime? _travelDate;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _syncFareAmount();
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int get _fare {
    final distance = _routeDistanceKm(
      _departController.text.trim(),
      _destinationController.text.trim(),
    );
    final base = 900;
    final perPassenger = (base + distance * 95).round();
    final roundedFare = ((perPassenger / 100).ceil() * 100)
        .clamp(1200, 65000)
        .toInt();
    return roundedFare * _passengerCount;
  }

  void _syncFareAmount() {
    _amountController.text = _formatAmount(_fare);
  }

  int _currentAmount() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? _fare;
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

  double _routeDistanceKm(String departure, String destination) {
    final from = _positionFor(departure);
    final to = _positionFor(destination);
    if (from == null || to == null) {
      final seed = departure.length * 17 + destination.length * 31;
      return 35 + (seed % 420).toDouble();
    }

    return _distanceKm(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  _CollectorCityPosition? _positionFor(String city) {
    if (city.startsWith('Ma position') && _currentPosition != null) {
      return _CollectorCityPosition(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
    return _collectorCityPositions[city];
  }

  double _distanceKm(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(latitudeB - latitudeA);
    final dLon = _degreesToRadians(longitudeB - longitudeA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(latitudeA)) *
            math.cos(_degreesToRadians(latitudeB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  Future<void> _useCurrentLocation(TextEditingController controller) async {
    Navigator.pop(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activez la localisation pour utiliser Ma position.'),
            backgroundColor: _fofanaGreen,
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission de localisation refusée.'),
            backgroundColor: _fofanaGreen,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        controller.text =
            'Ma position (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})';
        _syncFareAmount();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer la position actuelle.'),
          backgroundColor: _fofanaGreen,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
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

    if (date == null) return;
    setState(() {
      _travelDate = date;
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
    });
  }

  void _showCityPicker({
    required String title,
    required TextEditingController controller,
    bool includeCurrentLocation = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    itemCount:
                        _collectorBeninCities.length +
                        (includeCurrentLocation ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (includeCurrentLocation && index == 0) {
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            leading: const Icon(
                              Icons.my_location_rounded,
                              color: _fofanaGreen,
                            ),
                            title: const Text(
                              'Ma position',
                              style: TextStyle(
                                color: _deepBlue,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            onTap: () => _useCurrentLocation(controller),
                          ),
                        );
                      }

                      final cityIndex = includeCurrentLocation
                          ? index - 1
                          : index;
                      final city = _collectorBeninCities[cityIndex];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: _fofanaGreen,
                          ),
                          title: Text(
                            city,
                            style: const TextStyle(
                              color: _deepBlue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              controller.text = city;
                              _syncFareAmount();
                            });
                            Navigator.pop(context);
                          },
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

  void _switchLocations() {
    final first = _departController.text;
    setState(() {
      _departController.text = _destinationController.text;
      _destinationController.text = first;
      _syncFareAmount();
    });
  }

  Future<void> _confirmReservation() async {
    if (_departController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _travelDate == null) {
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
        builder: (_) => _CollectorPaymentDetailsPage(
          departure: _departController.text.trim(),
          destination: _destinationController.text.trim(),
          date:
              '${_travelDate!.day.toString().padLeft(2, '0')} ${_monthName(_travelDate!.month)} ${_travelDate!.year}',
          priceAmount: _currentAmount(),
          passengers: _passengerCount,
          time: '10:00',
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  String _monthName(int month) {
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
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/coli1.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0x99060E27),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.vertical(
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
                        child: _CollectorHeaderIconButton(
                          icon: Icons.arrow_back_rounded,
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
                  Container(
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
                      'Réservation percepteur',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReservationForm(),
                    const SizedBox(height: 18),
                    if (_CollectorReservationStore.reservations.isNotEmpty)
                      ..._CollectorReservationStore.reservations.map(
                        (item) => _CollectorReservationCard(item: item),
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
                    _CollectorCityField(
                      controller: _departController,
                      label: 'De',
                      hint: 'Ville de départ',
                      isFirst: true,
                      onTap: () => _showCityPicker(
                        title: 'Choisir la ville de départ',
                        controller: _departController,
                        includeCurrentLocation: true,
                      ),
                    ),
                    _CollectorCityField(
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
          _CollectorSmallField(
            label: 'Date de départ',
            value: _dateController.text.isEmpty
                ? 'Sélectionner une date'
                : _dateController.text,
            icon: Icons.calendar_month_rounded,
            onTap: _pickDate,
          ),
          const SizedBox(height: 14),
          if (_destinationController.text.isNotEmpty) ...[
            _CollectorTextInput(
              controller: _amountController,
              label: 'Montant',
              icon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
              suffixText: 'CFA',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 14),
          ],
          _CollectorPassengerCard(
            count: _passengerCount,
            onMinus: () {
              if (_passengerCount > 1) {
                setState(() {
                  _passengerCount -= 1;
                  _syncFareAmount();
                });
              }
            },
            onPlus: () {
              if (_passengerCount < 8) {
                setState(() {
                  _passengerCount += 1;
                  _syncFareAmount();
                });
              }
            },
          ),
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
}

class _CollectorCityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isFirst;
  final VoidCallback onTap;

  const _CollectorCityField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 68, 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: isFirst
                ? BorderSide(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF16A34A),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
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
    );
  }
}

class _CollectorSmallField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorSmallField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(icon, size: 18, color: deepBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 14.5,
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
}

class _CollectorPassengerCard extends StatelessWidget {
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _CollectorPassengerCard({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: deepBlue, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          _CollectorStepperButton(icon: Icons.remove, onTap: onMinus),
          const SizedBox(width: 10),
          Text(
            '$count',
            style: const TextStyle(
              color: deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          _CollectorStepperButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _CollectorStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorStepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.18),
          ),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF0B4F2A)),
      ),
    );
  }
}

class _CollectorPaymentDetailsPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final int priceAmount;
  final int passengers;
  final String time;

  const _CollectorPaymentDetailsPage({
    required this.departure,
    required this.destination,
    required this.date,
    required this.priceAmount,
    required this.passengers,
    this.time = '10:00',
  });

  @override
  State<_CollectorPaymentDetailsPage> createState() =>
      _CollectorPaymentDetailsPageState();
}

class _CollectorPaymentDetailsPageState
    extends State<_CollectorPaymentDetailsPage> {
  final TextEditingController _requesterPhoneController =
      TextEditingController();
  final TextEditingController _passengerNameController =
      TextEditingController();

  @override
  void dispose() {
    _requesterPhoneController.dispose();
    _passengerNameController.dispose();
    super.dispose();
  }

  void _finishReservation() {
    final phone = _requesterPhoneController.text.trim();
    final passenger = _passengerNameController.text.trim();

    if (phone.isEmpty || passenger.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter les informations.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CollectorPaymentChoicePage(
          reservation: _buildReservation(
            passengerName: passenger,
            phone: phone,
            status: 'En attente paiement',
          ),
          priceAmount: widget.priceAmount,
        ),
      ),
    );
  }

  _CollectorReservationRecord _buildReservation({
    required String passengerName,
    required String phone,
    required String status,
  }) {
    return _CollectorReservationRecord(
      reference: 'TB${DateTime.now().millisecondsSinceEpoch}',
      departure: widget.departure,
      destination: widget.destination,
      date: widget.date,
      time: widget.time,
      passengerCount: widget.passengers,
      passengerName: passengerName,
      phone: phone,
      price: '${_formatAmount(widget.priceAmount)} CFA',
      status: status,
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
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Confirmation',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectorTripSummaryCard(
                departure: widget.departure,
                destination: widget.destination,
                date: widget.date,
                time: widget.time,
                passengerCount: widget.passengers,
                price: '${_formatAmount(widget.priceAmount)} CFA',
              ),
              const SizedBox(height: 16),
              _CollectorTextInput(
                controller: _passengerNameController,
                label: 'Nom du passager',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              _CollectorTextInput(
                controller: _requesterPhoneController,
                label: 'Téléphone du demandeur',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _finishReservation,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Confirmer la réservation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
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

class _CollectorPaymentChoicePage extends StatefulWidget {
  final _CollectorReservationRecord reservation;
  final int priceAmount;

  const _CollectorPaymentChoicePage({
    required this.reservation,
    required this.priceAmount,
  });

  @override
  State<_CollectorPaymentChoicePage> createState() =>
      _CollectorPaymentChoicePageState();
}

class _CollectorPaymentChoicePageState
    extends State<_CollectorPaymentChoicePage> {
  String _mode = 'cash';
  String? _method;
  final TextEditingController _clientCodeController = TextEditingController();
  bool _paymentRequestSent = false;

  static const Color _deepBlue = Color(0xFF0B4F2A);

  @override
  void dispose() {
    _clientCodeController.dispose();
    super.dispose();
  }

  void _confirmCash() {
    _completeReservation('Confirmée - Cash');
  }

  void _sendPaymentRequest() {
    if (_method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une méthode de paiement.')),
      );
      return;
    }

    setState(() => _paymentRequestSent = true);
    _CollectorNotificationStore.add(
      title: 'Demande de paiement',
      message:
          'Demande envoyée au ${widget.reservation.phone} via ${_methodLabel(_method!)}.',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demande envoyée au ${widget.reservation.phone}. Le client peut saisir son code.',
        ),
        backgroundColor: _deepBlue,
      ),
    );
  }

  void _confirmRemotePayment() {
    if (!_paymentRequestSent || _clientCodeController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez envoyer la demande puis saisir le code client.',
          ),
        ),
      );
      return;
    }

    _completeReservation('Confirmée - ${_methodLabel(_method!)}');
  }

  void _completeReservation(String status) {
    final reservation = widget.reservation.copyWith(status: status);
    _CollectorReservationStore.add(reservation);
    _CollectorNotificationStore.add(
      title: 'Réservation confirmée',
      message:
          '${reservation.passengerName} - ${reservation.departure} vers ${reservation.destination}.',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _CollectorGeneratedTicketPage(reservation: reservation),
      ),
    );
  }

  String _methodLabel(String value) {
    switch (value) {
      case 'moov':
        return 'Moov';
      case 'celtiis':
        return 'Celtiis';
      case 'mtn':
        return 'MTN';
      case 'wave':
        return 'Wave';
      case 'card':
        return 'Carte bancaire';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectorTripSummaryCard(
                departure: widget.reservation.departure,
                destination: widget.reservation.destination,
                date: widget.reservation.date,
                time: widget.reservation.time,
                passengerCount: widget.reservation.passengerCount,
                price: widget.reservation.price,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Mode de règlement',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _CollectorModeButton(
                            label: 'Cash',
                            icon: Icons.payments_rounded,
                            selected: _mode == 'cash',
                            onTap: () => setState(() => _mode = 'cash'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CollectorModeButton(
                            label: 'Autre paiement',
                            icon: Icons.phone_android_rounded,
                            selected: _mode == 'remote',
                            onTap: () => setState(() => _mode = 'remote'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_mode == 'cash')
                      _CollectorCashPaymentPanel(onConfirm: _confirmCash)
                    else
                      _CollectorRemotePaymentPanel(
                        selectedMethod: _method,
                        requestSent: _paymentRequestSent,
                        clientCodeController: _clientCodeController,
                        onMethodTap: (method) => setState(() {
                          _method = method;
                          _paymentRequestSent = false;
                          _clientCodeController.clear();
                        }),
                        onSendRequest: _sendPaymentRequest,
                        onConfirmPayment: _confirmRemotePayment,
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

class _CollectorModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CollectorModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16A34A) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF16A34A)
                : const Color(0xFF0B4F2A).withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF0B4F2A),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF0B4F2A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorCashPaymentPanel extends StatelessWidget {
  final VoidCallback onConfirm;

  const _CollectorCashPaymentPanel({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            "Le percepteur reçoit directement l'argent du client puis confirme la réservation.",
            style: TextStyle(
              color: Color(0xFF5F6B86),
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Confirmer le paiement cash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
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
    );
  }
}

class _CollectorRemotePaymentPanel extends StatelessWidget {
  final String? selectedMethod;
  final bool requestSent;
  final TextEditingController clientCodeController;
  final ValueChanged<String> onMethodTap;
  final VoidCallback onSendRequest;
  final VoidCallback onConfirmPayment;

  const _CollectorRemotePaymentPanel({
    required this.selectedMethod,
    required this.requestSent,
    required this.clientCodeController,
    required this.onMethodTap,
    required this.onSendRequest,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    const methods = [
      ('moov', 'Moov', 'assets/images/logo_moov.png'),
      ('celtiis', 'Celtiis', 'assets/images/logo_celtiis.png'),
      ('mtn', 'MTN', 'assets/images/logo_mtn.png'),
      ('wave', 'Wave', null),
      ('card', 'Carte bancaire', 'assets/images/logo_carte.png'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.3,
          children: methods.map((method) {
            return _CollectorPaymentMethodTile(
              value: method.$1,
              label: method.$2,
              imagePath: method.$3,
              selected: selectedMethod == method.$1,
              onTap: () => onMethodTap(method.$1),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onSendRequest,
            icon: const Icon(Icons.send_to_mobile_rounded),
            label: const Text('Envoyer la demande au client'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B4F2A),
              side: BorderSide(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        if (requestSent) ...[
          const SizedBox(height: 14),
          TextField(
            controller: clientCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              counterText: '',
              labelText: 'Code reçu par le client',
              prefixIcon: const Icon(
                Icons.password_rounded,
                color: Color(0xFF16A34A),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FBFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onConfirmPayment,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Valider le paiement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
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
      ],
    );
  }
}

class _CollectorPaymentMethodTile extends StatelessWidget {
  final String value;
  final String label;
  final String? imagePath;
  final bool selected;
  final VoidCallback onTap;

  const _CollectorPaymentMethodTile({
    required this.value,
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7EF) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF16A34A)
                : const Color(0xFF0B4F2A).withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _methodIcon(),
              )
            else
              _methodIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodIcon() {
    final icon = value == 'wave'
        ? Icons.waves_rounded
        : Icons.credit_card_rounded;

    return Icon(icon, color: const Color(0xFF16A34A), size: 28);
  }
}

class _CollectorTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;

  const _CollectorTextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.suffixText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: Color(0xFF0B4F2A),
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        prefixIcon: Icon(icon, color: const Color(0xFF16A34A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CollectorTripSummaryCard extends StatelessWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String price;

  const _CollectorTripSummaryCard({
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            'Résumé du voyage',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _TicketInfoRow(title: 'Trajet', value: '$departure -> $destination'),
          _TicketInfoRow(title: 'Départ', value: '$date à $time'),
          _TicketInfoRow(title: 'Passagers', value: '$passengerCount'),
          _TicketInfoRow(title: 'Total', value: price),
        ],
      ),
    );
  }
}

class _CollectorGeneratedTicketPage extends StatelessWidget {
  final _CollectorReservationRecord reservation;

  const _CollectorGeneratedTicketPage({required this.reservation});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await _buildTicketPdf();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'ticket_fofana_${reservation.reference}.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de générer le PDF du ticket.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<Uint8List> _buildTicketPdf() async {
    final pdf = pw.Document();
    final deepBlue = PdfColor.fromHex('#0B4F2A');
    final red = PdfColor.fromHex('#16A34A');
    final light = PdfColor.fromHex('#F8FBFF');
    final muted = PdfColor.fromHex('#687089');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#E6EAF2')),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Fofana',
                      style: pw.TextStyle(
                        color: deepBlue,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: light,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        reservation.status,
                        style: pw.TextStyle(
                          color: red,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 28),
                _pdfRow('Passager', reservation.passengerName, deepBlue, muted),
                _pdfRow('Telephone', reservation.phone, deepBlue, muted),
                _pdfRow(
                  'Trajet',
                  '${reservation.departure} -> ${reservation.destination}',
                  deepBlue,
                  muted,
                ),
                _pdfRow(
                  'Depart',
                  '${reservation.date} a ${reservation.time}',
                  deepBlue,
                  muted,
                ),
                _pdfRow(
                  'Passagers',
                  '${reservation.passengerCount}',
                  deepBlue,
                  muted,
                ),
                _pdfRow('Montant', reservation.price, deepBlue, muted),
                pw.Spacer(),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        reservation.reference,
                        style: pw.TextStyle(
                          color: deepBlue,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: reservation.reference,
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(
    String title,
    String value,
    PdfColor deepBlue,
    PdfColor muted,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: deepBlue,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Billet généré',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CollectorReservationCard(item: reservation),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Code QR du billet',
                      style: TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    QrImageView(
                      data: reservation.reference,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reservation.reference,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Télécharger en PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Retour à la réservation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B4F2A),
                    side: BorderSide(
                      color: const Color(0xFF0B4F2A).withValues(alpha: 0.24),
                    ),
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
      ),
    );
  }
}

class _CollectorReservationCard extends StatelessWidget {
  final _CollectorReservationRecord item;

  const _CollectorReservationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.reference,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                item.status,
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TicketInfoRow(
            title: 'Trajet',
            value: '${item.departure} -> ${item.destination}',
          ),
          _TicketInfoRow(title: 'Départ', value: '${item.date} à ${item.time}'),
          _TicketInfoRow(title: 'Passager', value: item.passengerName),
          _TicketInfoRow(title: 'Téléphone', value: item.phone),
          _TicketInfoRow(title: 'Total', value: item.price),
        ],
      ),
    );
  }
}

class _CollectorAttendanceList extends StatelessWidget {
  final String title;
  final String emptyMessage;

  const _CollectorAttendanceList({
    required this.title,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [_CollectorEmptyCard(title: title, message: emptyMessage)],
    );
  }
}

class _CollectorEmptyCard extends StatelessWidget {
  final String title;
  final String message;

  const _CollectorEmptyCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
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
}

enum _CollectorHistoryScope { reservations, absent, present }

class _CollectorHistoryPage extends StatefulWidget {
  const _CollectorHistoryPage();

  @override
  State<_CollectorHistoryPage> createState() => _CollectorHistoryPageState();
}

class _CollectorHistoryPageState extends State<_CollectorHistoryPage> {
  _CollectorHistoryScope _scope = _CollectorHistoryScope.reservations;

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Historique voyage',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _HistoryActionButton(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Réservation',
                    selected: _scope == _CollectorHistoryScope.reservations,
                    onTap: () => setState(
                      () => _scope = _CollectorHistoryScope.reservations,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HistoryActionButton(
                    icon: Icons.person_off_rounded,
                    label: 'Absent',
                    selected: _scope == _CollectorHistoryScope.absent,
                    onTap: () =>
                        setState(() => _scope = _CollectorHistoryScope.absent),
                  ),
                  const SizedBox(width: 8),
                  _HistoryActionButton(
                    icon: Icons.how_to_reg_rounded,
                    label: 'Présent',
                    selected: _scope == _CollectorHistoryScope.present,
                    onTap: () =>
                        setState(() => _scope = _CollectorHistoryScope.present),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_scope == _CollectorHistoryScope.reservations)
                Expanded(
                  child: _CollectorReservationList(
                    onNewReservation: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _CollectorReservationPage(),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                )
              else
                Expanded(
                  child: _CollectorAttendanceList(
                    title: _scope == _CollectorHistoryScope.absent
                        ? 'Passagers absents'
                        : 'Passagers présents',
                    emptyMessage: _scope == _CollectorHistoryScope.absent
                        ? 'Aucun passager absent enregistré.'
                        : 'Aucun passager présent enregistré.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectorReservationList extends StatelessWidget {
  final VoidCallback onNewReservation;

  const _CollectorReservationList({required this.onNewReservation});

  @override
  Widget build(BuildContext context) {
    final reservations = _CollectorReservationStore.reservations;

    return ListView(
      children: [
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onNewReservation,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nouvelle réservation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (reservations.isEmpty)
          const _CollectorEmptyCard(
            title: 'Aucune réservation',
            message:
                'Les réservations faites par le percepteur apparaîtront ici.',
          )
        else
          ...reservations.map((item) => _CollectorReservationCard(item: item)),
      ],
    );
  }
}

class _HistoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _HistoryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    return Expanded(
      child: SizedBox(
        height: 58,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: selected ? Colors.white : deepBlue,
            side: BorderSide(color: deepBlue.withValues(alpha: 0.18)),
            backgroundColor: selected ? const Color(0xFF16A34A) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
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

class _CollectorNewsArticle {
  final String category;
  final String title;
  final String date;
  final String image;
  final String excerpt;
  final List<String> body;

  const _CollectorNewsArticle({
    required this.category,
    required this.title,
    required this.date,
    required this.image,
    required this.excerpt,
    required this.body,
  });
}

const List<_CollectorNewsArticle> _collectorNewsArticles = [
  _CollectorNewsArticle(
    category: 'Annonces',
    title: 'Nouveau départ sur Gouré',
    date: '28/03/2026',
    image: 'assets/images/coli1.jpg',
    excerpt:
        'Fofana renforce son réseau avec un nouveau départ pensé pour faciliter les déplacements réguliers.',
    body: [
      'Fofana informe son aimable clientèle de la mise en place d’un nouveau départ sur l’axe Gouré afin de rendre les voyages plus simples, plus réguliers et plus confortables.',
      'Cette nouvelle desserte répond à la demande des voyageurs qui souhaitent mieux organiser leurs déplacements entre les grandes villes et les localités desservies par Fofana.',
      'Les clients sont invités à se rapprocher des agences Fofana pour confirmer les horaires, les disponibilités et les conditions de réservation.',
    ],
  ),
  _CollectorNewsArticle(
    category: 'Annonces',
    title: "Renforcement des départs sur l'axe Tchaourou",
    date: '25/03/2026',
    image: 'assets/images/coli2.jpg',
    excerpt:
        'De nouveaux horaires sont ajoutés pour offrir plus de flexibilité aux voyageurs.',
    body: [
      'Pour mieux accompagner les besoins de mobilité, Fofana annonce un renforcement progressif des départs sur l’axe Tchaourou.',
      'Cette organisation permet aux voyageurs de choisir des créneaux plus adaptés à leurs programmes personnels, professionnels ou familiaux.',
      'Les équipes en agence restent disponibles pour orienter les clients et les aider à choisir le départ le plus pratique.',
    ],
  ),
  _CollectorNewsArticle(
    category: 'Presse',
    title: 'Fofana modernise l’accueil dans ses agences',
    date: '18/03/2026',
    image: 'assets/images/coli3.jpg',
    excerpt:
        'Un parcours client plus fluide est déployé pour améliorer l’achat de tickets et l’information voyageur.',
    body: [
      'Fofana poursuit l’amélioration de l’expérience client dans ses agences avec des espaces plus lisibles, un accueil renforcé et une meilleure orientation des voyageurs.',
      'L’objectif est de réduire l’attente, d’améliorer la qualité des informations et de rendre chaque étape du voyage plus agréable.',
      'Cette modernisation s’inscrit dans une démarche continue de qualité de service.',
    ],
  ),
  _CollectorNewsArticle(
    category: 'Conseils',
    title: 'Bien préparer son voyage avec Fofana',
    date: '12/03/2026',
    image: 'assets/images/coli4.jpg',
    excerpt:
        'Quelques réflexes simples pour voyager sereinement et éviter les oublis avant le départ.',
    body: [
      'Avant chaque départ, Fofana recommande aux voyageurs de vérifier leur ticket, leur pièce d’identité et l’heure de présentation en agence.',
      'Il est conseillé d’arriver suffisamment tôt afin d’effectuer les formalités sans stress et d’embarquer dans de bonnes conditions.',
      'Pour les bagages et colis, les équipes Fofana peuvent préciser les règles applicables selon le trajet choisi.',
    ],
  ),
  _CollectorNewsArticle(
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

class _CollectorNewsSection extends StatefulWidget {
  const _CollectorNewsSection();

  @override
  State<_CollectorNewsSection> createState() => _CollectorNewsSectionState();
}

class _CollectorNewsSectionState extends State<_CollectorNewsSection> {
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
        () => _pageIndex = (_pageIndex + 1) % _collectorNewsArticles.length,
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

    void openDetail(_CollectorNewsArticle article) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _CollectorNewsDetailPage(article: article),
        ),
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
                  color: Colors.red,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _CollectorNewsListPage(),
                    ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
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
            itemCount: _collectorNewsArticles.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = _collectorNewsArticles[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _CollectorNewsHeroTile(
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
          children: List.generate(_collectorNewsArticles.length, (i) {
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

class _CollectorNewsHeroTile extends StatelessWidget {
  final _CollectorNewsArticle article;
  final VoidCallback onTap;
  final bool compact;

  const _CollectorNewsHeroTile({
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
                child: _CollectorNewsCategoryPill(category: article.category),
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

class _CollectorNewsCategoryPill extends StatelessWidget {
  final String category;

  const _CollectorNewsCategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CollectorNewsListPage extends StatelessWidget {
  const _CollectorNewsListPage();

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actualités',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          itemCount: _collectorNewsArticles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final article = _collectorNewsArticles[index];
            return SizedBox(
              height: 178,
              child: _CollectorNewsHeroTile(
                article: article,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _CollectorNewsDetailPage(article: article),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CollectorNewsDetailPage extends StatelessWidget {
  final _CollectorNewsArticle article;

  const _CollectorNewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actualité',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            SizedBox(
              height: 230,
              child: _CollectorNewsHeroTile(article: article, onTap: () {}),
            ),
            const SizedBox(height: 18),
            Text(
              article.title,
              style: const TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publié le ${article.date}',
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.excerpt,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ...article.body.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  paragraph,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorTab {
  final String title;
  final IconData icon;

  const _CollectorTab(this.title, this.icon);
}
