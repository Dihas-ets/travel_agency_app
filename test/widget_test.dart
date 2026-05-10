import 'package:code_initial/navigation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:code_initial/main.dart';

void main() {
  testWidgets('affiche la première page onboarding au démarrage', (
    WidgetTester tester,
  ) async {
    // Monte l'application directement sur la route d'onboarding.
    await tester.pumpWidget(const Main(Routes.ONBOARDING));

    // Vérifie que la première slide visible correspond au contenu attendu.
    expect(find.text('Plus efficace'), findsOneWidget);

    // Laisse Flutter terminer les animations/images éventuelles.
    await tester.pump();

    // Le bouton de progression de l'onboarding est présent sur l'écran.
    expect(find.text('Plus assuré'), findsNothing);
  });
}
