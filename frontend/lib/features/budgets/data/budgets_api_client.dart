import 'package:budgetting_frontend/core/network/auth_interceptor.dart';
import 'package:budgetting_frontend/core/router/app_router.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:dio/dio.dart';

/// HTTP client for the budgets API endpoint.
class BudgetsApiClient {
  /// Create a [BudgetsApiClient].
  BudgetsApiClient() : _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080')) {
    _dio.interceptors.add(AuthInterceptor(authNotifier: authNotifier));
  }

  final Dio _dio;

  /// Fetches budget summary for [year] and optionally [month].
  ///
  /// When [month] is null the full year is returned.
  Future<BudgetSummaryModel> getBudgets({
    required int year,
    int? month,
  }) async {
    final params = <String, String>{
      'year': year.toString(),
      if (month != null) 'month': month.toString(),
    };
    final response = await _dio.get<Map<String, dynamic>>(
      '/budgets',
      queryParameters: params,
    );
    final json = response.data!;
    final budgets = (json['budgets'] as List)
        .map(
          (item) =>
              BudgetItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return BudgetSummaryModel(
      year: json['year'] as int,
      month: json['month'] as int?,
      monthName: json['month_name'] as String,
      budgets: budgets,
    );
  }
}
