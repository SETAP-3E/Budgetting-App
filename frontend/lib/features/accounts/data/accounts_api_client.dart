import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// HTTP client for the accounts API endpoints.
class AccountsApiClient {
  /// Create an [AccountsApiClient].
  AccountsApiClient() : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static const String _baseUrl = 'http://localhost:8080';

  /// Dev user UUID — matches the seeded record in database/seeds/dev_seed.sql.
  static const String devUserId = '00000000-0000-0000-0000-000000000001';

  final Dio _dio;

  /// Fetches all active accounts for the dev user.
  Future<List<AccountModel>> getAccounts() async {
    final response = await _dio.get<List<dynamic>>(
      '/accounts',
      queryParameters: {'user_id': devUserId},
    );
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
        'user_id': devUserId,
        'name': name,
        'account_type': type.name,
        'balance': balance,
        'monthly_budget': monthlyBudget,
        'accent_color': accentColor.toARGB32(),
      },
    );
    return _fromJson(response.data!);
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
        accentColor: Color(json['accent_color'] as int),
      );
}
