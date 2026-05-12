import 'package:budgetting_frontend/core/network/auth_interceptor.dart';
import 'package:budgetting_frontend/core/network/network_config.dart';
import 'package:budgetting_frontend/core/router/app_router.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// A single transaction belonging to a specific account, used in the detail
/// screen to show recent activity and category spending.
class AccountTransactionItem {
  /// Create an [AccountTransactionItem].
  const AccountTransactionItem({
    required this.id,
    required this.categoryName,
    required this.amount,
    required this.date,
    this.location,
  });

  /// Unique transaction identifier.
  final String id;

  /// Name of the spending category.
  final String categoryName;

  /// Transaction amount in GBP.
  final double amount;

  /// Date the transaction occurred.
  final DateTime date;

  /// Place name entered when the transaction was recorded.
  final String? location;
}

/// HTTP client for the accounts API endpoints.
class AccountsApiClient {
  /// Create an [AccountsApiClient].
  AccountsApiClient()
      : _dio = Dio(BaseOptions(baseUrl: NetworkConfig.baseUrl)) {
    _dio.interceptors.add(AuthInterceptor(authNotifier: authNotifier));
  }

  final Dio _dio;

  /// Fetches all active accounts for the authenticated user.
  Future<List<AccountModel>> getAccounts() async {
    final response = await _dio.get<List<dynamic>>('/accounts');
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(_fromJson)
        .toList();
  }

  /// Creates a new account and returns the saved model.
  Future<AccountModel> createAccount({
    required String name,
    required AccountType type,
    required double balance,
    required double monthlyBudget,
    required Color accentColor,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/accounts',
      data: {
        'name': name,
        'account_type': type.name,
        'balance': balance,
        'monthly_budget': monthlyBudget,
        'accent_color': accentColor.toARGB32(),
      },
    );
    return _fromJson(response.data!);
  }

  /// Fetches all transactions for [accountId], newest first.
  Future<List<AccountTransactionItem>> getAccountTransactions(
    String accountId,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/transactions',
      queryParameters: {'account_id': accountId},
    );
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(
          (j) => AccountTransactionItem(
            id: j['id'] as String,
            categoryName: j['category_name'] as String,
            amount: (j['amount'] as num).toDouble(),
            date: DateTime.parse(j['transaction_date'] as String),
            location: j['place_name'] as String?,
          ),
        )
        .toList();
  }

  AccountModel _fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: AccountType.values.firstWhere(
          (t) => t.name == json['account_type'],
          orElse: () => AccountType.current,
        ),
        balance: (json['balance'] as num).toDouble(),
        monthlyBudget: (json['monthly_budget'] as num).toDouble(),
        monthlySpent: (json['monthly_spent'] as num).toDouble(),
        weeklySpent: (json['weekly_spent'] as num).toDouble(),
        accentColor: Color(json['accent_color'] as int),
      );
}
