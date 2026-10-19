import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/models/colis_model.dart';

ColisModel parcelWithStatus(String status) => ColisModel.fromJson({
  'id': 42,
  'reference': 'CL-42',
  'statut': status,
  'statut_paiement': 'paye',
  'mode_paiement': 'ESPECES',
});

void main() {
  test('only unpaid draft parcels are classified as client initiations', () {
    final unpaidDraft = ColisModel.fromJson({
      'reference': 'CL-DRAFT',
      'statut': 'brouillon',
      'statut_paiement': 'en_attente_paiement',
    });

    expect(unpaidDraft.isClientInitiation, isTrue);
    expect(parcelWithStatus('a_expedier').isClientInitiation, isFalse);
    expect(parcelWithStatus('en_transit').isClientInitiation, isFalse);
  });

  test('moves a paid draft parcel out of client initiations', () {
    final paidDraft = parcelWithStatus('brouillon');
    final record = paidDraft.toParcelRecord();

    expect(paidDraft.isClientInitiation, isFalse);
    expect(record.isClientInitiation, isFalse);
    expect(record.readableStatus, 'Payé - à finaliser');
  });

  test('client cancellation is available only before physical departure', () {
    final readyToShip = parcelWithStatus('a_expedier').toParcelRecord();
    final inTransit = parcelWithStatus('en_transit').toParcelRecord();

    expect(readyToShip.parcelId, 42);
    expect(readyToShip.canClientCancel, isTrue);
    expect(inTransit.canClientCancel, isFalse);
  });
}
