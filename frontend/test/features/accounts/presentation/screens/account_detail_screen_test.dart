import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildWidget(AccountModel account) => MaterialApp(
      home: AccountDetailScreen(account: account),
    );

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

void main() {
  group('AccountDetailScreen', () {
    testWidgets('renders account name in AppBar', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(name: 'Holiday Fund')));
      expect(find.text('Holiday Fund'), findsOneWidget);
    });

    testWidgets('renders formatted balance', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(balance: 1234.56)));
      expect(find.text('£1,234.56'), findsOneWidget);
    });

    testWidgets('renders Monthly Budget stat tile', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(monthlyBudget: 500)));
      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(find.text('£500.00'), findsOneWidget);
    });

    testWidgets('renders Spent This Month stat tile', (tester) async {
      await tester.pumpWidget(buildWidget(_acc(monthlySpent: 300)));
      expect(find.text('Spent This Month'), findsOneWidget);
      expect(find.text('£300.00'), findsOneWidget);
    });

    testWidgets('renders Remaining stat tile', (tester) async {
      await tester
          .pumpWidget(buildWidget(_acc(monthlyBudget: 500, monthlySpent: 300)));
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('£200.00'), findsOneWidget);
    });

    testWidgets('shows Over budget chip when spent exceeds budget',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(_acc(monthlyBudget: 500, monthlySpent: 600)),
      );
      expect(find.text('Over budget'), findsOneWidget);
    });

    testWidgets('does not show Over budget chip when within budget',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(_acc(monthlyBudget: 500, monthlySpent: 300)),
      );
      expect(find.text('Over budget'), findsNothing);
    });

    testWidgets('shows Low balance chip when balance is below 1000',
        (tester) async {
      await tester.pumpWidget(buildWidget(_acc(balance: 999)));
      expect(find.text('Low balance'), findsOneWidget);
    });

    testWidgets('does not show Low balance chip when balance is 1000 or above',
        (tester) async {
      await tester.pumpWidget(buildWidget(_acc(balance: 1000)));
      expect(find.text('Low balance'), findsNothing);
    });
  });
}
