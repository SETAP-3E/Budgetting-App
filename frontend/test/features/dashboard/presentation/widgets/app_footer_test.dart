import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _router({int activeIndex = 0}) => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            bottomNavigationBar: AppFooter(activeIndex: activeIndex),
          ),
        ),
        GoRoute(path: '/accounts', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/budgets', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/transactions', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/reports', builder: (_, __) => const Scaffold()),
      ],
    );

Widget buildFooter({int activeIndex = 0}) =>
    MaterialApp.router(routerConfig: _router(activeIndex: activeIndex));

void main() {
  group('AppFooter', () {
    testWidgets('renders BottomNavigationBar', (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('renders all navigation items', (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Expense Map'), findsOneWidget);
    });

    testWidgets('renders correct icons', (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });

    testWidgets('sets currentIndex correctly', (tester) async {
      await tester.pumpWidget(buildFooter(activeIndex: 2));
      await tester.pumpAndSettle();
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 2);
    });

    testWidgets('tapping a non-active item navigates without crashing',
        (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('tapping the active item does not navigate', (tester) async {
      await tester.pumpWidget(buildFooter());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
