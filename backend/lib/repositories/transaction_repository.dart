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
        '  c.name AS category_name, t.amount, t.description, '
        '  t.transaction_date, t.latitude, t.longitude '
        'FROM transactions t '
        'JOIN categories c ON c.id = t.category_id '
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
}
