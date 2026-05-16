import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountsApiClient extends Mock implements AccountsApiClient {}

AccountModel _stubAccount({
  String name = 'My Account',
  AccountType type = AccountType.current,
}) =>
    AccountModel(
      id: 'test-uuid',
      name: name,
      type: type,
      balance: 500,
      monthlyBudget: 300,
      monthlySpent: 0,
      weeklySpent: 0,
      accentColor: kAccountAccentColours.first,
    );

Widget buildWidget({MockAccountsApiClient? apiClient}) => MaterialApp(
      home: Scaffold(
        body: AddAccountSheet(
          apiClientOverride: apiClient,
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
  setUpAll(() {
    registerFallbackValue(AccountType.current);
    registerFallbackValue(const Color(0xFF000000));
  });

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

    testWidgets('posts to API and shows snackbar when form is valid',
        (tester) async {
      final mockClient = MockAccountsApiClient();
      when(
        () => mockClient.createAccount(
          name: any(named: 'name'),
          type: any(named: 'type'),
          balance: any(named: 'balance'),
          monthlyBudget: any(named: 'monthlyBudget'),
          accentColor: any(named: 'accentColor'),
        ),
      ).thenAnswer(
        (_) async => _stubAccount(
          name: 'Holiday Fund',
          type: AccountType.savings,
        ),
      );

      await tester.pumpWidget(buildWidget(apiClient: mockClient));

      await _fillForm(
        tester,
        name: 'Holiday Fund',
        balance: '1000',
        budget: '200',
        type: AccountType.savings,
      );
      await tester.tap(find.text('Save Account'));
      await tester.pump(); // start async save
      await tester.pump(); // complete future

      verify(
        () => mockClient.createAccount(
          name: 'Holiday Fund',
          type: AccountType.savings,
          balance: 1000,
          monthlyBudget: 200,
          accentColor: any(named: 'accentColor'),
        ),
      ).called(1);
    });

    testWidgets('does not call API when form is invalid', (tester) async {
      final mockClient = MockAccountsApiClient();
      await tester.pumpWidget(buildWidget(apiClient: mockClient));
      await tester.tap(find.text('Save Account'));
      await tester.pump();
      verifyNever(
        () => mockClient.createAccount(
          name: any(named: 'name'),
          type: any(named: 'type'),
          balance: any(named: 'balance'),
          monthlyBudget: any(named: 'monthlyBudget'),
          accentColor: any(named: 'accentColor'),
        ),
      );
    });
  });
}
