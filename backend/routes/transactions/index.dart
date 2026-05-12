import 'dart:io';

import 'package:budgetting_backend/repositories/category_repository.dart';
import 'package:budgetting_backend/repositories/transaction_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// GET  /transactions — list transactions for the authenticated user
/// POST /transactions — create a new transaction
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getTransactions(context);
    case HttpMethod.post:
      return _createTransaction(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getTransactions(RequestContext context) async {
  final userId = context.read<String>();
  final connection = await context.read<Future<Connection>>();
  final repo = TransactionRepository(connection);

  final accountId =
      context.request.uri.queryParameters['account_id'];
  final transactions = (accountId != null && accountId.isNotEmpty)
      ? await repo.getAccountTransactions(userId, accountId)
      : await repo.getTransactions(userId);

  return Response.json(
    body: transactions.map((t) => t.toJson()).toList(),
  );
}

Future<Response> _createTransaction(RequestContext context) async {
  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;

  final accountId = body['account_id'] as String?;
  final amount = (body['amount'] as num?)?.toDouble();
  final transactionDate = body['transaction_date'] as String?;

  if (accountId == null || amount == null || transactionDate == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'account_id, amount and transaction_date are required',
      },
    );
  }

  if (amount <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'amount must be greater than 0'},
    );
  }

  final latitude = (body['latitude'] as num?)?.toDouble();
  final longitude = (body['longitude'] as num?)?.toDouble();

  if ((latitude == null) != (longitude == null)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'latitude and longitude must both be provided or both omitted',
      },
    );
  }

  final connection = await context.read<Future<Connection>>();
  final categoryRepo = CategoryRepository(connection);
  final transactionRepo = TransactionRepository(connection);

  // Resolve category: use provided category_id or create custom from name.
  final String categoryId;
  final categoryIdParam = body['category_id'] as String?;
  final newCategoryName = body['new_category_name'] as String?;

  if (categoryIdParam != null && categoryIdParam.isNotEmpty) {
    categoryId = categoryIdParam;
  } else if (newCategoryName != null && newCategoryName.isNotEmpty) {
    final category =
        await categoryRepo.findOrCreateCustom(userId, newCategoryName);
    categoryId = category.id;
  } else {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Either category_id or new_category_name is required'},
    );
  }

  final transaction = await transactionRepo.createTransaction(
    userId: userId,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    transactionDate: transactionDate,
    description: body['description'] as String?,
    latitude: latitude,
    longitude: longitude,
  );

  return Response.json(statusCode: 201, body: transaction.toJson());
}
