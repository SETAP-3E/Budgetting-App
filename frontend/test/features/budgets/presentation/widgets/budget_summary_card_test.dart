import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildCard({
    double totalBudget = 1000,
    double totalSpent = 600,
    String month = 'March',
    int year = 2026,
    VoidCallback? onAddBudget,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: BudgetSummaryCard(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            month: month,
            year: year,
            onAddBudget: onAddBudget,
          ),
        ),
      );

  group('BudgetSummaryCard', () {
    testWidgets('renders total budget amount', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text(formatCurrency(1000)), findsOneWidget);
    });

    testWidgets('renders month and year', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('renders spent amount', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('£600.00'), findsOneWidget);
    });

    testWidgets('renders positive remaining amount in green', (tester) async {
      await tester.pumpWidget(buildCard());

      final remainingWidget =
          tester.widget<Text>(find.text('£400.00'));
      expect(remainingWidget.style?.color, Colors.green);
    });

    testWidgets('renders percentage text', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('60% of total budget used'), findsOneWidget);
    });

    testWidgets('shows over-budget warning when spent exceeds budget',
        (tester) async {
      await tester.pumpWidget(
        buildCard(totalBudget: 500),
      );
      expect(
        find.text('You have exceeded your budget!'),
        findsOneWidget,
      );
    });

    testWidgets('does not show over-budget warning when within budget',
        (tester) async {
      await tester.pumpWidget(buildCard());
      expect(
        find.text('You have exceeded your budget!'),
        findsNothing,
      );
    });

    testWidgets('remaining is red when over budget', (tester) async {
      await tester.pumpWidget(
        buildCard(totalBudget: 500),
      );

      final remainingWidget =
          tester.widget<Text>(find.text(formatCurrency(-100)));
      expect(remainingWidget.style?.color, Colors.red);
    });

    testWidgets('renders LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
