import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/screens/global/widgets/common/african_phone_field.dart';

void main() {
  testWidgets('separates a saved country code from the editable number', (
    tester,
  ) async {
    final controller = TextEditingController(text: '+22997000000');
    String? fullNumber;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfricanPhoneField(
            controller: controller,
            onFullNumberChanged: (value) => fullNumber = value,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(controller.text, '97000000');
    expect(find.text('+229'), findsOneWidget);
    expect(fullNumber, '+22997000000');

    controller.dispose();
  });

  testWidgets(
    'accepts a pasted international number and keeps its country code',
    (tester) async {
      final controller = TextEditingController();
      String? fullNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AfricanPhoneField(
              controller: controller,
              onFullNumberChanged: (value) => fullNumber = value,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField), '+44 20 7123 4567');
      await tester.pump();

      expect(find.text('+44'), findsOneWidget);
      expect(controller.text, '2071234567');
      expect(fullNumber, '+442071234567');

      controller.dispose();
    },
  );

  testWidgets('preserves international prefixes outside the country list', (
    tester,
  ) async {
    final controller = TextEditingController();
    String? fullNumber;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfricanPhoneField(
            controller: controller,
            onFullNumberChanged: (value) => fullNumber = value,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), '+81 3 1234 5678');
    await tester.pump();

    expect(controller.text, '+81 3 1234 5678');
    expect(fullNumber, '+81312345678');

    controller.dispose();
  });
}
