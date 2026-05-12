/// A single week's spending within a monthly budget period.
class WeeklyBreakdownModel {
  /// Create a [WeeklyBreakdownModel].
  const WeeklyBreakdownModel({
    required this.weekNum,
    required this.startDay,
    required this.endDay,
    required this.spent,
  });

  /// Week number within the month (1–5).
  final int weekNum;

  /// First day-of-month in this week (1-based).
  final int startDay;

  /// Last day-of-month in this week (inclusive).
  final int endDay;

  /// Total amount spent in this week.
  final double spent;

  /// Serialise to JSON.
  Map<String, dynamic> toJson() => {
        'week': weekNum,
        'start_day': startDay,
        'end_day': endDay,
        'spent': spent,
      };
}
