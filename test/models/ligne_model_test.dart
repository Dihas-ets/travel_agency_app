import 'package:fofanavoyage/models/ligne_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses intermediate destinations and matches them case-insensitively',
    () {
      final line = Ligne.fromJson({
        'id': 1,
        'trajet_depart': 'Cotonou',
        'trajet_arrivee': 'Parakou',
        'villes_etapes': [
          {'nom': 'Bohicon', 'tarif': 5000},
        ],
      });

      expect(line.servesDestination('Parakou'), isTrue);
      expect(line.servesDestination(' bohicon '), isTrue);
      expect(line.servesDestination('Dassa'), isFalse);
    },
  );

  test('parses intermediate destinations returned as strings', () {
    final line = Ligne.fromJson({
      'id': 2,
      'trajet_depart': 'Cotonou',
      'trajet_arrivee': 'Parakou',
      'villes_etapes': ['Bohicon', 'Dassa'],
    });

    expect(line.servesDestination('Dassa'), isTrue);
  });
}
