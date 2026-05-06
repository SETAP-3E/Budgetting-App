import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:dio/dio.dart';

/// HTTP client for the transactions, categories, and places API endpoints.
///
/// Uses hardcoded dev UUIDs until real authentication is implemented.
class TransactionsApiClient {
  /// Create a [TransactionsApiClient].
  TransactionsApiClient() : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static const String _baseUrl = 'http://localhost:8080';

  /// Dev user UUID — matches the seeded record in [database/seeds/dev_seed.sql].
  static const String devUserId = '00000000-0000-0000-0000-000000000001';

  /// Dev account UUID — matches the seeded record in
  /// [database/seeds/dev_seed.sql].
  static const String devAccountId = '00000000-0000-0000-0000-000000000002';

  final Dio _dio;

  /// Fetches all categories available to the dev user.
  ///
  /// Returns a list of maps with keys: id, name, icon, colour_value,
  /// is_predefined.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dio.get<List<dynamic>>(
      '/categories',
      queryParameters: {'user_id': devUserId},
    );
    return (response.data ?? [])
        .cast<Map<String, dynamic>>();
  }

  /// Fetches all transactions for the dev user, newest first.
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _dio.get<List<dynamic>>(
      '/transactions',
      queryParameters: {'user_id': devUserId},
    );

    return (response.data ?? []).cast<Map<String, dynamic>>().map((json) {
      return TransactionModel(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        accountName: json['account_name'] as String?,
        amount: (json['amount'] as num).toDouble(),
        categoryName: json['category_name'] as String,
        location: json['description'] as String?,
        date: DateTime.parse(json['transaction_date'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  /// Posts a new transaction to the API.
  ///
  /// Provide either [categoryId] (for an existing category) or
  /// [newCategoryName] (to create a custom one on the fly).
  /// If [latitude] and [longitude] are provided they must both be non-null.
  Future<void> createTransaction({
    required double amount,
    required String transactionDate,
    required String accountId,
    String? categoryId,
    String? newCategoryName,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    await _dio.post<void>(
      '/transactions',
      data: {
        'user_id': devUserId,
        'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        if (newCategoryName != null) 'new_category_name': newCategoryName,
        'amount': amount,
        if (description != null && description.isNotEmpty)
          'description': description,
        'transaction_date': transactionDate,
        if (latitude != null && longitude != null) 'latitude': latitude,
        if (latitude != null && longitude != null) 'longitude': longitude,
      },
    );
  }

  /// Returns place autocomplete suggestions from the backend Places proxy.
  ///
  /// Each item has `place_id` and `description` keys.
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/places/autocomplete',
      queryParameters: {'q': query},
    );
    return ((response.data?['predictions'] as List<dynamic>?) ?? [])
        .cast<Map<String, dynamic>>();
  }

  /// Returns the name, latitude, and longitude for a Google place ID.
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/places/details',
      queryParameters: {'place_id': placeId},
    );
    return response.data ?? {};
  }
}
