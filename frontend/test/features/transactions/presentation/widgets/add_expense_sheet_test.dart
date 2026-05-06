import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/add_expense_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pumps the widget and drains the pending Dio timer from initState's
// getCategories call (which never completes without a running server).
Future<void> _pumpWidget(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: AddExpenseSheet())),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

// Opens the account dropdown without settling (avoids Dio timer interference).
Future<void> _openAccountDropdown(WidgetTester tester) async {
  await tester.tap(
    find.widgetWithText(DropdownButtonFormField<String>, 'Account'),
  );
  await tester.pump(); // start dropdown open animation
  await tester.pump(const Duration(milliseconds: 200)); // let it complete
}

void main() {
  group('AddExpenseSheet — account selector', () {
    testWidgets('renders Account dropdown', (tester) async {
      await _pumpWidget(tester);
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Account'),
        findsOneWidget,
      );
    });

    testWidgets('dropdown contains all four mock accounts', (tester) async {
      await _pumpWidget(tester);
      await _openAccountDropdown(tester);

      expect(find.text('Main Current Account'), findsOneWidget);
      expect(find.text('Savings Pot'), findsOneWidget);
      expect(find.text('Joint Bills Account'), findsOneWidget);
      expect(find.text('Trip Savings'), findsOneWidget);
    });

    testWidgets('dropdown items show account type icons', (tester) async {
      await _pumpWidget(tester);
      await _openAccountDropdown(tester);

      expect(find.byIcon(AccountType.current.icon), findsWidgets);
      expect(find.byIcon(AccountType.savings.icon), findsWidgets);
      expect(find.byIcon(AccountType.joint.icon), findsWidgets);
    });

    testWidgets('shows validation error when no account selected',
        (tester) async {
      await _pumpWidget(tester);

      // Trigger form validation directly — avoids relying on the save button,
      // which is disabled while categories are loading from the API.
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pump();

      expect(find.text('Please select an account'), findsOneWidget);
    });

    testWidgets('selecting an account clears the validation error',
        (tester) async {
      await _pumpWidget(tester);

      // First trigger the error
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pump();
      expect(find.text('Please select an account'), findsOneWidget);

      // Select an account
      await _openAccountDropdown(tester);
      await tester.tap(find.text('Savings Pot').last);
      await tester.pump();

      expect(find.text('Please select an account'), findsNothing);
    });
  });
}
