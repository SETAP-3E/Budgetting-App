import 'package:budgetting_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:budgetting_frontend/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:go_router/go_router.dart';

/// Application router defining all named routes.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Dashboard route (home)
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Transactions list route
    GoRoute(
      path: '/transactions',
      name: 'transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
  ],
);
