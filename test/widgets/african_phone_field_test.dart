import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:code_initial/screens/global/widgets/common/african_phone_field.dart';

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
}
