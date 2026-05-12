import 'package:budgetting_backend/models/account_model.dart';
import 'package:postgres/postgres.dart';

/// Data access for user accounts.
class AccountRepository {
  /// Create an [AccountRepository] backed by [connection].
  const AccountRepository(this.connection);

  /// The active database connection.
  final Connection connection;

  /// Returns all active accounts for [userId], with monthly_spent computed
  /// from transactions in the current calendar month.
  Future<List<AccountModel>> getAccounts(String userId) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT a.id, a.user_id, a.name, a.account_type,
               a.balance, a.monthly_budget, a.accent_color,
               COALESCE((
                 SELECT SUM(t.amount) FROM transactions t
                 WHERE t.account_id = a.id
                   AND DATE_TRUNC('month', t.transaction_date)
                     = DATE_TRUNC('month', CURRENT_DATE)
               ), 0) AS monthly_spent,
               COALESCE((
                 SELECT SUM(t.amount) FROM transactions t
                 WHERE t.account_id = a.id
                   AND DATE_TRUNC('month', t.transaction_date)
                     = DATE_TRUNC('month', CURRENT_DATE)
                   AND CEIL(EXTRACT(DAY FROM t.transaction_date) / 7.0)::int
                     = CEIL(EXTRACT(DAY FROM CURRENT_DATE) / 7.0)::int
               ), 0) AS weekly_spent
        FROM accounts a
        WHERE a.user_id = @userId AND a.is_active = TRUE
        ORDER BY a.created_at
      '''),
      parameters: {'userId': userId},
    );
    return result.map(AccountModel.fromRow).toList();
  }

  /// Inserts a new account and returns the created row.
  Future<AccountModel> createAccount({
    required String userId,
    required String name,
    required String accountType,
    required double balance,
    required double monthlyBudget,
    required int accentColor,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'INSERT INTO accounts '
        '  (user_id, name, account_type, '
        '   balance, monthly_budget, accent_color) '
        'VALUES '
        '  (@userId, @name, @accountType, '
        '   @balance, @monthlyBudget, @accentColor) '
        'RETURNING id, user_id, name, account_type, '
        '  balance, monthly_budget, accent_color, '
        '  0 AS monthly_spent, 0 AS weekly_spent',
      ),
      parameters: {
        'userId': userId,
        'name': name,
        'accountType': accountType,
        'balance': balance,
        'monthlyBudget': monthlyBudget,
        'accentColor': accentColor,
      },
    );
    return AccountModel.fromRow(result.first);
  }
}
