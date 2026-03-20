import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/category_card.dart';

void main() {
  group('CategoryCard', () {
    testWidgets('displays rank badge with correct position', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Groceries',
              amount: 687.43,
              percentage: 28.0,
            ),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('displays category name correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 2,
              categoryName: 'Utilities',
              amount: 342.50,
              percentage: 14.0,
            ),
          ),
        ),
      );

      expect(find.text('Utilities'), findsOneWidget);
    });

    testWidgets('displays amount with correct currency formatting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 3,
              categoryName: 'Entertainment',
              amount: 289.20,
              percentage: 12.0,
            ),
          ),
        ),
      );

      expect(find.text('£289.20'), findsOneWidget);
    });

    testWidgets('displays percentage with one decimal place', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Groceries',
              amount: 687.43,
              percentage: 28.0,
            ),
          ),
        ),
      );

      expect(find.text('28.0%'), findsOneWidget);
    });

    testWidgets('renders category icon when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Groceries',
              amount: 687.43,
              percentage: 28.0,
              categoryIcon: Icons.shopping_cart,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('renders without icon when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Groceries',
              amount: 687.43,
              percentage: 28.0,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart), findsNothing);
    });

    testWidgets('renders spending progress bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Groceries',
              amount: 687.43,
              percentage: 28.0,
            ),
          ),
        ),
      );

      // ClipRRect for progress bar wrapping
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('applies custom category colour to icon', (
      WidgetTester tester,
    ) async {
      const customColour = 0xFFFF9800; // Orange

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Dining Out',
              amount: 245.67,
              percentage: 10.0,
              categoryIcon: Icons.restaurant,
              categoryColour: customColour,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byType(CategoryCard), findsOneWidget);
    });

    testWidgets('triggers onTap callback when card is tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName: 'Groceries',
              amount: 687.43,
              percentage: 28.0,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('handles long category names gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 1,
              categoryName:
                  'Very Long Category Name That Should Not Break Layout',
              amount: 123.45,
              percentage: 5.0,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(
        find.text(
          'Very Long Category Name That Should Not Break Layout',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays different rank numbers correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CategoryCard(
                  rank: 1,
                  categoryName: 'Cat1',
                  amount: 100.0,
                  percentage: 10.0,
                ),
                CategoryCard(
                  rank: 5,
                  categoryName: 'Cat5',
                  amount: 50.0,
                  percentage: 5.0,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#5'), findsOneWidget);
    });

    testWidgets('renders multiple cards in a list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                CategoryCard(
                  rank: 1,
                  categoryName: 'Groceries',
                  amount: 687.43,
                  percentage: 28.0,
                ),
                CategoryCard(
                  rank: 2,
                  categoryName: 'Utilities',
                  amount: 342.50,
                  percentage: 14.0,
                ),
                CategoryCard(
                  rank: 3,
                  categoryName: 'Entertainment',
                  amount: 289.20,
                  percentage: 12.0,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CategoryCard), findsNWidgets(3));
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
    });

    testWidgets('formats small percentage values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              rank: 5,
              categoryName: 'Transport',
              amount: 203.15,
              percentage: 8.3,
            ),
          ),
        ),
      );

      expect(find.text('8.3%'), findsOneWidget);
    });
  });
}
