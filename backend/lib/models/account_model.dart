import 'package:postgres/postgres.dart';

/// Represents a single account stored in the database.
class AccountModel {
  /// Create an [AccountModel].
  const AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.accountType,
    required this.balance,
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.weeklySpent,
    required this.accentColor,
  });

  /// Creates an [AccountModel] from a postgres result row.
  ///
  /// Expects monthly_spent as a computed column (subquery or 0 from RETURNING).
  factory AccountModel.fromRow(ResultRow row) {
    final map = row.toColumnMap();
    return AccountModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      accountType: map['account_type'] as String,
      balance: double.parse(map['balance'].toString()),
      monthlyBudget: double.parse(map['monthly_budget'].toString()),
      monthlySpent: double.parse(map['monthly_spent'].toString()),
      weeklySpent: double.parse(map['weekly_spent'].toString()),
      accentColor: map['accent_color'] as int,
    );
  }

  /// Unique identifier (UUID).
  final String id;

  /// ID of the owning user.
  final String userId;

  /// Human-readable account name.
  final String name;

  /// Account category: 'current', 'savings', or 'joint'.
  final String accountType;

  /// Current balance in GBP.
  final double balance;

  /// Planned monthly spending budget.
  final double monthlyBudget;

  /// Total spent this calendar month (computed from transactions).
  final double monthlySpent;

  /// Total spent in the current week of this calendar month.
  final double weeklySpent;

  /// Flutter ARGB color integer for UI display.
  final int accentColor;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'account_type': accountType,
        'balance': balance,
        'monthly_budget': monthlyBudget,
        'monthly_spent': monthlySpent,
        'weekly_spent': weeklySpent,
        'accent_color': accentColor,
      };
}
