import 'package:budgetting_backend/models/budget_item_model.dart';
import 'package:postgres/postgres.dart';

/// Data access for budget goals and per-period spending summaries.
class BudgetRepository {
  /// Create a [BudgetRepository] backed by [connection].
  const BudgetRepository(this.connection);

  /// The active database connection.
  final Connection connection;

  /// Returns budget items for [userId] in a specific [year]/[month].
  ///
  /// Only categories with a goal set for the period are returned.
  /// Spending is aggregated from transactions in the same month.
  Future<List<BudgetItemModel>> getBudgetsByMonth(
    String userId,
    int year,
    int month,
  ) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT c.id AS category_id, c.name, c.colour_value, '
        '  b.goal_amount, '
        '  COALESCE(('
        '    SELECT SUM(tx.amount) FROM transactions tx '
        '    WHERE tx.category_id = c.id '
        '      AND tx.user_id = @userId '
        '      AND EXTRACT(YEAR FROM tx.transaction_date) = @year '
        '      AND EXTRACT(MONTH FROM tx.transaction_date) = @month'
        '  ), 0) AS spent_amount '
        'FROM categories c '
        'JOIN budgets b '
        '  ON b.category_id = c.id '
        ' AND b.user_id = @userId '
        ' AND b.period_year = @year '
        ' AND b.period_month = @month '
        'WHERE (c.is_predefined = TRUE OR c.user_id = @userId) '
        '  AND c.is_active = TRUE '
        'ORDER BY b.goal_amount DESC',
      ),
      parameters: {'userId': userId, 'year': year, 'month': month},
    );
    return result.map(BudgetItemModel.fromRow).toList();
  }

  /// Returns budget items for [userId] aggregated across an entire [year].
  ///
  /// Goal amounts are summed across all months where goals were set.
  /// Only categories with at least one goal in the year are returned.
  Future<List<BudgetItemModel>> getBudgetsByYear(
    String userId,
    int year,
  ) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT c.id AS category_id, c.name, c.colour_value, '
        '  COALESCE(('
        '    SELECT SUM(b2.goal_amount) FROM budgets b2 '
        '    WHERE b2.category_id = c.id '
        '      AND b2.user_id = @userId '
        '      AND b2.period_year = @year'
        '  ), 0) AS goal_amount, '
        '  COALESCE(('
        '    SELECT SUM(tx.amount) FROM transactions tx '
        '    WHERE tx.category_id = c.id '
        '      AND tx.user_id = @userId '
        '      AND EXTRACT(YEAR FROM tx.transaction_date) = @year'
        '  ), 0) AS spent_amount '
        'FROM categories c '
        'WHERE (c.is_predefined = TRUE OR c.user_id = @userId) '
        '  AND c.is_active = TRUE '
        '  AND EXISTS ('
        '    SELECT 1 FROM budgets b3 '
        '    WHERE b3.category_id = c.id '
        '      AND b3.user_id = @userId '
        '      AND b3.period_year = @year'
        '  ) '
        'ORDER BY goal_amount DESC',
      ),
      parameters: {'userId': userId, 'year': year},
    );
    return result.map(BudgetItemModel.fromRow).toList();
  }
}
