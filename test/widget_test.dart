// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_events/app/sign_in/sign_in_button.dart';

void main() {
  testWidgets('SignInButton renders provided text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignInButton(
            text: 'Без регистрации',
            color: Colors.green,
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Без регистрации'), findsOneWidget);
  });
}
