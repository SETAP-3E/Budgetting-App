import 'package:postgres/postgres.dart';

/// Represents a single expense transaction stored in the database.
class TransactionModel {
  /// Create a [TransactionModel].
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.transactionDate,
    this.description,
    this.latitude,
    this.longitude,
  });

  /// Creates a [TransactionModel] from a postgres result row.
  ///
  /// Expects the row to include a joined `category_name` column.
  factory TransactionModel.fromRow(ResultRow row) {
    final map = row.toColumnMap();
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String,
      amount: double.parse(map['amount'].toString()),
      description: map['description'] as String?,
      transactionDate: (map['transaction_date'] as DateTime)
          .toIso8601String()
          .substring(0, 10),
      latitude: map['latitude'] != null
          ? double.parse(map['latitude'].toString())
          : null,
      longitude: map['longitude'] != null
          ? double.parse(map['longitude'].toString())
          : null,
    );
  }

  /// Unique identifier (UUID).
  final String id;

  /// ID of the owning user.
  final String userId;

  /// ID of the associated account.
  final String accountId;

  /// ID of the spending category.
  final String categoryId;

  /// Resolved category name (from JOIN).
  final String categoryName;

  /// Amount spent in GBP.
  final double amount;

  /// Optional description or location note.
  final String? description;

  /// Date of the expense in ISO-8601 format (yyyy-MM-dd).
  final String transactionDate;

  /// Latitude of the transaction location (from Google Places).
  final double? latitude;

  /// Longitude of the transaction location (from Google Places).
  final double? longitude;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'account_id': accountId,
        'category_id': categoryId,
        'category_name': categoryName,
        'amount': amount,
        'description': description,
        'transaction_date': transactionDate,
        'latitude': latitude,
        'longitude': longitude,
      };
}
