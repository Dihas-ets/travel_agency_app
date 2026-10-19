import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/screens/client/colis/parcel_sender_defaults.dart';

void main() {
  test(
    'does not prefill staff parcel sender fields from the staff profile',
    () {
      final defaults = ParcelSenderDefaults.fromProfile(
        isPercepteur: true,
        fullName: 'Percepteur Nom',
        phone: '+22901020304',
      );

      expect(defaults.name, isEmpty);
      expect(defaults.phone, isEmpty);
    },
  );

  test('keeps profile defaults for client parcel forms', () {
    final defaults = ParcelSenderDefaults.fromProfile(
      isPercepteur: false,
      fullName: 'Client Nom',
      phone: '+22905060708',
    );

    expect(defaults.name, 'Client Nom');
    expect(defaults.phone, '+22905060708');
  });
}
