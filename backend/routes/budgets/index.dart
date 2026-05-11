import 'dart:io';

import 'package:budgetting_backend/models/budget_item_model.dart';
import 'package:budgetting_backend/repositories/budget_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// GET /budgets?year=...&month=... — budget summary for the authenticated user.
///
/// The `month` param is optional. When omitted the full year is returned.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

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

  return Response.json(
    body: {
      'year': year,
      if (month != null) 'month': month,
      'month_name': monthName,
      'budgets': ranked,
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
