import 'package:postgres/postgres.dart';

/// A single category's budget goal and actual spend for a period.
class BudgetItemModel {
  /// Create a [BudgetItemModel].
  const BudgetItemModel({
    required this.categoryId,
    required this.name,
    required this.colourValue,
    required this.goalAmount,
    required this.spentAmount,
  });

  /// Creates a [BudgetItemModel] from a postgres result row.
  factory BudgetItemModel.fromRow(ResultRow row) {
    final m = row.toColumnMap();
    return BudgetItemModel(
      categoryId: m['category_id'] as String,
      name: m['name'] as String,
      colourValue: (m['colour_value'] as int?) ?? 0,
      goalAmount: double.parse(m['goal_amount'].toString()),
      spentAmount: double.parse(m['spent_amount'].toString()),
    );
  }

  /// Unique category identifier (UUID).
  final String categoryId;

  /// Category display name.
  final String name;

  /// Flutter ARGB colour integer for UI display.
  final int colourValue;

  /// Budget goal amount for the period.
  final double goalAmount;

  /// Actual amount spent in the period.
  final double spentAmount;

  /// Percentage of goal consumed (0–100+).
  double get percentage =>
      goalAmount > 0 ? spentAmount / goalAmount * 100 : 0;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'name': name,
        'colour_value': colourValue,
        'goal_amount': goalAmount,
        'spent_amount': spentAmount,
        'percentage': percentage,
      };
}
