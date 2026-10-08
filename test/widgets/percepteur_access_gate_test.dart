import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/screens/percepteur/parts/percepteur_access_gate.dart';
import 'package:fofanavoyage/services/affectation_service.dart';

class _SessionService extends AffectationService {
  final Map<String, dynamic> response;

  _SessionService(this.response);

  @override
  Future<Map<String, dynamic>> getMySession() async => response;
}

void main() {
  testWidgets('blocks percepteur operations without an active session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PercepteurAccessGate(
          service: _SessionService({'session_active': false}),
          child: const Text('Opérations protégées'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ouverture de session requise'), findsOneWidget);
    expect(find.text('Opérations protégées'), findsNothing);
  });

  testWidgets('shows percepteur operations with an active session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PercepteurAccessGate(
          service: _SessionService({'session_active': true}),
          child: const Text('Opérations protégées'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Opérations protégées'), findsOneWidget);
    expect(find.text('Ouverture de session requise'), findsNothing);
  });
}
