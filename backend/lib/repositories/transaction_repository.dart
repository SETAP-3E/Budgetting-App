import 'package:budgetting_backend/models/transaction_model.dart';
import 'package:postgres/postgres.dart';

/// Data access for expense transactions.
class TransactionRepository {
  /// Create a [TransactionRepository] backed by [connection].
  const TransactionRepository(this.connection);

  /// The active database connection.
  final Connection connection;

  /// Returns all transactions for [userId], newest first, with category name.
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT t.id, t.user_id, t.account_id, t.category_id, '
        '  c.name AS category_name, a.name AS account_name, '
        '  t.amount, t.description, '
        '  t.transaction_date, t.latitude, t.longitude '
        'FROM transactions t '
        'JOIN categories c ON c.id = t.category_id '
        'LEFT JOIN accounts a ON a.id = t.account_id '
        'WHERE t.user_id = @userId '
        'ORDER BY t.transaction_date DESC, t.created_at DESC',
      ),
      parameters: {'userId': userId},
    );
    return result.map(TransactionModel.fromRow).toList();
  }

  /// Inserts a new transaction and returns the created row.
  Future<TransactionModel> createTransaction({
    required String userId,
    required String accountId,
    required String categoryId,
    required double amount,
    required String transactionDate,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'INSERT INTO transactions '
        '  (user_id, account_id, category_id, amount, description, '
        '   transaction_date, latitude, longitude) '
        'VALUES '
        '  (@userId, @accountId, @categoryId, @amount, @description, '
        '   @transactionDate, @latitude, @longitude) '
        'RETURNING id, user_id, account_id, category_id, amount, '
        '  description, transaction_date, latitude, longitude',
      ),
      parameters: {
        'userId': userId,
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'description': description,
        'transactionDate': transactionDate,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Re-query to get category name via JOIN.
    final row = result.first;
    final withCategory = await connection.execute(
      Sql.named(
        'SELECT t.id, t.user_id, t.account_id, t.category_id, '
        '  c.name AS category_name, t.amount, t.description, '
        '  t.transaction_date, t.latitude, t.longitude '
        'FROM transactions t '
        'JOIN categories c ON c.id = t.category_id '
        'WHERE t.id = @id',
      ),
      parameters: {'id': row.toColumnMap()['id']},
    );

    return TransactionModel.fromRow(withCategory.first);
  }

  /// Updates an existing transaction and returns the updated row, or null if
  /// no row matched [id] + [userId].
  Future<TransactionModel?> updateTransaction({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required double amount,
    required String transactionDate,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'UPDATE transactions SET '
        '  account_id = @accountId, category_id = @categoryId, '
        '  amount = @amount, description = @description, '
        '  transaction_date = @transactionDate, '
        '  latitude = @latitude, longitude = @longitude '
        'WHERE id = @id AND user_id = @userId '
        'RETURNING id',
      ),
      parameters: {
        'id': id,
        'userId': userId,
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'description': description,
        'transactionDate': transactionDate,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (result.isEmpty) return null;

    final withDetails = await connection.execute(
      Sql.named(
        'SELECT t.id, t.user_id, t.account_id, t.category_id, '
        '  c.name AS category_name, a.name AS account_name, '
        '  t.amount, t.description, '
        '  t.transaction_date, t.latitude, t.longitude '
        'FROM transactions t '
        'JOIN categories c ON c.id = t.category_id '
        'LEFT JOIN accounts a ON a.id = t.account_id '
        'WHERE t.id = @id',
      ),
      parameters: {'id': id},
    );

    return TransactionModel.fromRow(withDetails.first);
  }

  /// Deletes a transaction by [id] for [userId]. Returns true if a row was
  /// deleted, false if no matching row was found.
  Future<bool> deleteTransaction({
    required String id,
    required String userId,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'DELETE FROM transactions '
        'WHERE id = @id AND user_id = @userId '
        'RETURNING id',
      ),
      parameters: {'id': id, 'userId': userId},
    );
    return result.isNotEmpty;
  }
}
