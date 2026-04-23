import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:budgetting_frontend/features/budgets/presentation/screens/budgets_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Dashboard route (home)
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Budgets route
    GoRoute(
      path: '/budgets',
      name: 'budgets',
      builder: (context, state) => const BudgetsScreen(),
    ),
  ],
);
