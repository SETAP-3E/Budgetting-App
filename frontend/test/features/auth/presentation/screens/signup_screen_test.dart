import 'package:budgetting_frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSignup() => const MaterialApp(home: SignupScreen());

  group('SignupScreen', () {
    testWidgets('renders signup form fields and actions', (tester) async {
      await tester.pumpWidget(buildSignup());

      expect(find.text('Create account'), findsNWidgets(2));
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
      expect(find.text('Already have an account? Log in'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty form', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(find.text('Required'), findsNWidgets(2));
    });

    testWidgets('shows password validation messages when values are invalid',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'ab');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '1234567');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), 'different');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(find.text('Must be at least 3 characters'), findsOneWidget);
      expect(find.text('Must be at least 8 characters'), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('confirm password field is obscured', (tester) async {
      await tester.pumpWidget(buildSignup());
      final confirmEditable = tester.widget<EditableText>(
        find.byType(EditableText).at(2),
      );

      expect(confirmEditable.obscureText, isTrue);
    });
  });
}
