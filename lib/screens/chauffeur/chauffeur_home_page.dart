import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:fofanavoyage/screens/percepteur/parts/assignments_section.dart';
import 'package:fofanavoyage/screens/percepteur/parts/history_news_section.dart';
import 'package:fofanavoyage/screens/percepteur/parts/notifications_section.dart';
import 'package:fofanavoyage/data/local/session_store.dart';
import 'package:fofanavoyage/navigation.dart';
import 'package:fofanavoyage/services/affectation_service.dart';
import 'package:fofanavoyage/services/auth_service.dart';
import 'package:fofanavoyage/services/driver_position_service.dart';
import 'package:fofanavoyage/widgets/profile_avatar.dart';

class ChauffeurTab {
  final String title;
  final IconData icon;

  const ChauffeurTab(this.title, this.icon);
}

class ChauffeurHomePage extends StatefulWidget {
  const ChauffeurHomePage({super.key});

  @override
  State<ChauffeurHomePage> createState() => _ChauffeurHomePageState();
}

class _ChauffeurHomePageState extends State<ChauffeurHomePage>
    with WidgetsBindingObserver {
  static const _green = Color(0xFF16A34A);
  static const _deepGreen = Color(0xFF0B4F2A);
  static const _tabs = [
    ChauffeurTab('Accueil', Icons.home_rounded),
    ChauffeurTab('Affectation', Icons.assignment_rounded),
    ChauffeurTab('Connexion', Icons.lock_open_rounded),
    ChauffeurTab('Voyage', Icons.directions_bus_filled_rounded),
    ChauffeurTab('Profil', Icons.person_rounded),
  ];

  final AffectationService _affectationService = AffectationService();
  final DriverPositionService _driverPositionService = DriverPositionService();
  int _currentIndex = 0;
  int _voyageTabIndex = 0;
  List<Map<String, dynamic>> _assignments = [];
  Map<String, dynamic>? _mission;
  Timer? _trackingTimer;
  bool _loading = true;
  bool _actionLoading = false;
  bool _isTracking = false;
  bool _sendingPosition = false;
  String? _loadError;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trackingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isTracking && _mission != null) {
      final id = int.tryParse(_mission!['id']?.toString() ?? '');
      if (id != null) _startLocationUpdates(id);
    } else if (state == AppLifecycleState.paused) {
      _trackingTimer?.cancel();
      _trackingTimer = null;
    }
  }

  Future<void> _loadMission({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final assignments = (await _affectationService.getMyAssignments())
          .map((assignment) => Map<String, dynamic>.from(assignment))
          .toList();
      final eligible =
          assignments.where((assignment) {
            final status = assignment['statut']?.toString().toLowerCase();
            return status == 'en_cours' || status == 'planifie';
          }).toList()..sort((left, right) {
            final leftStatus = left['statut']?.toString().toLowerCase();
            final rightStatus = right['statut']?.toString().toLowerCase();
            if (leftStatus == 'en_cours' && rightStatus != 'en_cours') {
              return -1;
            }
            if (rightStatus == 'en_cours' && leftStatus != 'en_cours') {
              return 1;
            }
            final leftDate = DateTime.tryParse(
              left['date_debut']?.toString() ?? '',
            );
            final rightDate = DateTime.tryParse(
              right['date_debut']?.toString() ?? '',
            );
            if (leftDate == null) return 1;
            if (rightDate == null) return -1;
            return leftDate.compareTo(rightDate);
          });

      Map<String, dynamic>? mission;
      var tracking = false;
      for (final assignment in eligible) {
        final id = int.tryParse(assignment['id']?.toString() ?? '');
        if (id == null) continue;

        final trackingStatus = await _driverPositionService.getTrackingStatus(
          id,
        );
        if (trackingStatus == DriverTrackingStatus.ended) {
          assignment['statut'] = 'passe';
          continue;
        }
        if (trackingStatus == DriverTrackingStatus.started) {
          assignment['statut'] = 'en_cours';
          mission = assignment;
          tracking = true;
          break;
        }
        mission ??= assignment;
      }

      if (!mounted) return;
      setState(() {
        _assignments = assignments;
        _mission = mission;
        _isTracking = tracking;
        _loading = false;
        _loadError = null;
        _locationError = null;
      });
      if (tracking && mission != null) {
        final id = int.tryParse(mission['id']?.toString() ?? '');
        if (id != null) _startLocationUpdates(id);
      } else {
        _trackingTimer?.cancel();
        _trackingTimer = null;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = _errorMessage(error);
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Activez le GPS de votre téléphone pour continuer.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('L’autorisation de localisation est nécessaire.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Autorisez la localisation dans les paramètres de votre téléphone.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _startTracking() async {
    final mission = _mission;
    final id = int.tryParse(mission?['id']?.toString() ?? '');
    if (mission == null || id == null) return;

    setState(() {
      _actionLoading = true;
      _locationError = null;
    });
    try {
      final position = await _getCurrentPosition();
      await _driverPositionService.startJourney(
        id,
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _isTracking = true;
        _actionLoading = false;
        _mission = {...mission, 'statut': 'en_cours'};
      });
      _startLocationUpdates(id);
    } catch (error) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      if (error.toString().contains('déjà commencé')) {
        await _loadMission(showLoading: false);
      }
      if (!mounted) return;
      _showMessage(_errorMessage(error), isError: true);
    }
  }

  void _startLocationUpdates(int affectationId) {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_sendPosition(affectationId));
    });
  }

  Future<void> _sendPosition(int affectationId) async {
    if (_sendingPosition || !mounted) return;
    _sendingPosition = true;
    try {
      final position = await _getCurrentPosition();
      await _driverPositionService.updateLocation(
        affectationId,
        position.latitude,
        position.longitude,
      );
      if (mounted && _locationError != null) {
        setState(() => _locationError = null);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _locationError = _errorMessage(error));
      }
    } finally {
      _sendingPosition = false;
    }
  }

  Future<void> _endTracking() async {
    final mission = _mission;
    final id = int.tryParse(mission?['id']?.toString() ?? '');
    if (mission == null || id == null) return;

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l’arrivée'),
        content: const Text('Voulez-vous marquer votre arrivée ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer le trajet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Marquer l’arrivée'),
          ),
        ],
      ),
    );
    if (shouldEnd != true || !mounted) return;

    setState(() {
      _actionLoading = true;
      _locationError = null;
    });
    try {
      await _driverPositionService.endJourney(id);
      _trackingTimer?.cancel();
      _trackingTimer = null;
      if (!mounted) return;
      setState(() {
        _isTracking = false;
        _actionLoading = false;
        _voyageTabIndex = 1;
      });
      await _loadMission();
      if (!mounted) return;
      _showMessage('Voyage terminé. Bonne arrivée !');
    } catch (error) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      _showMessage(_errorMessage(error), isError: true);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    _trackingTimer?.cancel();
    await AuthService().deconnexion();
    if (mounted) Get.offAllNamed(Routes.LOGIN);
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 3) unawaited(_loadMission());
  }

  void _selectVoyageTab(int index) {
    setState(() => _voyageTabIndex = index);
    if (index == 1) unawaited(_loadMission());
  }

  void _openMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Menu chauffeur',
                style: TextStyle(
                  color: _deepGreen,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < _tabs.length; index++)
                ListTile(
                  leading: Icon(_tabs[index].icon, color: _green),
                  title: Text(
                    _tabs[index].title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _selectTab(index);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Action impossible' : 'Espace chauffeur',
      message,
      backgroundColor: isError ? Colors.redAccent : _deepGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  String _errorMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  Map<String, dynamic> _nestedMap(String key) {
    final value = _mission?[key];
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  String _value(
    Map<String, dynamic> data,
    String key, [
    String fallback = '—',
  ]) {
    final value = data[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Date non précisée';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '—';
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  @override
  Widget build(BuildContext context) {
    final mission = _mission;
    final bus = _nestedMap('bus');
    final ligne = _nestedMap('ligne');
    final status = mission?['statut']?.toString().toLowerCase();
    final canStart = status == 'en_cours' && !_isTracking;
    final showWorkspaceHeader =
        _currentIndex == 0 || _currentIndex == 3 || _currentIndex == 4;
    final currentTab = _tabs[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Colors.white, Color(0xFFFFF9F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showWorkspaceHeader) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PercepteurHeaderIconButton(
                          icon: Icons.menu_rounded,
                          onTap: _openMenu,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_fofana_no_background.png',
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: const PercepteurNotificationIconButton(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Espace chauffeur',
                          style: TextStyle(
                            color: _deepGreen,
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
                      ],
                    ),
                  ),
                ),
              ],
              Expanded(
                child: switch (_currentIndex) {
                  0 => _homeContent(),
                  1 => const PercepteurAssignmentsPage(showBackButton: false),
                  2 => const PercepteurConnectionPage(showBackButton: false),
                  3 => _voyageContent(mission, bus, ligne, status),
                  _ => const ChauffeurProfileTabContent(),
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentIndex == 3 &&
                _voyageTabIndex == 0 &&
                !_loading &&
                _loadError == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                child: mission == null
                    ? _noMissionAction()
                    : _actionButton(canStart),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: _green.withValues(alpha: 0.10)),
                boxShadow: [
                  BoxShadow(
                    color: _deepGreen.withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isActive = index == _currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTab(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? _green : Colors.transparent,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab.icon,
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF7B849B),
                              size: 19,
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                tab.title,
                                maxLines: 1,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF7B849B),
                                  fontSize: 10,
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
          ],
        ),
      ),
    );
  }

  Widget _homeContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      children: [
        const PercepteurNewsSection(),
        const SizedBox(height: 22),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Menu chauffeur',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _homeMenuCard(
          icon: Icons.assignment_rounded,
          title: 'Affectation',
          subtitle: 'Consulter vos missions et les informations du trajet.',
          onTap: () => _selectTab(1),
        ),
        const SizedBox(height: 12),
        _homeMenuCard(
          icon: Icons.lock_open_rounded,
          title: 'Connexion',
          subtitle: 'Activer la session avec le code transmis par l’agence.',
          onTap: () => _selectTab(2),
        ),
        const SizedBox(height: 12),
        _homeMenuCard(
          icon: Icons.directions_bus_filled_rounded,
          title: 'Démarrer le voyage',
          subtitle: 'Ouvrir votre mission et partager la position GPS du bus.',
          onTap: () => _selectTab(3),
          emphasized: true,
        ),
      ],
    );
  }

  Widget _homeMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool emphasized = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: emphasized
                  ? _green.withValues(alpha: 0.24)
                  : const Color(0xFFE8EEF0),
            ),
            boxShadow: [
              BoxShadow(
                color: _deepGreen.withValues(alpha: 0.045),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: emphasized ? _green : _green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: emphasized ? Colors.white : _green,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF202B38),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voyageContent(
    Map<String, dynamic>? mission,
    Map<String, dynamic> bus,
    Map<String, dynamic> ligne,
    String? status,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1ED),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                _VoyageTabButton(
                  label: 'Voyage en cours',
                  icon: Icons.directions_bus_filled_rounded,
                  selected: _voyageTabIndex == 0,
                  onTap: () => _selectVoyageTab(0),
                ),
                _VoyageTabButton(
                  label: 'Historique',
                  icon: Icons.history_rounded,
                  selected: _voyageTabIndex == 1,
                  onTap: () => _selectVoyageTab(1),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _green))
              : _loadError != null
              ? _errorContent()
              : _voyageTabIndex == 0
              ? mission == null
                    ? _emptyContent()
                    : _missionContent(mission, bus, ligne, status)
              : _historyContent(),
        ),
      ],
    );
  }

  Widget _historyContent() {
    if (_assignments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_rounded,
                color: Color(0xFFCBD5E1),
                size: 50,
              ),
              const SizedBox(height: 12),
              const Text(
                'Aucun voyage à afficher',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadMission,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualiser'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMission,
      color: _green,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
        itemCount: _assignments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _historyAssignmentCard(_assignments[index]),
      ),
    );
  }

  Widget _historyAssignmentCard(Map<String, dynamic> assignment) {
    Map<String, dynamic> mapOf(Object? value) =>
        value is Map ? Map<String, dynamic>.from(value) : {};

    final bus = mapOf(assignment['bus']);
    final line = mapOf(assignment['ligne']);
    final rawStatus = assignment['statut']?.toString() ?? '';
    final status = switch (rawStatus.toLowerCase()) {
      'en_cours' => 'En cours',
      'planifie' || 'planifiée' || 'planifiee' => 'Planifié',
      'passe' || 'passé' => 'Passé',
      'absent' => 'Absent',
      'reaffecte' || 'reaffectee' => 'Réaffecté',
      'annule' || 'annulee' || 'annulée' => 'Annulé',
      _ => rawStatus.isEmpty ? 'Statut inconnu' : rawStatus,
    };
    final statusColor = switch (rawStatus.toLowerCase()) {
      'en_cours' => const Color(0xFF16A34A),
      'planifie' || 'planifiée' || 'planifiee' => const Color(0xFFD97706),
      'passe' || 'passé' => const Color(0xFF2563EB),
      'absent' || 'annule' || 'annulee' || 'annulée' => const Color(0xFFE11D48),
      _ => const Color(0xFF64748B),
    };
    final route =
        '${line['trajet_depart'] ?? 'Départ'} → '
        '${line['trajet_arrivee'] ?? 'Destination'}';
    final rawDate = assignment['date_debut']?.toString();
    final date = _formatDate(rawDate);
    final time = _formatTime(assignment['heure_debut']?.toString());
    final registration =
        bus['immatriculation']?.toString() ?? 'Bus non renseigné';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF0)),
        boxShadow: [
          BoxShadow(
            color: _deepGreen.withValues(alpha: 0.045),
            blurRadius: 13,
            offset: const Offset(0, 5),
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
                  route,
                  style: const TextStyle(
                    color: Color(0xFF202B38),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HistoryInfoLine(
            icon: Icons.directions_bus_filled_rounded,
            text: registration,
          ),
          const SizedBox(height: 8),
          _HistoryInfoLine(
            icon: Icons.calendar_month_rounded,
            text: '$date à $time',
          ),
        ],
      ),
    );
  }

  Widget _missionContent(
    Map<String, dynamic> mission,
    Map<String, dynamic> bus,
    Map<String, dynamic> ligne,
    String? status,
  ) {
    final planned = status == 'planifie';
    final rawDate = mission['date_debut']?.toString();
    final startTime = _formatTime(mission['heure_debut']?.toString());

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      children: [
        _vehicleCard(_value(bus, 'immatriculation')),
        const SizedBox(height: 16),
        _routeCard(
          _value(ligne, 'trajet_depart'),
          _value(ligne, 'trajet_arrivee'),
        ),
        const SizedBox(height: 16),
        _detailsCard(
          startTime,
          _formatDate(rawDate),
          planned ? 'Planifié' : 'En cours',
          planned,
        ),
        if (_isTracking) ...[const SizedBox(height: 16), _liveCard()],
        if (_locationError != null) ...[
          const SizedBox(height: 12),
          _inlineError(_locationError!),
        ],
        const SizedBox(height: 16),
        _instructionCard(),
      ],
    );
  }

  Widget _vehicleCard(String registration) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8EEF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _green.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_bus_filled_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VÉHICULE',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  registration,
                  style: const TextStyle(
                    color: Color(0xFF202B38),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0BAC5)),
        ],
      ),
    );
  }

  Widget _routeCard(String departure, String arrival) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8EEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            icon: Icons.alt_route_rounded,
            title: 'Itinéraire',
          ),
          const SizedBox(height: 20),
          _RoutePoint(
            color: const Color(0xFF2563EB),
            label: 'DÉPART',
            value: departure,
            isLast: false,
          ),
          _RoutePoint(
            color: const Color(0xFFF43F5E),
            label: 'ARRIVÉE',
            value: arrival,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(String time, String date, String status, bool planned) {
    final color = planned ? const Color(0xFFD97706) : _green;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8EEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            icon: Icons.event_note_rounded,
            title: 'Détails du trajet',
          ),
          const SizedBox(height: 16),
          _DetailLine(
            icon: Icons.schedule_rounded,
            label: 'Heure de départ',
            value: time,
          ),
          const SizedBox(height: 14),
          _DetailLine(
            icon: Icons.calendar_month_rounded,
            label: 'Date',
            value: date,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'STATUT : ${status.toUpperCase()}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF0B7A3B)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.near_me_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIGNAL GPS EN DIRECT',
                  style: TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Votre bus est visible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFCBD5E1)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONSIGNE',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gardez cette application ouverte pendant toute la durée du trajet afin de partager votre position.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(bool canStart) {
    if (_actionLoading) {
      return const SizedBox(
        height: 58,
        child: Center(child: CircularProgressIndicator(color: _green)),
      );
    }
    if (_isTracking) {
      return SizedBox(
        height: 58,
        child: FilledButton.icon(
          onPressed: _endTracking,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.stop_rounded, size: 25),
          label: const Text(
            'MARQUER L’ARRIVÉE',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }
    if (!canStart) {
      return SizedBox(
        height: 58,
        child: FilledButton.icon(
          onPressed: () => _selectTab(2),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text(
            'ACTIVER LA SESSION POUR DÉMARRER',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }
    return SizedBox(
      height: 58,
      child: FilledButton.icon(
        onPressed: _startTracking,
        style: FilledButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: _green.withValues(alpha: 0.25),
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 27),
        label: const Text(
          'DÉMARRER LA MISSION',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _noMissionAction() {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _loadMission,
        style: OutlinedButton.styleFrom(
          foregroundColor: _deepGreen,
          side: BorderSide(color: _green.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text(
          'ACTUALISER MES AFFECTATIONS',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _emptyContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE8EEF0)),
          ),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'AUCUNE MISSION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF202B38),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous n’avez pas d’affectation pour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: _loadMission,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualiser'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFDC2626),
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Impossible de charger la mission',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF202B38),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError ?? 'Une erreur est survenue.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loadMission,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(backgroundColor: _green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inlineError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Text(
        'Position non transmise : $message',
        style: const TextStyle(
          color: Color(0xFFBE123C),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF16A34A), size: 19),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202B38),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isLast;

  const _RoutePoint({
    required this.color,
    required this.label,
    required this.value,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF202B38),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class ChauffeurProfileTabContent extends StatelessWidget {
  const ChauffeurProfileTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SessionStore.currentUserNotifier,
      builder: (context, user, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          children: [
            Center(
              child: ProfileAvatar(
                user: user,
                radius: 52,
                fallbackIcon: Icons.directions_bus_filled_rounded,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profil chauffeur',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0B4F2A),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE8EEF0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ChauffeurProfileInfoRow(
                    icon: Icons.badge_rounded,
                    label: 'Nom et prénom',
                    value: user?.fullName,
                  ),
                  _ChauffeurProfileInfoRow(
                    icon: Icons.phone_rounded,
                    label: 'Téléphone',
                    value: user?.numero,
                  ),
                  _ChauffeurProfileInfoRow(
                    icon: Icons.location_city_rounded,
                    label: 'Agence',
                    value: user?.agence?['nom_agence']?.toString(),
                  ),
                  _ChauffeurProfileInfoRow(
                    icon: Icons.work_rounded,
                    label: 'Fonction',
                    value: 'Chauffeur',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChauffeurProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;

  const _ChauffeurProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue == null || displayValue.isEmpty
                      ? 'Non renseigné'
                      : displayValue,
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

class _VoyageTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VoyageTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? const Color(0xFF0B4F2A)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF0B4F2A)
                          : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
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

class _HistoryInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HistoryInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
