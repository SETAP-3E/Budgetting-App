/// Represents a single expense transaction.
class TransactionModel {
  /// Create a [TransactionModel].
  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.categoryName,
    required this.date,
    this.location,
    this.latitude,
    this.longitude,
  });

  /// Unique identifier for this transaction.
  final String id;

  /// ID of the account this transaction was paid from.
  final String accountId;

  /// Amount spent in GBP (must be > 0).
  final double amount;

  /// Human-readable place name (e.g. "Tesco Warwick"), set via Places search.
  final String? location;

  /// Name of the spending category (predefined or custom).
  final String categoryName;

  /// Date the expense occurred.
  final DateTime date;

  /// Latitude of the transaction location.
  final double? latitude;

  /// Longitude of the transaction location.
  final double? longitude;
}
