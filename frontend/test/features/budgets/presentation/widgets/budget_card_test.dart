import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildCard({
    int rank = 1,
    String categoryName = 'Groceries',
    double allocatedAmount = 200,
    double spentAmount = 120,
    double percentage = 60,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: BudgetCard(
            rank: rank,
            categoryName: categoryName,
            allocatedAmount: allocatedAmount,
            spentAmount: spentAmount,
            percentage: percentage,
          ),
        ),
      );

  group('BudgetCard', () {
    testWidgets('renders rank', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('renders category name', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders spent and allocated amounts', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('£120.00'), findsOneWidget);
      expect(find.text(' / £200.00'), findsOneWidget);
    });

    testWidgets('renders percentage text', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('renders a LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows red color when over budget', (tester) async {
      await tester.pumpWidget(buildCard(spentAmount: 250, percentage: 125));

      final percentageText = tester.widget<Text>(find.text('125%'));
      expect(
        percentageText.style?.color,
        Colors.red,
      );
    });

    testWidgets('does not show red when within budget', (tester) async {
      await tester.pumpWidget(buildCard());

      final percentageText = tester.widget<Text>(find.text('60%'));
      expect(
        percentageText.style?.color,
        isNot(Colors.red),
      );
    });
  });
}
