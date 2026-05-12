import 'package:budgetting_frontend/core/network/auth_interceptor.dart';
import 'package:budgetting_frontend/core/network/network_config.dart';
import 'package:budgetting_frontend/core/router/app_router.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:dio/dio.dart';

/// HTTP client for the transactions, categories, and places API endpoints.
class TransactionsApiClient {
  /// Create a [TransactionsApiClient].
  TransactionsApiClient()
      : _dio = Dio(BaseOptions(baseUrl: NetworkConfig.baseUrl)) {
    _dio.interceptors.add(AuthInterceptor(authNotifier: authNotifier));
  }

  final Dio _dio;

  /// Fetches all categories available to the authenticated user.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/categories');
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  /// Fetches all transactions for the authenticated user, newest first.
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _dio.get<List<dynamic>>('/transactions');

    return (response.data ?? []).cast<Map<String, dynamic>>().map((json) {
      return TransactionModel(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        categoryId: json['category_id'] as String,
        accountName: json['account_name'] as String?,
        amount: (json['amount'] as num).toDouble(),
        categoryName: json['category_name'] as String,
        location: json['place_name'] as String?,
        date: DateTime.parse(json['transaction_date'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  /// Posts a new transaction to the API.
  Future<void> createTransaction({
    required double amount,
    required String transactionDate,
    required String accountId,
    String? categoryId,
    String? newCategoryName,
    String? placeName,
    double? latitude,
    double? longitude,
  }) async {
    await _dio.post<void>(
      '/transactions',
      data: {
        'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        if (newCategoryName != null) 'new_category_name': newCategoryName,
        'amount': amount,
        if (placeName != null && placeName.isNotEmpty) 'place_name': placeName,
        'transaction_date': transactionDate,
        if (latitude != null && longitude != null) 'latitude': latitude,
        if (latitude != null && longitude != null) 'longitude': longitude,
      },
    );
  }

  /// Updates an existing transaction.
  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String transactionDate,
    required String accountId,
    String? categoryId,
    String? newCategoryName,
    String? placeName,
    double? latitude,
    double? longitude,
  }) async {
    await _dio.put<void>(
      '/transactions/$id',
      data: {
        'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        if (newCategoryName != null) 'new_category_name': newCategoryName,
        'amount': amount,
        if (placeName != null && placeName.isNotEmpty) 'place_name': placeName,
        'transaction_date': transactionDate,
        if (latitude != null && longitude != null) 'latitude': latitude,
        if (latitude != null && longitude != null) 'longitude': longitude,
      },
    );
  }

  /// Deletes a transaction by [id].
  Future<void> deleteTransaction(String id) async {
    await _dio.delete<void>('/transactions/$id');
  }

  /// Returns place autocomplete suggestions from the backend Places proxy.
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
