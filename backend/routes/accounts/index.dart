import 'dart:io';

import 'package:budgetting_backend/repositories/account_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// GET  /accounts?user_id=...  — list accounts for a user
/// POST /accounts              — create a new account
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getAccounts(context);
    case HttpMethod.post:
      return _createAccount(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getAccounts(RequestContext context) async {
  final userId = context.request.uri.queryParameters['user_id'];
  if (userId == null || userId.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'user_id query parameter is required'},
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = AccountRepository(connection);
  final accounts = await repo.getAccounts(userId);

  return Response.json(
    body: accounts.map((a) => a.toJson()).toList(),
  );
}

Future<Response> _createAccount(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;

  final userId = body['user_id'] as String?;
  final name = body['name'] as String?;
  final accountType = body['account_type'] as String?;
  final balance = (body['balance'] as num?)?.toDouble();
  final monthlyBudget = (body['monthly_budget'] as num?)?.toDouble();
  final accentColor = body['accent_color'] as int?;

  if (userId == null ||
      name == null ||
      accountType == null ||
      balance == null ||
      monthlyBudget == null ||
      accentColor == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error':
            'user_id, name, account_type, balance, '
            'monthly_budget and accent_color are required',
      },
    );
  }

  const validTypes = ['current', 'savings', 'joint'];
  if (!validTypes.contains(accountType)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'account_type must be current, savings, or joint'},
    );
  }

  if (balance < 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'balance must be >= 0'},
    );
  }

  if (monthlyBudget <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'monthly_budget must be > 0'},
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = AccountRepository(connection);
  final account = await repo.createAccount(
    userId: userId,
    name: name,
    accountType: accountType,
    balance: balance,
    monthlyBudget: monthlyBudget,
    accentColor: accentColor,
  );

  return Response.json(statusCode: 201, body: account.toJson());
}
