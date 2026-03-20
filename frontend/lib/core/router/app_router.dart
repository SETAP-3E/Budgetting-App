import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// TODO: Import dashboard_screen when created
// import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Dashboard route (home)
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) {
        // TODO: Replace with DashboardScreen when ready
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: const Center(child: Text('Dashboard Screen - Coming Soon')),
        );
      },
    ),
  ],
);
