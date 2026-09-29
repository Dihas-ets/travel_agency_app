import 'package:flutter_test/flutter_test.dart';
import 'package:code_initial/screens/percepteur/parts/reservation_flow.dart';

void main() {
  test(
    'maps an emitted ticket with API relations into the history card model',
    () {
      final ticket = PercepteurReservationRecord.fromTicket({
        'reference': 'FV-TKT-123',
        'date_voyage': '2026-09-30',
        'heure_voyage': '08:30:00',
        'nbre_place': 2,
        'nom_passager': 'KOFFI',
        'prenom_passager': 'Awa',
        'numero_passager': '+22901020304',
        'tarif_total': '15000',
        'statut': 'en_cours',
        'ligne': {'trajet_depart': 'Cotonou', 'trajet_arrivee': 'Parakou'},
        'bus': {'immatriculation': 'BJ-1234-AA'},
      });

      expect(ticket.reference, 'FV-TKT-123');
      expect(ticket.departure, 'Cotonou');
      expect(ticket.destination, 'Parakou');
      expect(ticket.time, '08:30:00');
      expect(ticket.passengerCount, 2);
      expect(ticket.passengerName, 'Awa KOFFI');
      expect(ticket.phone, '+22901020304');
      expect(ticket.price, '15000 CFA');
      expect(ticket.busMatricule, 'BJ-1234-AA');
      expect(ticket.status, 'Émis');
      expect(ticket.rawStatus, 'en_cours');
    },
  );

  test('maps attendance statuses to the corresponding history label', () {
    final present = PercepteurReservationRecord.fromTicket({
      'statut': 'utilisé',
    });
    final absent = PercepteurReservationRecord.fromTicket({'statut': 'absent'});

    expect(present.status, 'Présent');
    expect(absent.status, 'Absent');
  });
}
