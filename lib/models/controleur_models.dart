import 'package:flutter/material.dart';
import 'package:code_initial/services/staff_ticket_service.dart';

// Donnees memoire propres a l espace controleur.
// Elles restent separees du percepteur pour pouvoir brancher plus tard une API
// sans modifier les ecrans d'affectation, de connexion ou de validation.

class ControleurScannedTicket {
  final String code;
  final String passenger;
  final String route;
  final String departure;
  final String seat;
  final String scannedAt;
  final String status;

  const ControleurScannedTicket({
    required this.code,
    required this.passenger,
    required this.route,
    required this.departure,
    required this.seat,
    required this.scannedAt,
    required this.status,
  });

  factory ControleurScannedTicket.fromApi(StaffTicketModel ticket) {
    return ControleurScannedTicket(
      code: ticket.reference,
      passenger: ticket.fullPassengerName,
      route: ticket.route,
      departure: [ticket.dateVoyage, ticket.heureVoyage]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .join(' à '),
      seat: ticket.numPlace ?? '-',
      scannedAt: '-',
      status: ticket.statutLabel,
    );
  }
}

class ControleurScannedTicketStore {
  static final ValueNotifier<List<ControleurScannedTicket>> tickets =
      ValueNotifier<List<ControleurScannedTicket>>(<ControleurScannedTicket>[]);

  static void add(String rawCode) {
    final code = rawCode.trim();
    if (code.isEmpty) return;
    final now = DateTime.now();
    final scannedAt =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} à '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    tickets.value = [
      ControleurScannedTicket(
        code: code,
        passenger: '-',
        route: '-',
        departure: '-',
        seat: '-',
        scannedAt: scannedAt,
        status: 'En attente',
      ),
      ...tickets.value.where((ticket) => ticket.code != code),
    ];
  }

  static void addFromApi(StaffTicketModel ticket) {
    final scanned = ControleurScannedTicket.fromApi(ticket);
    tickets.value = [
      scanned,
      ...tickets.value.where((item) => item.code != scanned.code),
    ];
  }
}

class ControleurProfileData {
  final String fullName;
  final String phone;
  final String agency;
  final String role;

  const ControleurProfileData({
    required this.fullName,
    required this.phone,
    required this.agency,
    required this.role,
  });

  ControleurProfileData copyWith({
    String? fullName,
    String? phone,
    String? agency,
    String? role,
  }) {
    return ControleurProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      role: role ?? this.role,
    );
  }
}

class ControleurProfileStore {
  static final ValueNotifier<ControleurProfileData> profile =
      ValueNotifier<ControleurProfileData>(
        const ControleurProfileData(
          fullName: '',
          phone: '',
          agency: '',
          role: '',
        ),
      );

  static void update(ControleurProfileData data) {
    profile.value = data;
  }
}
