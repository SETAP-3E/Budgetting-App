import 'dart:io';

import 'package:budgetting_backend/models/budget_item_model.dart';
import 'package:budgetting_backend/repositories/budget_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// GET  /budgets?year=...&month=... — budget summary for the authenticated user.
/// POST /budgets — create or update a category budget goal.
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getBudgets(context);
    case HttpMethod.post:
      return _upsertBudget(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _upsertBudget(RequestContext context) async {
  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;

  final categoryId = body['category_id'] as String?;
  final year = body['year'] is int
      ? body['year'] as int
      : int.tryParse(body['year'].toString());
  final month = body['month'] is int
      ? body['month'] as int
      : int.tryParse(body['month'].toString());
  final goalAmount = (body['goal_amount'] as num?)?.toDouble();

  if (categoryId == null ||
      year == null ||
      month == null ||
      goalAmount == null ||
      goalAmount <= 0) {
    return Response.json(
      statusCode: 400,
      body: {
        'error':
            'category_id, year, month, and goal_amount (> 0) are required',
      },
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = BudgetRepository(connection);
  await repo.upsertBudget(
    userId: userId,
    categoryId: categoryId,
    year: year,
    month: month,
    goalAmount: goalAmount,
  );
  return Response.json(statusCode: 201, body: {'success': true});
}

Future<Response> _getBudgets(RequestContext context) async {

  final userId = context.read<String>();
  final params = context.request.uri.queryParameters;
  final yearStr = params['year'];
  final monthStr = params['month'];

  if (yearStr == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'year query parameter is required'},
    );
  }

  final year = int.tryParse(yearStr);
  final month = monthStr != null ? int.tryParse(monthStr) : null;

  if (year == null || (monthStr != null && month == null)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'year and month must be integers'},
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = BudgetRepository(connection);

  final List<BudgetItemModel> items;
  final String monthName;

  if (month != null) {
    items = await repo.getBudgetsByMonth(userId, year, month);
    monthName = _monthName(month);
  } else {
    items = await repo.getBudgetsByYear(userId, year);
    monthName = 'YTD';
  }

  final ranked = items.asMap().entries.map((e) {
    final json = e.value.toJson();
    return {...json, 'rank': e.key + 1};
  }).toList();

  final weeklyBreakdown = month != null
      ? (await repo.getWeeklyBreakdown(userId, year, month))
          .map((w) => w.toJson())
          .toList()
      : null;

  return Response.json(
    body: {
      'year': year,
      if (month != null) 'month': month,
      'month_name': monthName,
      'budgets': ranked,
      if (weeklyBreakdown != null) 'weekly_breakdown': weeklyBreakdown,
    },
  );
}

String _monthName(int month) => const [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][month];
