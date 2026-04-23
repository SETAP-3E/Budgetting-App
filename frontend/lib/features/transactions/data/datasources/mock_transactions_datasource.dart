import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';

/// In-memory mock datasource for transactions.
///
/// Mirrors the pattern used by [MockDashboardDataService].
/// Replace with a real API client when backend integration is ready.
class MockTransactionsDatasource {
  MockTransactionsDatasource._();

  static final List<TransactionModel> _transactions = [];

  /// Predefined spending categories matching the database seed data.
  static const List<String> predefinedCategories = [
    'Groceries',
    'Utilities',
    'Entertainment',
    'Dining Out',
    'Transport',
  ];

  /// Add a new transaction to the in-memory store.
  static void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
  }

  /// Returns an unmodifiable view of all stored transactions.
  static List<TransactionModel> getTransactions() =>
      List.unmodifiable(_transactions);
}
