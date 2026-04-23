/// Represents a single expense transaction.
class TransactionModel {
  /// Create a [TransactionModel].
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryName,
    required this.date,
    this.location,
  });

  /// Unique identifier for this transaction.
  final String id;

  /// Amount spent in GBP (must be > 0).
  final double amount;

  /// Optional rough location description (e.g. "Tesco, High Street").
  final String? location;

  /// Name of the spending category (predefined or custom).
  final String categoryName;

  /// Date the expense occurred.
  final DateTime date;
}
