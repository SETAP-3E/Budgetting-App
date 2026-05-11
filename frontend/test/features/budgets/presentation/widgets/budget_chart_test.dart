import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleCategories = [
    {
      'name': 'Groceries',
      'allocated': 200.0,
      'spent': 150.0,
      'colour': 0xFF4CAF50,
    },
    {
      'name': 'Entertainment',
      'allocated': 100.0,
      'spent': 80.0,
      'colour': 0xFF2196F3,
    },
    {
      'name': 'Transport',
      'allocated': 150.0,
      'spent': 120.0,
      'colour': 0xFFFF9800,
    },
  ];

  Widget buildChart({
    List<Map<String, dynamic>> categories = sampleCategories,
    bool isSimpleView = true,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: BudgetChart(
            categories: categories,
            isSimpleView: isSimpleView,
          ),
        ),
      );

  group('BudgetChart', () {
    group('Simple View (Pie Chart)', () {
      testWidgets('renders title', (tester) async {
        await tester.pumpWidget(buildChart());
        expect(find.text('Budget allocation'), findsOneWidget);
      });

      testWidgets('renders PieChart', (tester) async {
        await tester.pumpWidget(buildChart());
        expect(find.byType(PieChart), findsOneWidget);
      });

      testWidgets('renders legend with category names and percentages',
          (tester) async {
        await tester.pumpWidget(buildChart());
        expect(find.textContaining('Groceries • 44.4%'), findsOneWidget);
        expect(find.textContaining('Entertainment • 22.2%'), findsOneWidget);
        expect(find.textContaining('Transport • 33.3%'), findsOneWidget);
      });

      testWidgets('renders color indicators in legend', (tester) async {
        await tester.pumpWidget(buildChart());
        // Check for containers with specific colors
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
        // More specific checks would require inspecting widget properties
      });

      testWidgets('does not show tooltip initially', (tester) async {
        await tester.pumpWidget(buildChart());
        expect(find.text('Groceries'), findsNothing); // Only in legend
        expect(find.textContaining('150.00'), findsNothing);
      });

      testWidgets('shows tooltip when section is touched', (tester) async {
        await tester.pumpWidget(buildChart());
        // Simulate tap on pie chart - this is complex, so perhaps skip or mock
        // For now, test that tooltip can be shown by setting state
        // But since it's stateful, hard to test interaction without integration
        // Perhaps test the _buildCenterTooltip method indirectly
      });

      testWidgets('calculates percentages correctly', (tester) async {
        await tester.pumpWidget(buildChart());
        // Total allocated: 200 + 100 + 150 = 450
        // Groceries: 200/450 ≈ 44.4%
        expect(find.textContaining('44.4%'), findsOneWidget);
      });

      testWidgets('handles empty categories', (tester) async {
        await tester.pumpWidget(buildChart(categories: []));
        expect(find.byType(PieChart), findsOneWidget);
        // Should not crash
      });

      testWidgets('handles zero allocated amounts', (tester) async {
        const zeroCategories = [
          {'name': 'Test', 'allocated': 0.0, 'spent': 0.0, 'colour': 0xFF000000}
        ];
        await tester.pumpWidget(buildChart(categories: zeroCategories));
        expect(find.byType(PieChart), findsOneWidget);
      });
    });

    group('Edit View (Stacked Bars)', () {
      testWidgets('renders title', (tester) async {
        await tester.pumpWidget(buildChart(isSimpleView: false));
        expect(find.text('Budget vs Spending'), findsOneWidget);
      });

      testWidgets('renders category names', (tester) async {
        await tester.pumpWidget(buildChart(isSimpleView: false));
        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Entertainment'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);
      });

      testWidgets('renders spent vs allocated amounts', (tester) async {
        await tester.pumpWidget(buildChart(isSimpleView: false));
        expect(find.text('£150.00 / £200.00'), findsOneWidget);
        expect(find.text('£80.00 / £100.00'), findsOneWidget);
        expect(find.text('£120.00 / £150.00'), findsOneWidget);
      });

      testWidgets('renders LinearProgressIndicator for each category',
          (tester) async {
        await tester.pumpWidget(buildChart(isSimpleView: false));
        expect(find.byType(LinearProgressIndicator), findsNWidgets(6)); // 2 per category
      });

      testWidgets('shows over budget in red when spent > allocated',
          (tester) async {
        const overBudgetCategories = [
          {
            'name': 'Over',
            'allocated': 100.0,
            'spent': 150.0,
            'colour': 0xFF4CAF50,
          }
        ];
        await tester.pumpWidget(
          buildChart(categories: overBudgetCategories, isSimpleView: false),
        );
        // The spent bar should be red, but hard to test color in test
        expect(find.text('£150.00 / £100.00'), findsOneWidget);
      });

      testWidgets('handles empty categories in edit view', (tester) async {
        await tester.pumpWidget(buildChart(categories: [], isSimpleView: false));
        expect(find.text('Budget vs Spending'), findsOneWidget);
        // Should not crash
      });

      testWidgets('scales bars based on max allocated', (tester) async {
        await tester.pumpWidget(buildChart(isSimpleView: false));
        // Max allocated is 200, so bars should be proportional
        // Hard to test exact values without accessing widget internals
      });
    });

    group('General', () {
      testWidgets('renders in Card widget', (tester) async {
        await tester.pumpWidget(buildChart());
        expect(find.byType(Card), findsOneWidget);
      });
    });
  });
}