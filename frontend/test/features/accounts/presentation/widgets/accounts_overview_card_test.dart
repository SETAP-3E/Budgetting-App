import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    double totalBalance = 3500,
    int activeAccounts = 3,
    int lowBalanceCount = 1,
    String currencyText = '£3,500.00',
  }) =>
      MaterialApp(
        home: Scaffold(
          body: AccountsOverviewCard(
            totalBalance: totalBalance,
            activeAccounts: activeAccounts,
            lowBalanceCount: lowBalanceCount,
            currencyText: currencyText,
          ),
        ),
      );

  group('AccountsOverviewCard', () {
    testWidgets('renders the Total Balance label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Total Balance'), findsOneWidget);
    });

    testWidgets('renders the formatted currency text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('£3,500.00'), findsOneWidget);
    });

    testWidgets('renders the active accounts pill', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('3 active accounts'), findsOneWidget);
    });

    testWidgets('renders the low balance count pill', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('1 need attention'), findsOneWidget);
    });

    testWidgets('updates pill text when counts change', (tester) async {
      await tester.pumpWidget(
        buildWidget(activeAccounts: 5, lowBalanceCount: 0),
      );
      expect(find.text('5 active accounts'), findsOneWidget);
      expect(find.text('0 need attention'), findsOneWidget);
    });
  });
}
