import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/transactions_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const initialFilter = TransactionFilter(
    dateFrom: null,
    dateTo: null,
    categoryQuery: null,
    minAmount: null,
    maxAmount: null,
  );

  Widget buildSheet({
    TransactionFilter initialFilter = initialFilter,
    required ValueChanged<TransactionFilter> onApply,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: TransactionsFilterSheet(
            initialFilter: initialFilter,
            onApply: onApply,
          ),
        ),
      );

  group('TransactionsFilterSheet', () {
    testWidgets('renders sheet handle', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.byType(Container), findsWidgets); // Handle is a Container
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.text('Filter Transactions'), findsOneWidget);
    });

    testWidgets('renders date picker tiles', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Any'), findsNWidgets(2)); // Initial values
    });

    testWidgets('renders category text field', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.text('Category contains'), findsOneWidget);
      expect(find.text('e.g. Groceries'), findsOneWidget);
    });

    testWidgets('renders amount text fields', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.text('Min amount'), findsOneWidget);
      expect(find.text('Max amount'), findsOneWidget);
    });

    testWidgets('renders buttons', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('initializes with provided filter values', (tester) async {
      const filter = TransactionFilter(
        dateFrom: null,
        dateTo: null,
        categoryQuery: 'Test',
        minAmount: 10.0,
        maxAmount: 100.0,
      );
      await tester.pumpWidget(buildSheet(initialFilter: filter, onApply: (_) {}));
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('100.00'), findsOneWidget);
    });

    testWidgets('clears all fields on Clear All tap', (tester) async {
      var appliedFilter = const TransactionFilter();
      await tester.pumpWidget(buildSheet(
        initialFilter: const TransactionFilter(
          categoryQuery: 'Test',
          minAmount: 10.0,
        ),
        onApply: (filter) => appliedFilter = filter,
      ));
      await tester.tap(find.text('Clear All'));
      await tester.pump();
      expect(appliedFilter.categoryQuery, null);
      expect(appliedFilter.minAmount, null);
    });

    testWidgets('applies filter on Apply Filters tap', (tester) async {
      var appliedFilter = const TransactionFilter();
      await tester.pumpWidget(buildSheet(
        onApply: (filter) => appliedFilter = filter,
      ));
      await tester.enterText(find.byType(TextField).at(0), 'Groceries'); // Category
      await tester.enterText(find.byType(TextField).at(1), '50.00'); // Min
      await tester.enterText(find.byType(TextField).at(2), '200.00'); // Max
      await tester.tap(find.text('Apply Filters'));
      await tester.pump();
      expect(appliedFilter.categoryQuery, 'Groceries');
      expect(appliedFilter.minAmount, 50.0);
      expect(appliedFilter.maxAmount, 200.0);
    });

    testWidgets('handles invalid amount inputs', (tester) async {
      var appliedFilter = const TransactionFilter();
      await tester.pumpWidget(buildSheet(
        onApply: (filter) => appliedFilter = filter,
      ));
      await tester.enterText(find.byType(TextField).at(1), 'invalid');
      await tester.tap(find.text('Apply Filters'));
      await tester.pump();
      expect(appliedFilter.minAmount, null);
    });

    testWidgets('shows clear button on date tiles when date is set', (tester) async {
      // Hard to test date picker without mocking showDatePicker
      // Perhaps test that clear is shown when date is not null
      final filter = TransactionFilter(
        dateFrom: DateTime(2023, 1, 1),
        dateTo: null,
      );
      await tester.pumpWidget(buildSheet(initialFilter: filter, onApply: (_) {}));
      expect(find.byIcon(Icons.clear), findsOneWidget); // For From
    });

    testWidgets('renders _SheetHandle correctly', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      final handle = find.byType(Container).first;
      final container = tester.widget<Container>(handle);
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('renders date picker tiles', (tester) async {
      await tester.pumpWidget(buildSheet(onApply: (_) {}));
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
    });
  });
}