import 'dart:async';

import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountsApiClient extends Mock implements AccountsApiClient {}

AccountModel _acc({
  String id = 'test-acc',
  String name = 'Test Account',
  AccountType type = AccountType.current,
  double balance = 2000,
  double monthlyBudget = 1500,
  double monthlySpent = 800,
  double weeklySpent = 0,
}) =>
    AccountModel(
      id: id,
      name: name,
      type: type,
      balance: balance,
      monthlyBudget: monthlyBudget,
      monthlySpent: monthlySpent,
      weeklySpent: weeklySpent,
      accentColor: const Color(0xFF4DB6AC),
    );

late MockAccountsApiClient mockClient;

Widget buildWidget(AccountModel account) => MaterialApp(
      home: AccountDetailScreen(account: account, apiClient: mockClient),
    );

void main() {
  setUp(() {
    mockClient = MockAccountsApiClient();
    when(() => mockClient.getAccountTransactions(any()))
        .thenAnswer((_) async => []);
  });

  group('AccountDetailScreen', () {
    testWidgets('renders account name in AppBar', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(name: 'Holiday Fund')));
      await tester.pumpAndSettle();
      expect(find.text('Holiday Fund'), findsOneWidget);
    });

    testWidgets('renders formatted balance', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(balance: 1234.56)));
      await tester.pumpAndSettle();
      expect(find.text('£1,234.56'), findsOneWidget);
    });

    testWidgets('renders Monthly Budget label and value', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(monthlyBudget: 500)));
      await tester.pumpAndSettle();
      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(find.text('£500.00'), findsOneWidget);
    });

    testWidgets('renders Spent stat chip', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(monthlySpent: 300)));
      await tester.pumpAndSettle();
      expect(find.text('Spent'), findsOneWidget);
      expect(find.text('£300.00'), findsOneWidget);
    });

    testWidgets('renders Remaining stat chip', (tester) async {
      await tester.pumpWidget(
        buildWidget(_acc(monthlyBudget: 500, monthlySpent: 300)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('£200.00'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading',
        (tester) async {
      final completer = Completer<List<AccountTransactionItem>>();
      when(() => mockClient.getAccountTransactions(any()))
          .thenAnswer((_) => completer.future);
      await tester.pumpWidget(buildWidget(_acc()));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(<AccountTransactionItem>[]);
      await tester.pumpAndSettle();
    });
  });
}
