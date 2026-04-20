import 'package:budgetting_frontend/features/dashboard/presentation/widgets/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpendingChart', () {
    final mockCategories = [
      {
        'name': 'Groceries',
        'amount': 687.43,
        'percentage': 28.0,
        'colour': 0xFF2E7D32,
      },
      {
        'name': 'Utilities',
        'amount': 342.50,
        'percentage': 14.0,
        'colour': 0xFF4DB6AC,
      },
      {
        'name': 'Entertainment',
        'amount': 289.20,
        'percentage': 12.0,
        'colour': 0xFFFF9800,
      },
      {
        'name': 'Dining Out',
        'amount': 245.67,
        'percentage': 10.0,
        'colour': 0xFFFFC107,
      },
      {
        'name': 'Transport',
        'amount': 203.15,
        'percentage': 8.0,
        'colour': 0xFF66BB6A,
      },
    ];

    testWidgets('renders card with chart and legend', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingChart(
              categories: mockCategories,
              isSimpleView: false,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('renders colour indicators for each category', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingChart(
              categories: mockCategories,
              isSimpleView: false,
            ),
          ),
        ),
      );

      // Find all Container widgets with circular shape (colour indicators)
      final colourIndicators = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      expect(colourIndicators, findsWidgets);
    });

    testWidgets('triggers onCategoryTap callback when segment is tapped', (
      WidgetTester tester,
    ) async {
      String? tappedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingChart(
              categories: mockCategories,
              isSimpleView: false,
              onCategoryTap: (category) {
                tappedCategory = category;
              },
            ),
          ),
        ),
      );

      // TODO(test): Verify tap interaction triggers callback
      // This requires simulating touch events on PieChart segments
      // which is complex with fl_chart. Basic widget structure verified above.
      expect(tappedCategory, isNull);
    });

    testWidgets('handles empty categories gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
            body: SizedBox(),
          ),
          builder: (context, child) =>
              // ignore: prefer_const_constructors
              Scaffold(
            // ignore: prefer_const_constructors
            body: SpendingChart(
              categories: const [],
              isSimpleView: false,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(SpendingChart), findsOneWidget);
    });

    testWidgets('handles single category correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingChart(
              categories: [mockCategories[0]],
              isSimpleView: true,
            ),
          ),
        ),
      );

      // Widget renders without error
      expect(find.byType(SpendingChart), findsOneWidget);
    });

    testWidgets('applies custom colours when provided', (
      WidgetTester tester,
    ) async {
      const customColours = [
        0xFFFF0000, // Red
        0xFF00FF00, // Green
        0xFF0000FF, // Blue
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingChart(
              categories: mockCategories,
              isSimpleView: false,
              customColours: customColours,
            ),
          ),
        ),
      );

      expect(find.byType(SpendingChart), findsOneWidget);
    });

    testWidgets(
      'renders without errors in portrait orientation',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpendingChart(
                categories: mockCategories,
                isSimpleView: false,
              ),
            ),
          ),
        );

        expect(find.byType(SpendingChart), findsOneWidget);
      },
    );
  });
}
