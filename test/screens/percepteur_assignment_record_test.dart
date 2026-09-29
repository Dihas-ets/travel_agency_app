import 'package:code_initial/screens/percepteur/parts/assignments_section.dart';
import 'package:code_initial/services/affectation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAffectationService extends AffectationService {
  _FakeAffectationService({this.expiredCode = false});

  final bool expiredCode;
  final _endsAt = DateTime.now().add(const Duration(hours: 2));

  String get _date =>
      '${_endsAt.year.toString().padLeft(4, '0')}-'
      '${_endsAt.month.toString().padLeft(2, '0')}-'
      '${_endsAt.day.toString().padLeft(2, '0')}';

  String get _time =>
      '${_endsAt.hour.toString().padLeft(2, '0')}:'
      '${_endsAt.minute.toString().padLeft(2, '0')}';

  @override
  Future<Map<String, dynamic>> getMySession() async => {
    'session_active': false,
  };

  @override
  Future<List<Map<String, dynamic>>> getMyAssignments() async => [
    {
      'id': 12,
      'statut': 'en_cours',
      'date_debut': '2026-09-29',
      'date_fin': '2026-09-29',
      'heure_debut': '08:00',
      'heure_fin': '23:59',
    },
  ];

  @override
  Future<Map<String, dynamic>> activateAccessCode(String code) async {
    expect(code, 'FV-123456');
    if (expiredCode) {
      throw Exception(
        'Code expiré le 29/09/2026 à 13:00:00. '
        'Heure actuelle serveur : 29/09/2026 à 17:11:23',
      );
    }
    return {
      'message': 'Session activée avec succès.',
      'access': {'statut': 'actif', 'date_fin': _date, 'heure_fin': _time},
    };
  }
}

void main() {
  test('distinguishes an active assignment from an opened access session', () {
    const assignment = {
      'id': 12,
      'statut': 'en_cours',
      'date_debut': '2026-09-29',
      'date_fin': '2026-09-29',
      'heure_debut': '08:00',
      'heure_fin': '12:00',
    };

    final awaitingCode = PercepteurAssignmentRecord.fromJson(assignment);
    final sessionOpen = PercepteurAssignmentRecord.fromJson(
      assignment,
      sessionOpen: true,
    );

    expect(awaitingCode.status, 'Code d’accès à saisir');
    expect(awaitingCode.sessionOpen, isFalse);
    expect(sessionOpen.status, 'Session ouverte');
    expect(sessionOpen.sessionOpen, isTrue);
  });

  test('keeps planned assignments scheduled until their start', () {
    final assignment = PercepteurAssignmentRecord.fromJson({
      'id': 13,
      'statut': 'planifie',
      'date_debut': '2026-10-01',
      'date_fin': '2026-10-01',
      'heure_debut': '08:00',
      'heure_fin': '12:00',
    });

    expect(assignment.status, 'Programmé');
  });

  testWidgets(
    'shows the open-section action before showing an active countdown',
    (tester) async {
      var requested = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PercepteurSessionCard(
              isActive: false,
              isLoading: false,
              remainingLabel: '05:00:00',
              onRequestOpen: () => requested = true,
            ),
          ),
        ),
      );

      expect(find.text('Durée prévue de la section'), findsOneWidget);
      expect(find.text('05:00:00'), findsOneWidget);
      expect(find.text('Demande ouverture de section'), findsOneWidget);

      await tester.tap(find.text('Demande ouverture de section'));
      expect(requested, isTrue);
    },
  );

  testWidgets('activates the session when the access code is submitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PercepteurConnectionPage(service: _FakeAffectationService()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Demande ouverture de section'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'fv-123456');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ouverte'), findsOneWidget);
    expect(find.text('Fermeture dans'), findsOneWidget);
  });

  testWidgets('explains when the backend refuses an expired access code', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PercepteurConnectionPage(
          service: _FakeAffectationService(expiredCode: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Demande ouverture de section'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'fv-123456');
    await tester.tap(find.text('Activer ma session'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Code expiré'), findsOneWidget);
    expect(find.textContaining('La section reste fermée.'), findsWidgets);
    expect(find.text('Fermée'), findsOneWidget);
  });
}
