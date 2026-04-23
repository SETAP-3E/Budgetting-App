import 'package:flutter/material.dart';
import 'package:budgetting_frontend/core/router/app_router.dart';
import 'package:budgetting_frontend/core/theme/app_theme.dart';

void main() {
  runApp(const BudgetingApp());
}

class BudgetingApp extends StatelessWidget {
  const BudgetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Budgeting App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
