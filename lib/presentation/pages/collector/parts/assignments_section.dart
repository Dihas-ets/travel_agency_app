import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:code_initial/models/models_and_stores.dart';
import 'package:code_initial/presentation/pages/collector/parts/notifications_section.dart';
// Missions percepteur: filtres, listes, detail, itineraire et connexion.

// Widget stub pour CollectorParcelStatusPill
class CollectorParcelStatusPill extends StatelessWidget {
  final String label;
  final bool strong;

  const CollectorParcelStatusPill({super.key, required this.label, required this.strong});

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

enum CollectorAssignmentFilter { current, scheduled, past }

enum CollectorAssignmentPastStatusFilter { all, completed, reassigned, absent }

extension on CollectorAssignmentPastStatusFilter {
  String get label {
    switch (this) {
      case CollectorAssignmentPastStatusFilter.all:
        return 'Tous';
      case CollectorAssignmentPastStatusFilter.completed:
        return 'Effectué';
      case CollectorAssignmentPastStatusFilter.reassigned:
        return 'Réaffecter';
      case CollectorAssignmentPastStatusFilter.absent:
        return 'Absent';
    }
  }

  bool matches(String status) {
    switch (this) {
      case CollectorAssignmentPastStatusFilter.all:
        return true;
      case CollectorAssignmentPastStatusFilter.completed:
        return status == 'Effectué';
      case CollectorAssignmentPastStatusFilter.reassigned:
        return status == 'Réaffecter';
      case CollectorAssignmentPastStatusFilter.absent:
        return status == 'Absent';
    }
  }
}

class CollectorAssignmentCollector {
  final String name;
  final String phone;

  const CollectorAssignmentCollector({
    required this.name,
    required this.phone,
  });
}

class CollectorAssignmentRecord {
  final String date;
  final String time;
  final String busMatricule;
  final String driverName;
  final String driverPhone;
  final String route;
  final String sessionCloseTime;
  final List<CollectorAssignmentCollector> collectors;
  final String status;

  const CollectorAssignmentRecord({
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

class CollectorAssignmentsPage extends StatefulWidget {
  const CollectorAssignmentsPage({super.key});

  @override
  State<CollectorAssignmentsPage> createState() =>
      CollectorAssignmentsPageState();
}

class CollectorAssignmentsPageState extends State<CollectorAssignmentsPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  CollectorAssignmentFilter _filter = CollectorAssignmentFilter.current;
  CollectorAssignmentPastStatusFilter _pastStatusFilter =
      CollectorAssignmentPastStatusFilter.all;

  // Jeu de données local en attendant la connexion à l'API des affectations.
  final List<CollectorAssignmentRecord> _currentAssignments = const [
    CollectorAssignmentRecord(
      date: '29 mai 2026',
      time: '08:30',
      busMatricule: 'BJ-6248-RB',
      driverName: 'Karim Soglo',
      driverPhone: '+229 01 66 42 18 09',
      route: 'Cotonou -> Parakou',
      sessionCloseTime: '18:45',
      collectors: [
        CollectorAssignmentCollector(
          name: 'Awa Mensah',
          phone: '+229 01 64 20 11 90',
        ),
        CollectorAssignmentCollector(
          name: 'Joel Kpadonou',
          phone: '+229 01 97 44 08 26',
        ),
      ],
      status: 'Session ouverte',
    ),
  ];

  final List<CollectorAssignmentRecord> _scheduledAssignments = const [
    CollectorAssignmentRecord(
      date: '31 mai 2026',
      time: '06:00',
      busMatricule: 'BJ-7812-AG',
      driverName: 'Moussa Adjou',
      driverPhone: '+229 01 97 12 44 30',
      route: 'Porto-Novo -> Natitingou',
      sessionCloseTime: '17:30',
      collectors: [
        CollectorAssignmentCollector(
          name: 'Chancelle Toko',
          phone: '+229 01 62 19 31 45',
        ),
        CollectorAssignmentCollector(
          name: 'Eric Houngbo',
          phone: '+229 01 69 88 14 77',
        ),
      ],
      status: 'Programmé',
    ),
    CollectorAssignmentRecord(
      date: '02 juin 2026',
      time: '14:15',
      busMatricule: 'BJ-4589-CD',
      driverName: 'Jean Dossou',
      driverPhone: '+229 01 62 55 70 21',
      route: 'Cotonou -> Djougou',
      sessionCloseTime: '23:00',
      collectors: [
        CollectorAssignmentCollector(
          name: 'Mariette Hounkanrin',
          phone: '+229 01 60 75 29 10',
        ),
        CollectorAssignmentCollector(
          name: 'Serge Loko',
          phone: '+229 01 66 13 57 84',
        ),
      ],
      status: 'Programmé',
    ),
  ];

  final List<CollectorAssignmentRecord> _pastAssignments = const [
    CollectorAssignmentRecord(
      date: '27 mai 2026',
      time: '07:45',
      busMatricule: 'BJ-3220-TR',
      driverName: 'Rachid Bio',
      driverPhone: '+229 01 61 18 40 33',
      route: 'Cotonou -> Bohicon',
      sessionCloseTime: '16:20',
      collectors: [
        CollectorAssignmentCollector(
          name: 'Mireille Zinsou',
          phone: '+229 01 65 42 71 88',
        ),
        CollectorAssignmentCollector(
          name: 'Patrick Tossa',
          phone: '+229 01 91 06 24 35',
        ),
      ],
      status: 'Effectué',
    ),
    CollectorAssignmentRecord(
      date: '25 mai 2026',
      time: '09:00',
      busMatricule: 'BJ-9301-PL',
      driverName: 'Armand Hounsinou',
      driverPhone: '+229 01 95 72 10 67',
      route: 'Porto-Novo -> Kandi',
      sessionCloseTime: '20:10',
      collectors: [
        CollectorAssignmentCollector(
          name: 'Nadine Sossa',
          phone: '+229 01 68 77 31 04',
        ),
        CollectorAssignmentCollector(
          name: 'Abel Gandonou',
          phone: '+229 01 94 50 63 19',
        ),
      ],
      status: 'Réaffecter',
    ),
    CollectorAssignmentRecord(
      date: '22 mai 2026',
      time: '12:30',
      busMatricule: 'BJ-1077-MK',
      driverName: 'Saturnin Kiki',
      driverPhone: '+229 01 60 30 41 82',
      route: 'Cotonou -> Lokossa',
      sessionCloseTime: '19:00',
      collectors: [
        CollectorAssignmentCollector(
          name: 'Judith Ahouanvoebla',
          phone: '+229 01 61 33 42 50',
        ),
        CollectorAssignmentCollector(
          name: 'David Nonvignon',
          phone: '+229 01 96 82 18 73',
        ),
      ],
      status: 'Absent',
    ),
  ];

  List<CollectorAssignmentRecord> get _records {
    switch (_filter) {
      case CollectorAssignmentFilter.current:
        return _currentAssignments;
      case CollectorAssignmentFilter.scheduled:
        return _scheduledAssignments;
      case CollectorAssignmentFilter.past:
        return _pastAssignments
            .where((assignment) => _pastStatusFilter.matches(assignment.status))
            .toList();
    }
  }

  String get _title {
    switch (_filter) {
      case CollectorAssignmentFilter.current:
        return 'Affectation en cours';
      case CollectorAssignmentFilter.scheduled:
        return 'Affectations programmées';
      case CollectorAssignmentFilter.past:
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

  void _selectFilter(CollectorAssignmentFilter value) {
    setState(() {
      _filter = value;
      if (_filter != CollectorAssignmentFilter.past) {
        _pastStatusFilter = CollectorAssignmentPastStatusFilter.all;
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
                      CollectorHeaderIconButton(
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
                  CollectorAssignmentSegmentedControl(
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
                          if (_filter == CollectorAssignmentFilter.current) {
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
                                      CollectorParcelStatusPill(
                                        label: item.status,
                                        strong: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  CollectorAssignmentRoutePanel(
                                    route: item.route,
                                  ),
                                  const SizedBox(height: 12),
                                  CollectorAssignmentInfoGrid(
                                    children: [
                                      CollectorAssignmentInfo(
                                        icon: Icons.person_rounded,
                                        label: 'Chauffeur',
                                        value: item.driverName,
                                      ),
                                      CollectorAssignmentInfo(
                                        icon: Icons.phone_rounded,
                                        label: 'Téléphone chauffeur',
                                        value: item.driverPhone,
                                      ),
                                      CollectorAssignmentInfo(
                                        icon: Icons.lock_clock_rounded,
                                        label: 'Fin session',
                                        value: item.sessionCloseTime,
                                      ),
                                      CollectorAssignmentInfo(
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
                                      CollectorAssignmentDetailPage(
                                        assignment: item,
                                        mode: _filter,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList()),
                  if (_filter == CollectorAssignmentFilter.past) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: CollectorAssignmentPastStatusFilter.values
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

class CollectorAssignmentSegmentedControl extends StatelessWidget {
  final CollectorAssignmentFilter selected;
  final ValueChanged<CollectorAssignmentFilter> onChanged;

  const CollectorAssignmentSegmentedControl({super.key, 
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
          CollectorAssignmentTabButton(
            label: 'En cours',
            icon: Icons.play_circle_fill_rounded,
            selected: selected == CollectorAssignmentFilter.current,
            onTap: () => onChanged(CollectorAssignmentFilter.current),
          ),
          CollectorAssignmentTabButton(
            label: 'Programmer',
            icon: Icons.event_available_rounded,
            selected: selected == CollectorAssignmentFilter.scheduled,
            onTap: () => onChanged(CollectorAssignmentFilter.scheduled),
          ),
          CollectorAssignmentTabButton(
            label: 'Passer',
            icon: Icons.history_rounded,
            selected: selected == CollectorAssignmentFilter.past,
            onTap: () => onChanged(CollectorAssignmentFilter.past),
          ),
        ],
      ),
    );
  }
}

class CollectorAssignmentTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CollectorAssignmentTabButton({super.key, 
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

class CollectorAssignmentDetailPage extends StatelessWidget {
  final CollectorAssignmentRecord assignment;
  final CollectorAssignmentFilter mode;

  const CollectorAssignmentDetailPage({super.key, 
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
                  CollectorAssignmentRoutePanel(route: assignment.route),
                  const SizedBox(height: 18),
                  CollectorAssignmentInfoGrid(
                    children: [
                      CollectorAssignmentInfo(
                        icon: Icons.person_rounded,
                        label: 'Chauffeur',
                        value: assignment.driverName,
                      ),
                      CollectorAssignmentInfo(
                        icon: Icons.phone_rounded,
                        label: 'Téléphone chauffeur',
                        value: assignment.driverPhone,
                      ),
                      CollectorAssignmentInfo(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Matricule bus',
                        value: assignment.busMatricule,
                      ),
                      CollectorAssignmentInfo(
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
                                CollectorPhoneSheet(collector: collector),
                          );
                        },
                      ),
                    ),
                  ),
                  if (mode == CollectorAssignmentFilter.current) ...[
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

class CollectorAssignmentRoutePanel extends StatefulWidget {
  final String route;

  const CollectorAssignmentRoutePanel({super.key, required this.route});

  @override
  State<CollectorAssignmentRoutePanel> createState() =>
      CollectorAssignmentRoutePanelState();
}

class CollectorAssignmentRoutePanelState
    extends State<CollectorAssignmentRoutePanel> {
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

class CollectorAssignmentInfoGrid extends StatelessWidget {
  final List<CollectorAssignmentInfo> children;

  const CollectorAssignmentInfoGrid({super.key, required this.children});

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

class CollectorAssignmentInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const CollectorAssignmentInfo({super.key, 
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

class CollectorPhoneSheet extends StatelessWidget {
  final CollectorAssignmentCollector collector;

  const CollectorPhoneSheet({super.key, required this.collector});

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

class CollectorConnectionPage extends StatefulWidget {
  const CollectorConnectionPage({super.key});

  @override
  State<CollectorConnectionPage> createState() =>
      CollectorConnectionPageState();
}

class CollectorConnectionPageState extends State<CollectorConnectionPage> {
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
    CollectorNotificationStore.add(
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
    CollectorNotificationStore.add(
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
                    child: CollectorHeaderIconButton(
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
                    CollectorSessionCard(
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
                                      child: CollectorOtpBox(
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

class CollectorSessionCard extends StatelessWidget {
  final bool isActive;
  final String remainingLabel;

  const CollectorSessionCard({super.key, 
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

class CollectorOtpBox extends StatelessWidget {
  final TextEditingController controller;

  const CollectorOtpBox({super.key, required this.controller});

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


