import 'package:code_initial/models/ligne_model.dart';
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
}
