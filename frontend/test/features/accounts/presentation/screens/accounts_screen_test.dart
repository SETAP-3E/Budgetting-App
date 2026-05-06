import 'dart:async';

import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountsApiClient extends Mock implements AccountsApiClient {}

final _accounts = [
  const AccountModel(
    id: '00000000-0000-0000-0000-000000000002',
    name: 'Main Current Account',
    type: AccountType.current,
    balance: 1842.76,
    monthlyBudget: 1800,
    monthlySpent: 0,
    accentColor: Color(0xFF4DB6AC),
  ),
  const AccountModel(
    id: '00000000-0000-0000-0000-000000000003',
    name: 'Savings Pot',
    type: AccountType.savings,
    balance: 5200,
    monthlyBudget: 600,
    monthlySpent: 0,
    accentColor: Color(0xFF66BB6A),
  ),
];

late MockAccountsApiClient mockClient;

Widget buildWidget() => MaterialApp(
      home: AccountsScreen(apiClientOverride: mockClient),
    );

void main() {
  setUp(() {
    mockClient = MockAccountsApiClient();
    when(() => mockClient.getAccounts())
        .thenAnswer((_) async => _accounts);
  });

  group('AccountsScreen', () {
    testWidgets('shows CircularProgressIndicator before load completes',
        (tester) async {
      final completer = Completer<List<AccountModel>>();
      when(() => mockClient.getAccounts())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildWidget());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(_accounts);
      await tester.pumpAndSettle();
    });

    testWidgets('shows account cards after load', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.text('Main Current Account'), findsOneWidget);
      expect(find.text('Savings Pot'), findsOneWidget);
    });

    testWidgets('tapping account card navigates to AccountDetailScreen',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main Current Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountDetailScreen), findsOneWidget);
    });

    testWidgets('tapping Add Account opens AddAccountSheet', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AddAccountSheet), findsOneWidget);
    });

    testWidgets('Transfer shows coming soon snackbar', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pump();
      expect(find.text('Transfer flow coming soon'), findsOneWidget);
    });

    testWidgets('Export shows coming soon snackbar', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export'));
      await tester.pump();
      expect(find.text('Export flow coming soon'), findsOneWidget);
    });
  });
}
