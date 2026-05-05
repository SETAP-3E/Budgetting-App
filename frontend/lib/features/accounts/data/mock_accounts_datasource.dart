import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:flutter/material.dart';

/// Mock datasource for the accounts feature.
class MockAccountsDatasource {
  static final List<AccountModel> _accounts = [
    const AccountModel(
      id: 'acc_current_main',
      name: 'Main Current Account',
      type: AccountType.current,
      balance: 1842.76,
      monthlyBudget: 1800,
      monthlySpent: 1210.54,
      accentColor: Color(0xFF4DB6AC),
    ),
    const AccountModel(
      id: 'acc_savings_pot',
      name: 'Savings Pot',
      type: AccountType.savings,
      balance: 5200,
      monthlyBudget: 600,
      monthlySpent: 420,
      accentColor: Color(0xFF66BB6A),
    ),
    const AccountModel(
      id: 'acc_joint_bills',
      name: 'Joint Bills Account',
      type: AccountType.joint,
      balance: 963.45,
      monthlyBudget: 1100,
      monthlySpent: 892.18,
      accentColor: Color(0xFFFFC107),
    ),
    const AccountModel(
      id: 'acc_trip_savings',
      name: 'Trip Savings',
      type: AccountType.savings,
      balance: 1375.20,
      monthlyBudget: 300,
      monthlySpent: 140,
      accentColor: Color(0xFFFF9800),
    ),
  ];

  /// Returns the current list of accounts.
  static List<AccountModel> getAccounts() => List.unmodifiable(_accounts);

  /// Appends a new account to the in-memory list.
  static void addAccount(AccountModel account) => _accounts.add(account);
}
