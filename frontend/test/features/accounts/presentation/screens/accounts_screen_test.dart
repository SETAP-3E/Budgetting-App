import 'dart:async';

import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountsApiClient extends Mock implements AccountsApiClient {}

class MockTransactionsApiClient extends Mock
    implements TransactionsApiClient {}

final _accounts = [
  const AccountModel(
    id: '00000000-0000-0000-0000-000000000002',
    name: 'Main Current Account',
    type: AccountType.current,
    balance: 1842.76,
    monthlyBudget: 1800,
    monthlySpent: 0,
    weeklySpent: 0,
    accentColor: Color(0xFF4DB6AC),
  ),
  const AccountModel(
    id: '00000000-0000-0000-0000-000000000003',
    name: 'Savings Pot',
    type: AccountType.savings,
    balance: 5200,
    monthlyBudget: 600,
    monthlySpent: 0,
    weeklySpent: 0,
    accentColor: Color(0xFF66BB6A),
  ),
];

late MockAccountsApiClient mockClient;
late MockTransactionsApiClient mockTxnsClient;

GoRouter _router() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => AccountsScreen(
            apiClientOverride: mockClient,
            txnsApiClientOverride: mockTxnsClient,
          ),
        ),
        GoRoute(
          path: '/accounts/:id',
          builder: (_, __) => const Scaffold(body: Text('AccountDetail')),
        ),
      ],
    );

Widget buildWidget() => MaterialApp.router(routerConfig: _router());

void main() {
  setUp(() {
    mockClient = MockAccountsApiClient();
    mockTxnsClient = MockTransactionsApiClient();
    when(() => mockClient.getAccounts()).thenAnswer((_) async => _accounts);
    when(() => mockTxnsClient.getTransactions())
        .thenAnswer((_) async => <TransactionModel>[]);
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

    testWidgets('tapping account card navigates to account detail',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main Current Account'));
      await tester.pumpAndSettle();
      expect(find.text('AccountDetail'), findsOneWidget);
    });

    testWidgets('tapping Add Account opens AddAccountSheet', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AddAccountSheet), findsOneWidget);
    });

    testWidgets('tapping Export shows preparing snackbar', (tester) async {
      final completer = Completer<List<TransactionModel>>();
      when(() => mockTxnsClient.getTransactions())
          .thenAnswer((_) => completer.future);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.file_download_outlined));
      await tester.pump();
      expect(find.text('Preparing export…'), findsOneWidget);
      completer.complete(<TransactionModel>[]);
      await tester.pumpAndSettle();
    });
  });
}
