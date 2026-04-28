import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared bottom navigation bar used across all screens.
class AppFooter extends StatelessWidget {
  /// Creates an [AppFooter] with the given [activeIndex] highlighted.
  const AppFooter({this.activeIndex = 0, super.key});

  /// Index of the currently active tab (0 = Dashboard).
  final int activeIndex;

  static const _routes = ['/', '/accounts', '/budgets', '/transactions'];

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    if (index < _routes.length) {
      context.go(_routes[index]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reports coming soon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Budgets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
      ],
    );
  }
}
