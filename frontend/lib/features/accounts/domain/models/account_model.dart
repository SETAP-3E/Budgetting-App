import 'package:flutter/material.dart';

/// Supported account categories for the accounts view.
enum AccountType {
  /// Daily spending account.
  current('Current Account', Icons.account_balance_wallet),

  /// Account focused on saving money.
  savings('Savings Account', Icons.savings),

  /// Shared account used by more than one person.
  joint('Joint Account', Icons.groups);

  const AccountType(this.label, this.icon);

  /// User-facing label for UI.
  final String label;

  /// Default icon used in account cards.
  final IconData icon;
}

/// Read model for account information displayed in the UI.
class AccountModel {
  /// Creates an account model.
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.weeklySpent,
    required this.accentColor,
  });

  /// Unique account identifier.
  final String id;

  /// Human-readable account name.
  final String name;

  /// Category of this account.
  final AccountType type;

  /// Current available balance.
  final double balance;

  /// Planned monthly budget for this account.
  final double monthlyBudget;

  /// Amount spent so far this month.
  final double monthlySpent;

  /// Amount spent in the current week of this month.
  final double weeklySpent;

  /// Accent color for avatars and indicators.
  final Color accentColor;

  /// Remaining budget value for this month.
  double get remainingBudget => monthlyBudget - monthlySpent;

  /// Monthly utilization ratio in the range 0..1+.
  double get budgetUsageRatio {
    if (monthlyBudget <= 0) return 0;
    return monthlySpent / monthlyBudget;
  }

  /// Pro-rated weekly target (monthly budget ÷ number of weeks in the month).
  double get weeklyTarget {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final numWeeks = (daysInMonth / 7).ceil();
    return monthlyBudget > 0 ? monthlyBudget / numWeeks : 0;
  }

  /// Weekly utilization ratio in the range 0..1+.
  double get weeklyUsageRatio {
    if (weeklyTarget <= 0) return 0;
    return weeklySpent / weeklyTarget;
  }
}
