part of '../collector/collector_home_page.dart';

// Donnees memoire propres a l espace controleur.
// Elles restent separees du percepteur pour pouvoir brancher plus tard une API
// sans modifier les ecrans d'affectation, de connexion ou de validation.

class _ControllerScannedTicket {
  final String code;
  final String passenger;
  final String route;
  final String departure;
  final String seat;
  final String scannedAt;
  final String status;

  const _ControllerScannedTicket({
    required this.code,
    required this.passenger,
    required this.route,
    required this.departure,
    required this.seat,
    required this.scannedAt,
    required this.status,
  });
}

class _ControllerScannedTicketStore {
  static final ValueNotifier<List<_ControllerScannedTicket>> tickets =
      ValueNotifier<List<_ControllerScannedTicket>>(
        <_ControllerScannedTicket>[],
      );

  static void add(String rawCode) {
    final code = rawCode.trim().isEmpty ? 'TK-2026-0487' : rawCode.trim();
    final now = DateTime.now();
    final scannedAt =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} à '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    tickets.value = [
      _ControllerScannedTicket(
        code: code,
        passenger: 'Client Fofana',
        route: 'Cotonou -> Parakou',
        departure: '21/05/2026 à 08:30',
        seat: '12A',
        scannedAt: scannedAt,
        status: 'Ticket valide',
      ),
      ...tickets.value.where((ticket) => ticket.code != code),
    ];
  }
}

class _ControllerProfileData {
  final String fullName;
  final String phone;
  final String agency;
  final String role;

  const _ControllerProfileData({
    required this.fullName,
    required this.phone,
    required this.agency,
    required this.role,
  });

  _ControllerProfileData copyWith({
    String? fullName,
    String? phone,
    String? agency,
    String? role,
  }) {
    return _ControllerProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      role: role ?? this.role,
    );
  }
}

class _ControllerProfileStore {
  static final ValueNotifier<_ControllerProfileData> profile =
      ValueNotifier<_ControllerProfileData>(
        const _ControllerProfileData(
          fullName: 'Controleur Fofana',
          phone: '+229 01 00 00 00 00',
          agency: 'Cotonou',
          role: 'Controleur voyage',
        ),
      );

  static void update(_ControllerProfileData data) {
    profile.value = data;
  }
}
