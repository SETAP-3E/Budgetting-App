/// Lightweight model for a category returned by GET /categories.
class CategoryItem {
  /// Create a [CategoryItem].
  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.colourValue,
  });

  /// Deserialise from the API response.
  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        colourValue: json['colour_value'] as int,
      );

  /// Unique category identifier.
  final String id;

  /// Display name of the category.
  final String name;

  /// Material icon name string (e.g. 'shopping_bag').
  final String icon;

  /// Flutter ARGB colour integer.
  final int colourValue;
}

/// One week's spending within a monthly period.
class WeeklySpendingItem {
  /// Create a [WeeklySpendingItem].
  const WeeklySpendingItem({
    required this.weekNum,
    required this.startDay,
    required this.endDay,
    required this.spent,
  });

  /// Deserialise from the API response.
  factory WeeklySpendingItem.fromJson(Map<String, dynamic> json) =>
      WeeklySpendingItem(
        weekNum: json['week'] as int,
        startDay: json['start_day'] as int,
        endDay: json['end_day'] as int,
        spent: (json['spent'] as num).toDouble(),
      );

  /// Week number within the month (1–5).
  final int weekNum;

  /// First day-of-month in this week.
  final int startDay;

  /// Last day-of-month in this week (inclusive).
  final int endDay;

  /// Total amount spent in this week.
  final double spent;
}

/// A single category's budget goal and actual spend for a period.
class BudgetItemModel {
  /// Create a [BudgetItemModel].
  const BudgetItemModel({
    required this.categoryId,
    required this.name,
    required this.colourValue,
    required this.goalAmount,
    required this.spentAmount,
    required this.rank,
  });

  /// Creates a [BudgetItemModel] from a JSON map.
  factory BudgetItemModel.fromJson(Map<String, dynamic> json) =>
      BudgetItemModel(
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        colourValue: json['colour_value'] as int,
        goalAmount: (json['goal_amount'] as num).toDouble(),
        spentAmount: (json['spent_amount'] as num).toDouble(),
        rank: json['rank'] as int,
      );

  /// Unique category identifier.
  final String categoryId;

  /// Category display name.
  final String name;

  /// Flutter ARGB colour integer.
  final int colourValue;

  /// Budget goal amount for the period.
  final double goalAmount;

  /// Actual amount spent in the period.
  final double spentAmount;

  /// Rank position within the period (1 = highest goal).
  final int rank;

  /// Percentage of goal consumed (0–100+).
  double get percentage =>
      goalAmount > 0 ? spentAmount / goalAmount * 100 : 0;
}

/// Aggregated budget summary for a time period.
class BudgetSummaryModel {
  /// Create a [BudgetSummaryModel].
  const BudgetSummaryModel({
    required this.year,
    required this.monthName,
    required this.budgets,
    this.month,
    this.weeklyBreakdown,
  });

  /// The calendar year.
  final int year;

  /// Month number (1–12), or null for a full-year view.
  final int? month;

  /// Display name for the month: e.g. "May" or "YTD".
  final String monthName;

  /// Per-category budget items, ordered by goal amount descending.
  final List<BudgetItemModel> budgets;

  /// Per-week spending totals (only present for monthly requests).
  final List<WeeklySpendingItem>? weeklyBreakdown;

  /// Sum of all category goal amounts.
  double get totalGoal =>
      budgets.fold(0, (sum, b) => sum + b.goalAmount);

  /// Sum of all category spent amounts.
  double get totalSpent =>
      budgets.fold(0, (sum, b) => sum + b.spentAmount);

  /// Remaining budget (totalGoal − totalSpent).
  double get totalRemaining => totalGoal - totalSpent;
}
