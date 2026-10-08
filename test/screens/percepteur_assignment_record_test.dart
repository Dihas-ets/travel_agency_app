import 'package:fofanavoyage/screens/percepteur/parts/assignments_section.dart';
import 'package:fofanavoyage/services/affectation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAffectationService extends AffectationService {
  _FakeAffectationService({
    this.expiredCode = false,
    this.sessionAlreadyActive = false,
    this.activateUsedCodeConflict = false,
  });

  final bool expiredCode;
  final bool sessionAlreadyActive;
  final bool activateUsedCodeConflict;
  final _endsAt = DateTime.now().add(const Duration(hours: 2));
  int _sessionChecks = 0;

  String get _date =>
      '${_endsAt.year.toString().padLeft(4, '0')}-'
      '${_endsAt.month.toString().padLeft(2, '0')}-'
      '${_endsAt.day.toString().padLeft(2, '0')}';

  String get _time =>
      '${_endsAt.hour.toString().padLeft(2, '0')}:'
      '${_endsAt.minute.toString().padLeft(2, '0')}';

  @override
  Future<Map<String, dynamic>> getMySession() async {
    _sessionChecks++;
    final isActive =
        sessionAlreadyActive ||
        (activateUsedCodeConflict && _sessionChecks > 2);
    return {
      'session_active': isActive,
      if (isActive)
        'access': {'statut': 'actif', 'date_fin': _date, 'heure_fin': _time},
    };
  }

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
    if (activateUsedCodeConflict) {
      throw Exception('Code incorrect ou déjà utilisé.');
    }
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

  test('preserves the API calendar date for an in-progress assignment', () {
    final assignment = PercepteurAssignmentRecord.fromJson({
      'id': 14,
      'statut': 'en_cours',
      'date_debut': '2026-10-01T00:00:00+02:00',
      'date_fin': '2026-10-01',
      'heure_debut': '08:00',
      'heure_fin': '12:00',
    });

    expect(assignment.date, '1 octobre 2026');
    expect(assignment.endDate, '1 octobre 2026');
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
    final countdownFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(widget.data ?? ''),
    );
    final countdownBefore = tester.widget<Text>(countdownFinder).data;
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<Text>(countdownFinder).data, isNot(countdownBefore));
  });

  testWidgets(
    'uses an already active server session without re-entering code',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PercepteurConnectionPage(
            service: _FakeAffectationService(sessionAlreadyActive: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ouverte'), findsOneWidget);
      expect(find.text('Activer ma session'), findsNothing);
    },
  );

  testWidgets(
    'recovers the active session when the code was just used elsewhere',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PercepteurConnectionPage(
            service: _FakeAffectationService(activateUsedCodeConflict: true),
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
      await tester.pumpAndSettle();

      expect(find.text('Ouverte'), findsOneWidget);
      expect(find.text('Activation impossible'), findsNothing);
    },
  );

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
