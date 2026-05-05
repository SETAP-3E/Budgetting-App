import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_alert_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildCard({
    String categoryName = 'Groceries',
    double allocatedAmount = 200,
    double currentAmount = 180,
    double percentage = 90,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: BudgetAlertCard(
            categoryName: categoryName,
            allocatedAmount: allocatedAmount,
            currentAmount: currentAmount,
            percentage: percentage,
          ),
        ),
      );

  group('BudgetAlertCard', () {
    testWidgets('renders category name', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders allocated and spent amounts', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('£200.00'), findsOneWidget);
      expect(find.text('£180.00'), findsOneWidget);
    });

    testWidgets('renders percentage text', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('90% of budget used'), findsOneWidget);
    });

    testWidgets('renders LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'shows Close to Limit badge when percentage <= 100',
      (tester) async {
        await tester.pumpWidget(buildCard());
        expect(find.text('Close to Limit'), findsOneWidget);
        expect(find.text('Over Budget'), findsNothing);
      },
    );

    testWidgets(
      'shows Over Budget badge when percentage > 100',
      (tester) async {
      await tester.pumpWidget(
        buildCard(currentAmount: 220, percentage: 110),
      );
      expect(find.text('Over Budget'), findsOneWidget);
      expect(find.text('Close to Limit'), findsNothing);
    });

    testWidgets(
      'card background is orange when close to limit',
      (tester) async {
        await tester.pumpWidget(buildCard());
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.color, Colors.orange[50]);
      },
    );

    testWidgets('card background is red when over budget', (tester) async {
      await tester.pumpWidget(
        buildCard(currentAmount: 220, percentage: 110),
      );
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.red[50]);
    });
  });
}
