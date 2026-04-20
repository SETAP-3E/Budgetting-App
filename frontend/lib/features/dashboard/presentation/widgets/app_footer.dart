import 'package:flutter/material.dart';

/// Footer navigation widget with 5 bottom navigation buttons.
///
/// Displays: Dashboard, Accounts, Budgets, Transactions, Reports
class AppFooter extends StatelessWidget {
  /// Create a [AppFooter].
  const AppFooter({
    this.activeIndex = 0,
    this.onNavigation,
    super.key,
  });

  /// Index of the active navigation item (0 = Dashboard).
  final int activeIndex;

  /// Callback when a navigation item is tapped.
  final Function(int)? onNavigation;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: onNavigation,
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
