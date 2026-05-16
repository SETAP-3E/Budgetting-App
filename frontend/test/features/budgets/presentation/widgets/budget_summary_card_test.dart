import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildCard({
    double totalBudget = 1000,
    double totalSpent = 600,
    String monthName = 'March',
    int month = 3,
    int year = 2025,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: BudgetSummaryCard(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            monthName: monthName,
            year: year,
            month: month,
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
      expect(find.text('March 2025'), findsOneWidget);
    });

    testWidgets('renders spent and remaining in one label', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(
        find.text('£600.00 spent  ·  £400.00 remaining'),
        findsOneWidget,
      );
    });

    testWidgets('renders "remaining" label when under budget', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.textContaining('remaining'), findsOneWidget);
    });

    testWidgets('renders percentage text for a past month', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('60% of budget used'), findsOneWidget);
    });

    testWidgets('pace chip shows "Over budget" when spent exceeds budget',
        (tester) async {
      await tester.pumpWidget(buildCard(totalBudget: 500));
      expect(find.text('Over budget'), findsOneWidget);
    });

    testWidgets('spent label shows "over budget" text when over limit',
        (tester) async {
      await tester.pumpWidget(buildCard(totalBudget: 500));
      expect(find.textContaining('over budget'), findsOneWidget);
    });

    testWidgets('does not show over-budget label when within budget',
        (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.textContaining('over budget'), findsNothing);
    });

    testWidgets('renders LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
