import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildWidget({void Function(AccountModel)? onAccountAdded}) =>
    MaterialApp(
      home: Scaffold(
        body: AddAccountSheet(
          onAccountAdded: onAccountAdded ?? (_) {},
        ),
      ),
    );

Future<void> _fillForm(
  WidgetTester tester, {
  String name = 'My Account',
  String balance = '500',
  String budget = '300',
  AccountType type = AccountType.current,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Account Name'),
    name,
  );
  await tester.tap(
    find.widgetWithText(
      DropdownButtonFormField<AccountType>,
      'Account Type',
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(type.label).last);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Opening Balance'),
    balance,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Monthly Budget'),
    budget,
  );
}

void main() {
  group('AddAccountSheet', () {
    testWidgets('renders Account Name field', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.widgetWithText(TextFormField, 'Account Name'),
        findsOneWidget,
      );
    });

    testWidgets('renders Account Type dropdown', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.widgetWithText(
          DropdownButtonFormField<AccountType>,
          'Account Type',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Opening Balance field', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.widgetWithText(TextFormField, 'Opening Balance'),
        findsOneWidget,
      );
    });

    testWidgets('renders Monthly Budget field', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.widgetWithText(TextFormField, 'Monthly Budget'),
        findsOneWidget,
      );
    });

    testWidgets('renders Save Account button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Save Account'), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Save Account'));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('shows validation error when balance is empty', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account Name'),
        'Test',
      );
      await tester.tap(find.text('Save Account'));
      await tester.pump();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('calls onAccountAdded with correct model when form is valid',
        (tester) async {
      AccountModel? received;
      await tester.pumpWidget(buildWidget(onAccountAdded: (a) => received = a));

      await _fillForm(
        tester,
        name: 'Holiday Fund',
        balance: '1000',
        budget: '200',
        type: AccountType.savings,
      );
      await tester.tap(find.text('Save Account'));
      await tester.pump();

      expect(received, isNotNull);
      expect(received!.name, 'Holiday Fund');
      expect(received!.type, AccountType.savings);
      expect(received!.balance, 1000);
      expect(received!.monthlyBudget, 200);
      expect(received!.monthlySpent, 0);
    });

    testWidgets('does not call onAccountAdded when form is invalid',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildWidget(onAccountAdded: (_) => called = true),
      );
      await tester.tap(find.text('Save Account'));
      await tester.pump();
      expect(called, isFalse);
    });
  });
}
