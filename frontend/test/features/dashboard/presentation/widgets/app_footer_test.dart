import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildFooter({int activeIndex = 0}) => MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppFooter(activeIndex: activeIndex),
        ),
      );

  group('AppFooter', () {
    testWidgets('renders BottomNavigationBar', (tester) async {
      await tester.pumpWidget(buildFooter());
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('renders all navigation items', (tester) async {
      await tester.pumpWidget(buildFooter());
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('renders correct icons', (tester) async {
      await tester.pumpWidget(buildFooter());
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('sets currentIndex correctly', (tester) async {
      await tester.pumpWidget(buildFooter(activeIndex: 2));
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 2);
    });

    testWidgets('shows snackbar for reports on tap', (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.tap(find.text('Reports'));
      await tester.pump();
      expect(find.text('Reports coming soon'), findsOneWidget);
    });

    testWidgets('does not show snackbar when tapping other items', (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.tap(find.text('Dashboard'));
      await tester.pump();
      expect(find.text('Reports coming soon'), findsNothing);
    });

    testWidgets('handles tapping different indices', (tester) async {
      // Test that tapping doesn't crash
      await tester.pumpWidget(buildFooter());
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      // Since no router, it should not crash
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}