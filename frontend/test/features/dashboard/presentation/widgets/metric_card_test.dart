import 'package:budgetting_frontend/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetricCard', () {
    testWidgets('renders card with amount, month, and year', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 2456.32,
                month: 'March',
                year: 2026,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£2,456.32'), findsOneWidget);
      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('displays amount with correct currency formatting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 1234.5,
                month: 'January',
                year: 2026,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£1,234.50'), findsOneWidget);
    });

    testWidgets('displays zero spending correctly formatted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 0,
                month: 'February',
                year: 2026,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£0.00'), findsOneWidget);
    });

    testWidgets('renders no-budget message when no goal provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 500,
                month: 'March',
                year: 2026,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('No monthly budget set'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders progress bar when goal provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 1500,
                month: 'March',
                year: 2026,
                budgetGoal: 3000,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays remaining budget when spending is under goal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 1500,
                month: 'March',
                year: 2026,
                budgetGoal: 3000,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£1,500.00 remaining'), findsOneWidget);
      expect(find.text('50% used'), findsOneWidget);
    });

    testWidgets('displays over-budget text when spending exceeds goal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 3500,
                month: 'March',
                year: 2026,
                budgetGoal: 3000,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£500.00 over budget'), findsOneWidget);
      expect(find.text('117% used'), findsOneWidget);
    });

    testWidgets('progress bar shows 50% fill at goal midpoint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 1500,
                month: 'March',
                year: 2026,
                budgetGoal: 3000,
              ),
            ),
          ),
        ),
      );

      final progress = find.byType(LinearProgressIndicator);
      expect(progress, findsOneWidget);
      final widget = tester.widget<LinearProgressIndicator>(progress);
      expect(widget.value, 0.5);
    });

    testWidgets('progress bar caps at 100% when exceeding goal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 4000,
                month: 'March',
                year: 2026,
                budgetGoal: 3000,
              ),
            ),
          ),
        ),
      );

      final progress = find.byType(LinearProgressIndicator);
      final widget = tester.widget<LinearProgressIndicator>(progress);
      expect(widget.value, 1.0);
    });

    testWidgets('hides button when goal provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 1500,
                month: 'March',
                year: 2026,
                budgetGoal: 3000,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add Spending'), findsNothing);
    });

    testWidgets('displays large amounts correctly formatted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 9999.99,
                month: 'December',
                year: 2026,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£9,999.99'), findsOneWidget);
      final textWidget = find.text('£9,999.99');
      final textStyle = tester.widget<Text>(textWidget).style;
      expect(textStyle?.fontSize, 57.0);
    });

    testWidgets('displays month and year correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 500,
                month: 'November',
                year: 2025,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('November 2025'), findsOneWidget);
    });

    testWidgets('renders card with correct structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MetricCard(
                totalSpending: 500,
                month: 'March',
                year: 2026,
                budgetGoal: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
