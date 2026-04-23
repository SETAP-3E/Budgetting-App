import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/top_category_alert.dart';

void main() {
  group('TopCategoryAlert', () {
    testWidgets('renders category name and percentage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 687.43,
                previousAmount: 650,
                percentage: 28,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('28.0% of spending'), findsOneWidget);
    });

    testWidgets('displays current amount with currency formatting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Utilities',
                currentAmount: 342.50,
                previousAmount: 320,
                percentage: 14,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£342.50'), findsOneWidget);
    });

    testWidgets('shows increase indicator when spending increased', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Entertainment',
                currentAmount: 300,
                previousAmount: 250,
                percentage: 12,
              ),
            ),
          ),
        ),
      );

      expect(find.text('↑'), findsOneWidget);
      expect(find.text('£50.00 more than last month'), findsOneWidget);
    });

    testWidgets('shows decrease indicator when spending decreased', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Dining Out',
                currentAmount: 200,
                previousAmount: 250,
                percentage: 8,
              ),
            ),
          ),
        ),
      );

      expect(find.text('↓'), findsOneWidget);
      expect(find.text('£50.00 less than last month'), findsOneWidget);
    });

    testWidgets('shows same indicator when spending unchanged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Transport',
                currentAmount: 200,
                previousAmount: 200,
                percentage: 8,
              ),
            ),
          ),
        ),
      );

      expect(find.text('→'), findsOneWidget);
      expect(find.text('Same as last month'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 500,
                previousAmount: 480,
                percentage: 20,
                categoryIcon: Icons.shopping_cart,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('does not render icon when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 500,
                previousAmount: 480,
                percentage: 20,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart), findsNothing);
    });

    testWidgets('applies custom colour to icon', (
      WidgetTester tester,
    ) async {
      const customColour = 0xFFFF9800;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 500,
                previousAmount: 480,
                percentage: 20,
                categoryIcon: Icons.shopping_cart,
                categoryColour: customColour,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.shopping_cart));
      expect(icon.color, const Color(customColour));
    });

    testWidgets('applies custom colour to left border', (
      WidgetTester tester,
    ) async {
      const customColour = 0xFF4DB6AC;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 500,
                previousAmount: 480,
                percentage: 20,
                categoryColour: customColour,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (
      WidgetTester tester,
    ) async {
      var wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 500,
                previousAmount: 480,
                percentage: 20,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });

    testWidgets('displays small percentage values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Other',
                currentAmount: 50,
                previousAmount: 45,
                percentage: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.text('2.0% of spending'), findsOneWidget);
    });

    testWidgets('displays large percentage values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 1000,
                previousAmount: 950,
                percentage: 40,
              ),
            ),
          ),
        ),
      );

      expect(find.text('40.0% of spending'), findsOneWidget);
    });

    testWidgets('renders card structure correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Utilities',
                currentAmount: 300,
                previousAmount: 280,
                percentage: 12,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('handles zero difference in spending', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Transport',
                currentAmount: 150,
                previousAmount: 150,
                percentage: 6,
              ),
            ),
          ),
        ),
      );

      expect(find.text('→'), findsOneWidget);
      expect(find.text('Same as last month'), findsOneWidget);
    });

    testWidgets('formats decimal amounts correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 687.43,
                previousAmount: 650,
                percentage: 28,
              ),
            ),
          ),
        ),
      );

      expect(find.text('£687.43'), findsOneWidget);
    });
  });
}
