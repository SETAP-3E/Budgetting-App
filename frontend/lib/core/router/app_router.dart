import 'package:budgetting_frontend/core/auth/auth_notifier.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:budgetting_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:budgetting_frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:budgetting_frontend/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:budgetting_frontend/features/reports/presentation/screens/spending_map_screen.dart';
import 'package:budgetting_frontend/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:go_router/go_router.dart';

/// Module-level singleton — importable by screens that need to trigger auth
/// state changes (login, logout).
final authNotifier = AuthNotifier();

/// Application router with authentication guard.
final appRouter = GoRouter(
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final loggedIn = authNotifier.isAuthenticated;
    final loc = state.matchedLocation;
    final onAuthRoute = loc == '/login' || loc == '/signup';
    if (!loggedIn && !onAuthRoute) return '/login';
    if (loggedIn && onAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/accounts',
      name: 'accounts',
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: '/transactions',
      name: 'transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/budgets',
      name: 'budgets',
      builder: (context, state) => const BudgetsScreen(),
    ),
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const SpendingMapScreen(),
    ),
  ],
);
