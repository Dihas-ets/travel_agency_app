import 'package:code_initial/models/voyage_programme_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the selected bus, route, departure times, and fare', () {
    final voyage = VoyageProgramme.fromJson({
      'id': 18,
      'heures_depart': ['08:00', '13:30'],
      'bus': {
        'id': 4,
        'type': 'vip',
        'capacite': 32,
        'immatriculation': 'BJ-1234-AA',
        'nom_identite': 'Bus VIP',
      },
      'ligne': {
        'trajet_depart': 'Cotonou',
        'trajet_arrivee': 'Parakou',
        'montant': 7000,
        'montant_vip': 10000,
      },
    });

    expect(voyage.id, 18);
    expect(voyage.busId, 4);
    expect(voyage.busType, 'vip');
    expect(voyage.busCapacite, 32);
    expect(voyage.busName, 'Bus VIP');
    expect(voyage.busMatricule, 'BJ-1234-AA');
    expect(voyage.heuresDepart, ['08:00', '13:30']);
    expect(voyage.ligneDepart, 'Cotonou');
    expect(voyage.ligneArrivee, 'Parakou');
    expect(voyage.montant, 7000);
    expect(voyage.montantVip, 10000);
  });
}
