import 'package:flutter/material.dart';
import 'dart:async';
import 'package:code_initial/screens/percepteur/parts/notifications_section.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/models/access_session_model.dart';
import 'package:code_initial/services/affectation_service.dart';

// Missions percepteur: filtres, listes, detail, itineraire et connexion.

// Widget stub pour PercepteurParcelStatusPill
class PercepteurParcelStatusPill extends StatelessWidget {
  final String label;
  final bool strong;

  const PercepteurParcelStatusPill({
    super.key,
    required this.label,
    required this.strong,
  });

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

enum PercepteurAssignmentFilter { current, scheduled, past }

enum PercepteurAssignmentPastStatusFilter { all, completed, reassigned, absent }

extension on PercepteurAssignmentPastStatusFilter {
  String get label {
    switch (this) {
      case PercepteurAssignmentPastStatusFilter.all:
        return 'Tous';
      case PercepteurAssignmentPastStatusFilter.completed:
        return 'Effectué';
      case PercepteurAssignmentPastStatusFilter.reassigned:
        return 'Réaffecter';
      case PercepteurAssignmentPastStatusFilter.absent:
        return 'Absent';
    }
  }

  bool matches(String status) {
    switch (this) {
      case PercepteurAssignmentPastStatusFilter.all:
        return true;
      case PercepteurAssignmentPastStatusFilter.completed:
        return status == 'Effectué';
      case PercepteurAssignmentPastStatusFilter.reassigned:
        return status == 'Réaffecté' || status == 'Réaffecter';
      case PercepteurAssignmentPastStatusFilter.absent:
        return status == 'Absent';
    }
  }
}

class PercepteurAssignmentPercepteur {
  final String name;
  final String phone;

  const PercepteurAssignmentPercepteur({
    required this.name,
    required this.phone,
  });
}

class PercepteurAssignmentRecord {
  final int id;
  final String rawStatus;
  final bool sessionOpen;
  final String percepteurName;
  final String date;
  final String endDate;
  final String time;
  final String busMatricule;
  final String driverName;
  final String driverPhone;
  final String route;
  final String sessionCloseTime;
  final List<PercepteurAssignmentPercepteur> percepteurs;
  final String status;

  const PercepteurAssignmentRecord({
    required this.id,
    required this.rawStatus,
    required this.sessionOpen,
    required this.percepteurName,
    required this.date,
    required this.endDate,
    required this.time,
    required this.busMatricule,
    required this.driverName,
    required this.driverPhone,
    required this.route,
    required this.sessionCloseTime,
    required this.percepteurs,
    required this.status,
  });

  factory PercepteurAssignmentRecord.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? team,
    bool sessionOpen = false,
  }) {
    Map<String, dynamic> mapOf(Object? value) =>
        value is Map ? Map<String, dynamic>.from(value) : {};

    final bus = mapOf(json['bus']);
    final line = mapOf(json['ligne']);
    final currentUser = mapOf(json['user']);
    final teamMembers = (team?['equipe'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((item) => mapOf(item['user']))
        .where((user) => user.isNotEmpty)
        .toList();

    String fullName(Map<String, dynamic> user) =>
        '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim();
    String formatDate(Object? value) {
      final parsed = DateTime.tryParse(value?.toString() ?? '');
      if (parsed == null) return value?.toString() ?? '-';
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
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    }

    final driver = teamMembers.firstWhere(
      (user) => user['role']?.toString().toLowerCase() == 'chauffeur',
      orElse: () => <String, dynamic>{},
    );
    final currentAssignmentId = int.tryParse(json['id']?.toString() ?? '');
    final collectors = <PercepteurAssignmentPercepteur>[];
    for (final member in teamMembers) {
      if (member['role']?.toString().toLowerCase() != 'percepteur') continue;
      final assignment = (team?['equipe'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .firstWhere(
            (item) =>
                mapOf(item['user'])['id']?.toString() ==
                member['id']?.toString(),
            orElse: () => <String, dynamic>{},
          );
      if (int.tryParse(assignment['affectation_id']?.toString() ?? '') ==
          currentAssignmentId) {
        continue;
      }
      collectors.add(
        PercepteurAssignmentPercepteur(
          name: fullName(member),
          phone: member['numero']?.toString() ?? '',
        ),
      );
    }

    final rawStatus = json['statut']?.toString() ?? '';
    final reaffectationId = json['reaffectation_id'];
    final status = reaffectationId != null
        ? 'Réaffecté'
        : switch (rawStatus) {
            'en_cours' => 'En cours',
            'planifie' => 'Programmé',
            'passe' => 'Effectué',
            'absent' => 'Absent',
            _ => rawStatus,
          };
    final readableStatus = rawStatus == 'en_cours'
        ? sessionOpen
              ? 'Session ouverte'
              : 'Code d’accès à saisir'
        : status;

    return PercepteurAssignmentRecord(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      rawStatus: rawStatus,
      sessionOpen: sessionOpen,
      percepteurName: fullName(currentUser).isEmpty
          ? SessionStore.currentUser?.fullName ?? 'Percepteur'
          : fullName(currentUser),
      date: formatDate(json['date_debut']),
      endDate: formatDate(json['date_fin']),
      time: json['heure_debut']?.toString() ?? '-',
      busMatricule: bus['immatriculation']?.toString() ?? 'Bus non renseigné',
      driverName: fullName(driver).isEmpty ? 'Non renseigné' : fullName(driver),
      driverPhone: driver['numero']?.toString() ?? 'Non renseigné',
      route:
          '${line['trajet_depart'] ?? 'Départ'} → '
          '${line['trajet_arrivee'] ?? 'Destination'}',
      sessionCloseTime: json['heure_fin']?.toString() ?? '-',
      percepteurs: collectors,
      status: readableStatus,
    );
  }
}

class PercepteurAssignmentsPage extends StatefulWidget {
  const PercepteurAssignmentsPage({super.key});

  @override
  State<PercepteurAssignmentsPage> createState() =>
      PercepteurAssignmentsPageState();
}

class PercepteurAssignmentsPageState extends State<PercepteurAssignmentsPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  PercepteurAssignmentFilter _filter = PercepteurAssignmentFilter.current;
  PercepteurAssignmentPastStatusFilter _pastStatusFilter =
      PercepteurAssignmentPastStatusFilter.all;
  final _service = AffectationService();
  List<PercepteurAssignmentRecord> _assignments = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final rows = await _service.getMyAssignments();
      final sessionResponse = await _service.getMySession();
      final access = sessionResponse['access'] is Map
          ? Map<String, dynamic>.from(sessionResponse['access'] as Map)
          : <String, dynamic>{};
      final sessionActive = sessionResponse['session_active'] == true;
      final activeAssignmentId = sessionActive
          ? int.tryParse(access['affectation_id']?.toString() ?? '')
          : null;
      final assignments = rows
          .map(
            (row) => PercepteurAssignmentRecord.fromJson(
              row,
              sessionOpen:
                  sessionActive &&
                  activeAssignmentId != null &&
                  row['id']?.toString() == activeAssignmentId.toString(),
            ),
          )
          .toList();
      final currentAssignments = assignments
          .where((item) => item.rawStatus == 'en_cours')
          .toList();
      for (final item in currentAssignments) {
        try {
          final team = await _service.getAssignmentTeam(item.id);
          final index = assignments.indexWhere((value) => value.id == item.id);
          if (index != -1) {
            assignments[index] = PercepteurAssignmentRecord.fromJson(
              rows.firstWhere(
                (row) => row['id']?.toString() == item.id.toString(),
              ),
              team: team,
              sessionOpen: item.sessionOpen,
            );
          }
        } catch (error) {
          debugPrint(
            'Impossible de charger l’équipe de l’affectation ${item.id}: $error',
          );
        }
      }
      if (!mounted) return;
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<PercepteurAssignmentRecord> get _records {
    switch (_filter) {
      case PercepteurAssignmentFilter.current:
        return _assignments
            .where((assignment) => assignment.rawStatus == 'en_cours')
            .toList();
      case PercepteurAssignmentFilter.scheduled:
        return _assignments
            .where((assignment) => assignment.rawStatus == 'planifie')
            .toList();
      case PercepteurAssignmentFilter.past:
        return _assignments
            .where(
              (assignment) =>
                  assignment.rawStatus == 'passe' ||
                  assignment.rawStatus == 'absent' ||
                  assignment.rawStatus == 'reaffectee',
            )
            .where((assignment) => _pastStatusFilter.matches(assignment.status))
            .toList();
    }
  }

  String get _title {
    switch (_filter) {
      case PercepteurAssignmentFilter.current:
        return 'Affectation en cours';
      case PercepteurAssignmentFilter.scheduled:
        return 'Affectations programmées';
      case PercepteurAssignmentFilter.past:
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

  void _selectFilter(PercepteurAssignmentFilter value) {
    setState(() {
      _filter = value;
      if (_filter != PercepteurAssignmentFilter.past) {
        _pastStatusFilter = PercepteurAssignmentPastStatusFilter.all;
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
                      PercepteurHeaderIconButton(
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
                  PercepteurAssignmentSegmentedControl(
                    selected: _filter,
                    currentCount: _countFor(PercepteurAssignmentFilter.current),
                    scheduledCount: _countFor(
                      PercepteurAssignmentFilter.scheduled,
                    ),
                    pastCount: _countFor(PercepteurAssignmentFilter.past),
                    onChanged: _selectFilter,
                  ),
                  const SizedBox(height: 18),
                  if (_loadError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE53935).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _loadError!,
                            style: const TextStyle(
                              color: Color(0xFFB42318),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _loadAssignments,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Réessayer'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: CircularProgressIndicator(color: _fofanaGreen),
                      ),
                    ),
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
                          if (_filter == PercepteurAssignmentFilter.current) {
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
                                          item.percepteurName,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      PercepteurParcelStatusPill(
                                        label: item.status,
                                        strong: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  PercepteurAssignmentRoutePanel(
                                    route: item.route,
                                  ),
                                  const SizedBox(height: 12),
                                  PercepteurAssignmentInfoGrid(
                                    children: [
                                      PercepteurAssignmentInfo(
                                        icon: Icons.person_rounded,
                                        label: 'Chauffeur',
                                        value: item.driverName,
                                      ),
                                      PercepteurAssignmentInfo(
                                        icon: Icons.phone_rounded,
                                        label: 'Téléphone chauffeur',
                                        value: item.driverPhone,
                                      ),
                                      PercepteurAssignmentInfo(
                                        icon: Icons.lock_clock_rounded,
                                        label: 'Fin session',
                                        value: item.sessionCloseTime,
                                      ),
                                      PercepteurAssignmentInfo(
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
                                  if (item.percepteurs.isEmpty)
                                    const Text(
                                      'Aucun autre percepteur affecté à ce voyage.',
                                      style: TextStyle(
                                        color: Color(0xFF5F6B86),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: item.percepteurs.map((
                                        percepteur,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Text(
                                            '${percepteur.name} • ${percepteur.phone}',
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
                                      PercepteurAssignmentDetailPage(
                                        assignment: item,
                                        mode: _filter,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList()),
                  if (_filter == PercepteurAssignmentFilter.past) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: PercepteurAssignmentPastStatusFilter.values
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

  int _countFor(PercepteurAssignmentFilter filter) {
    switch (filter) {
      case PercepteurAssignmentFilter.current:
        return _assignments
            .where((item) => item.rawStatus == 'en_cours')
            .length;
      case PercepteurAssignmentFilter.scheduled:
        return _assignments
            .where((item) => item.rawStatus == 'planifie')
            .length;
      case PercepteurAssignmentFilter.past:
        return _assignments
            .where(
              (item) =>
                  item.rawStatus == 'passe' ||
                  item.rawStatus == 'absent' ||
                  item.rawStatus == 'reaffectee',
            )
            .length;
    }
  }
}

class PercepteurAssignmentSegmentedControl extends StatelessWidget {
  final PercepteurAssignmentFilter selected;
  final int currentCount;
  final int scheduledCount;
  final int pastCount;
  final ValueChanged<PercepteurAssignmentFilter> onChanged;

  const PercepteurAssignmentSegmentedControl({
    super.key,
    required this.selected,
    required this.currentCount,
    required this.scheduledCount,
    required this.pastCount,
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
          PercepteurAssignmentTabButton(
            label: 'En cours ($currentCount)',
            icon: Icons.play_circle_fill_rounded,
            selected: selected == PercepteurAssignmentFilter.current,
            onTap: () => onChanged(PercepteurAssignmentFilter.current),
          ),
          PercepteurAssignmentTabButton(
            label: 'Programmer ($scheduledCount)',
            icon: Icons.event_available_rounded,
            selected: selected == PercepteurAssignmentFilter.scheduled,
            onTap: () => onChanged(PercepteurAssignmentFilter.scheduled),
          ),
          PercepteurAssignmentTabButton(
            label: 'Passer ($pastCount)',
            icon: Icons.history_rounded,
            selected: selected == PercepteurAssignmentFilter.past,
            onTap: () => onChanged(PercepteurAssignmentFilter.past),
          ),
        ],
      ),
    );
  }
}

class PercepteurAssignmentTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PercepteurAssignmentTabButton({
    super.key,
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

class PercepteurAssignmentDetailPage extends StatelessWidget {
  final PercepteurAssignmentRecord assignment;
  final PercepteurAssignmentFilter mode;

  const PercepteurAssignmentDetailPage({
    super.key,
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
                  PercepteurAssignmentRoutePanel(route: assignment.route),
                  const SizedBox(height: 18),
                  PercepteurAssignmentInfoGrid(
                    children: [
                      PercepteurAssignmentInfo(
                        icon: Icons.person_rounded,
                        label: 'Chauffeur',
                        value: assignment.driverName,
                      ),
                      PercepteurAssignmentInfo(
                        icon: Icons.phone_rounded,
                        label: 'Téléphone chauffeur',
                        value: assignment.driverPhone,
                      ),
                      PercepteurAssignmentInfo(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Matricule bus',
                        value: assignment.busMatricule,
                      ),
                      PercepteurAssignmentInfo(
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
                  ...assignment.percepteurs.map(
                    (percepteur) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: green.withValues(alpha: 0.12),
                        child: const Icon(Icons.person, color: green),
                      ),
                      title: Text(
                        percepteur.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(percepteur.phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone_rounded),
                        color: deepBlue,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                PercepteurPhoneSheet(percepteur: percepteur),
                          );
                        },
                      ),
                    ),
                  ),
                  if (mode == PercepteurAssignmentFilter.current) ...[
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

class PercepteurAssignmentRoutePanel extends StatefulWidget {
  final String route;

  const PercepteurAssignmentRoutePanel({super.key, required this.route});

  @override
  State<PercepteurAssignmentRoutePanel> createState() =>
      PercepteurAssignmentRoutePanelState();
}

class PercepteurAssignmentRoutePanelState
    extends State<PercepteurAssignmentRoutePanel> {
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

class PercepteurAssignmentInfoGrid extends StatelessWidget {
  final List<PercepteurAssignmentInfo> children;

  const PercepteurAssignmentInfoGrid({super.key, required this.children});

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

class PercepteurAssignmentInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PercepteurAssignmentInfo({
    super.key,
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

class PercepteurPhoneSheet extends StatelessWidget {
  final PercepteurAssignmentPercepteur percepteur;

  const PercepteurPhoneSheet({super.key, required this.percepteur});

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
                        percepteur.name,
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
                      percepteur.phone,
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

class PercepteurConnectionPage extends StatefulWidget {
  final AffectationService? service;
  final bool closeOnActivation;

  const PercepteurConnectionPage({
    super.key,
    this.service,
    this.closeOnActivation = false,
  });

  @override
  State<PercepteurConnectionPage> createState() =>
      PercepteurConnectionPageState();
}

class PercepteurConnectionPageState extends State<PercepteurConnectionPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);
  final TextEditingController _accessCodeController = TextEditingController();
  late final AffectationService _service =
      widget.service ?? AffectationService();
  Timer? _sessionTimer;
  int _sessionRemaining = 0;
  int? _assignmentDurationSeconds;
  Map<String, dynamic>? _sessionAssignment;
  bool _isSessionActive = false;
  bool _isLoadingSession = true;
  bool _isActivating = false;
  bool _showAccessCodeForm = false;
  String? _sessionError;

  @override
  void initState() {
    super.initState();
    _loadCurrentSession();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _accessCodeController.dispose();
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

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isSessionActive) return;
      final endsAt = _sessionEndsAt;
      if (endsAt == null) return;
      final remaining = endsAt.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        setState(() {
          _sessionRemaining = 0;
          _isSessionActive = false;
        });
        _sessionTimer?.cancel();
        return;
      }
      setState(() => _sessionRemaining = remaining);
    });
  }

  DateTime? _sessionEndsAt;

  String _activationErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.toLowerCase().contains('code expir')) {
      return 'Le serveur a refusé ce code car sa période de validité est terminée.\n\n'
          '$message\n\n'
          'La section reste fermée. Demandez à l’administrateur de générer un nouveau code lié à une affectation encore valide.';
    }
    return message;
  }

  Future<void> _loadCurrentSession() async {
    try {
      final response = await _service.getMySession();
      if (!mounted) return;
      _applySession(response);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sessionError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingSession = false);
      }
    }

    try {
      final assignments = await _service.getMyAssignments();
      if (!mounted) return;
      final relevantAssignments =
          assignments.where((assignment) {
            final status = assignment['statut']?.toString();
            return status == 'en_cours' || status == 'planifie';
          }).toList()..sort((left, right) {
            final leftStatus = left['statut']?.toString();
            final rightStatus = right['statut']?.toString();
            if (leftStatus == 'en_cours' && rightStatus != 'en_cours') {
              return -1;
            }
            if (rightStatus == 'en_cours' && leftStatus != 'en_cours') return 1;
            final leftStart = _assignmentMoment(
              left,
              'date_debut',
              'heure_debut',
            );
            final rightStart = _assignmentMoment(
              right,
              'date_debut',
              'heure_debut',
            );
            if (leftStart == null) return 1;
            if (rightStart == null) return -1;
            return leftStart.compareTo(rightStart);
          });
      final assignment = relevantAssignments.isEmpty
          ? null
          : relevantAssignments.first;
      _sessionAssignment = assignment;
      final start = assignment == null
          ? null
          : _assignmentMoment(assignment, 'date_debut', 'heure_debut');
      final end = assignment == null
          ? null
          : _assignmentMoment(assignment, 'date_fin', 'heure_fin');
      if (start == null || end == null) return;
      final duration = end.difference(start).inSeconds;
      if (duration <= 0) return;
      setState(() => _assignmentDurationSeconds = duration);
    } catch (error) {
      if (mounted && _sessionError == null) {
        setState(() {
          _sessionError =
              'Impossible de charger la durée de votre affectation : '
              '${error.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }

  DateTime? _assignmentMoment(
    Map<String, dynamic> assignment,
    String dateKey,
    String timeKey,
  ) {
    final rawDate = assignment[dateKey]?.toString();
    final rawTime = assignment[timeKey]?.toString();
    if (rawDate == null || rawTime == null || rawTime.length < 5) return null;
    final date = DateTime.tryParse(rawDate.substring(0, 10));
    final parts = rawTime.substring(0, 5).split(':');
    if (date == null || parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void _applySession(Map<String, dynamic> response) {
    final normalized = Map<String, dynamic>.from(response);
    final access = response['access'] is Map
        ? Map<String, dynamic>.from(response['access'] as Map)
        : <String, dynamic>{};
    final assignment = access['affectation'] is Map
        ? Map<String, dynamic>.from(access['affectation'] as Map)
        : _sessionAssignment ?? <String, dynamic>{};
    access['affectation'] = assignment;
    normalized['access'] = access;
    final session = AccessSession.fromJson(normalized);
    final remaining = session.remainingSecondsAt(DateTime.now());

    setState(() {
      _sessionEndsAt = session.endsAt;
      _sessionRemaining = remaining;
      _isSessionActive = session.isActive;
      _isLoadingSession = false;
      _sessionError = response['session_active'] == true && !session.isActive
          ? 'La session est expirée selon sa date de fin.'
          : response['session_active'] == true && session.endsAt == null
          ? 'Section ouverte, mais aucune date de fin n’est disponible pour le décompte.'
          : null;
      if (session.isActive) _showAccessCodeForm = false;
    });
    if (_isSessionActive && _sessionEndsAt != null) {
      _startSessionTimer();
    } else {
      _sessionTimer?.cancel();
    }
  }

  Future<void> _activate() async {
    final code = _accessCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir votre code d’accès.')),
      );
      return;
    }

    setState(() {
      _isActivating = true;
      _isLoadingSession = true;
      _sessionError = null;
    });
    try {
      final activation = await _service.activateAccessCode(code);
      if (!mounted) return;
      final access = activation['access'] is Map
          ? Map<String, dynamic>.from(activation['access'] as Map)
          : <String, dynamic>{};
      if (access['statut']?.toString() != 'actif') {
        throw Exception(
          activation['message']?.toString() ??
              'Le serveur n’a pas confirmé l’activation du code.',
        );
      }
      _applySession({'session_active': true, 'access': access});
      if (!_isSessionActive) {
        throw Exception(_sessionError ?? 'La session n’a pas pu être activée.');
      }
      if (!mounted) return;
      _accessCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Section activée.'),
          backgroundColor: _deepBlue,
        ),
      );
      if (widget.closeOnActivation) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      final message = _activationErrorMessage(error);
      setState(() {
        _isLoadingSession = false;
        _sessionError = message;
      });
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            message.startsWith('Le serveur a refusé')
                ? Icons.timer_off_rounded
                : Icons.error_outline_rounded,
            color: const Color(0xFFB42318),
          ),
          title: Text(
            message.startsWith('Le serveur a refusé')
                ? 'Code expiré'
                : 'Activation impossible',
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isActivating = false);
    }
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
                    child: PercepteurHeaderIconButton(
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
                    PercepteurSessionCard(
                      isActive: _isSessionActive,
                      isLoading: _isLoadingSession,
                      remainingLabel: _isLoadingSession
                          ? 'Vérification...'
                          : _isSessionActive
                          ? _sessionEndsAt == null
                                ? 'Durée indisponible'
                                : _formatDuration(_sessionRemaining)
                          : _assignmentDurationSeconds == null
                          ? 'Aucune affectation active'
                          : _formatDuration(_assignmentDurationSeconds!),
                      onRequestOpen: _isSessionActive
                          ? null
                          : () => setState(
                              () => _showAccessCodeForm = !_showAccessCodeForm,
                            ),
                    ),
                    if (_sessionError != null &&
                        (!_showAccessCodeForm || _isSessionActive)) ...[
                      const SizedBox(height: 10),
                      Text(
                        _sessionError!,
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (_showAccessCodeForm && !_isSessionActive) ...[
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
                            const Text(
                              'Code d’accès',
                              style: TextStyle(
                                color: _deepBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _accessCodeController,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _activate(),
                              decoration: InputDecoration(
                                hintText: 'Ex. FV-123456',
                                prefixIcon: const Icon(
                                  Icons.key_rounded,
                                  color: _fofanaGreen,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF6F8FF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _deepBlue.withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                            ),
                            if (_sessionError != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _sessionError!,
                                style: const TextStyle(
                                  color: Color(0xFFB42318),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _isActivating || _isSessionActive
                                    ? null
                                    : _activate,
                                icon: _isActivating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.lock_open_rounded),
                                label: Text(
                                  _isActivating
                                      ? 'Activation...'
                                      : _isSessionActive
                                      ? 'Session déjà ouverte'
                                      : 'Activer ma session',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _fofanaGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

class PercepteurSessionCard extends StatelessWidget {
  final bool isActive;
  final bool isLoading;
  final String remainingLabel;
  final VoidCallback? onRequestOpen;

  const PercepteurSessionCard({
    super.key,
    required this.isActive,
    required this.isLoading,
    required this.remainingLabel,
    required this.onRequestOpen,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    const green = Color(0xFF16A34A);
    final statusColor = isActive ? red : deepBlue;
    final statusLabel = isLoading
        ? 'Vérification'
        : isActive
        ? 'Ouverte'
        : 'Fermée';

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
          Text(
            isLoading
                ? 'Vérification de la session'
                : isActive
                ? 'Fermeture dans'
                : 'Durée prévue de la section',
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
              color: isActive || isLoading ? deepBlue : red,
              fontSize: remainingLabel.contains(':') ? 34 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (!isActive && !isLoading && onRequestOpen != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onRequestOpen,
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Demande ouverture de section'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
