import 'package:budgetting_backend/models/budget_item_model.dart';
import 'package:budgetting_backend/models/weekly_breakdown_model.dart';
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

  /// Deletes the budget goal for [categoryId] in [year]/[month].
  ///
  /// Returns true if a row was deleted, false if not found.
  Future<bool> deleteBudget({
    required String userId,
    required String categoryId,
    required int year,
    required int month,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'DELETE FROM budgets '
        'WHERE user_id = @userId AND category_id = @categoryId '
        '  AND period_year = @year AND period_month = @month '
        'RETURNING id',
      ),
      parameters: {
        'userId': userId,
        'categoryId': categoryId,
        'year': year,
        'month': month,
      },
    );
    return result.isNotEmpty;
  }

  /// Creates or updates a budget goal for [categoryId] in [year]/[month].
  Future<void> upsertBudget({
    required String userId,
    required String categoryId,
    required int year,
    required int month,
    required double goalAmount,
  }) async {
    await connection.execute(
      Sql.named(
        'INSERT INTO budgets '
        '  (user_id, category_id, period_year, period_month, goal_amount) '
        'VALUES (@userId, @categoryId, @year, @month, @goalAmount) '
        'ON CONFLICT ON CONSTRAINT budgets_unique_goal_per_period '
        'DO UPDATE SET '
        '  goal_amount = EXCLUDED.goal_amount, '
        '  updated_at  = now()',
      ),
      parameters: {
        'userId': userId,
        'categoryId': categoryId,
        'year': year,
        'month': month,
        'goalAmount': goalAmount,
      },
    );
  }

  /// Returns per-week spending totals for [userId] in [year]/[month].
  ///
  /// Weeks are defined as 7-day chunks starting on the 1st:
  /// Wk 1 = days 1–7, Wk 2 = days 8–14, Wk 3 = 15–21, Wk 4 = 22–28,
  /// Wk 5 = days 29–end (only present in months with > 28 days).
  /// Weeks with no transactions are returned with spent = 0.
  Future<List<WeeklyBreakdownModel>> getWeeklyBreakdown(
    String userId,
    int year,
    int month,
  ) async {
    // DateTime(year, month + 1, 0) gives the last day of the month.
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final numWeeks = (daysInMonth / 7).ceil();

    final result = await connection.execute(
      Sql.named(
        'SELECT '
        '  w.week_num, '
        '  COALESCE(SUM(tx.amount), 0) AS spent '
        'FROM generate_series(1, @numWeeks) AS w(week_num) '
        'LEFT JOIN transactions tx '
        '  ON tx.user_id = @userId '
        '  AND EXTRACT(YEAR  FROM tx.transaction_date) = @year '
        '  AND EXTRACT(MONTH FROM tx.transaction_date) = @month '
        '  AND CEIL(EXTRACT(DAY FROM tx.transaction_date) / 7.0)::int = w.week_num '
        'GROUP BY w.week_num '
        'ORDER BY w.week_num',
      ),
      parameters: {
        'userId': userId,
        'year': year,
        'month': month,
        'numWeeks': numWeeks,
      },
    );

    return result.map((row) {
      final weekNum = int.parse(row[0]!.toString());
      final spent = double.parse(row[1]!.toString());
      final startDay = (weekNum - 1) * 7 + 1;
      final endDay = (weekNum * 7).clamp(1, daysInMonth);
      return WeeklyBreakdownModel(
        weekNum: weekNum,
        startDay: startDay,
        endDay: endDay,
        spent: spent,
      );
    }).toList();
  }
}
