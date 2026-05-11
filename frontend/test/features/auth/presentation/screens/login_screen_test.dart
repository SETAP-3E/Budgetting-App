import 'package:budgetting_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildLogin() => const MaterialApp(home: LoginScreen());

  group('LoginScreen', () {
    testWidgets('renders login form fields and actions', (tester) async {
      await tester.pumpWidget(buildLogin());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty form', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.text('Required'), findsNWidgets(2));
    });

    testWidgets('password field is obscured', (tester) async {
      await tester.pumpWidget(buildLogin());
      final passwordEditable = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );

      expect(passwordEditable.obscureText, isTrue);
    });
  });
}
