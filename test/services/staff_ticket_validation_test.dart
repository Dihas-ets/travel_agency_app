import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/services/staff_ticket_service.dart';

void main() {
  test('maps a paid in-progress API ticket as eligible for boarding', () {
    final ticket = StaffTicketModel.fromJson({
      'id': 42,
      'reference': 'FV-TKT-20261015-AB12',
      'statut': 'en_cours',
      'statut_paiement': 'payé',
    });

    expect(ticket.id, 42);
    expect(ticket.reference, 'FV-TKT-20261015-AB12');
    expect(ticket.canValidateBoarding, isTrue);
  });

  test('does not allow boarding before payment is confirmed', () {
    final ticket = StaffTicketModel.fromJson({
      'id': 42,
      'reference': 'FV-TKT-20261015-AB12',
      'statut': 'en_cours',
      'statut_paiement': 'en_attente_paiement',
    });

    expect(ticket.canValidateBoarding, isFalse);
  });
}
