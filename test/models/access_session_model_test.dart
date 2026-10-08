import 'package:fofanavoyage/models/access_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 29, 16, 0);

  test(
    'parses the API access expiration and starts the remaining countdown',
    () {
      final session = AccessSession.fromJson({
        'session_active': true,
        'access': {
          'statut': 'actif',
          'date_fin': '2026-09-29T00:00:00.000000Z',
          'heure_fin': '18:30:00',
        },
      });

      expect(session.isActive, isTrue);
      expect(session.endsAt, DateTime(2026, 9, 29, 18, 30));
      expect(session.remainingSecondsAt(now), 9000);
    },
  );

  test('uses the linked assignment schedule when access times are absent', () {
    final session = AccessSession.fromJson({
      'session_active': true,
      'access': {
        'statut': 'actif',
        'affectation': {'date_fin': '2026-09-29', 'heure_fin': '17:15'},
      },
    });

    expect(session.isActive, isTrue);
    expect(session.remainingSecondsAt(now), 4500);
  });

  test('keeps a server-active session open when the end time is missing', () {
    final missingEnd = AccessSession.fromJson({
      'session_active': true,
      'access': {'statut': 'actif'},
    });

    expect(missingEnd.isActive, isTrue);
    expect(missingEnd.endsAt, isNull);
    expect(missingEnd.remainingSecondsAt(now), 0);
  });

  test('uses the backend session state when the device clock differs', () {
    final session = AccessSession.fromJson({
      'session_active': true,
      'access': {'date_fin': '2026-09-29', 'heure_fin': '15:59'},
    });

    expect(session.isActive, isTrue);
    expect(session.remainingSecondsAt(now), 0);
  });
}
