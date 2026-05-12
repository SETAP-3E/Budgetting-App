import 'dart:io';

import 'package:budgetting_backend/repositories/category_repository.dart';
import 'package:budgetting_backend/repositories/transaction_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// PUT    /transactions/[id]  — update a transaction
/// DELETE /transactions/[id]  — delete a transaction
Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
      return _updateTransaction(context, id);
    case HttpMethod.delete:
      return _deleteTransaction(context, id);
    case HttpMethod.get:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _updateTransaction(RequestContext context, String id) async {
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

  final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!datePattern.hasMatch(transactionDate)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'transaction_date must be in yyyy-MM-dd format'},
    );
  }

  final latitude = (body['latitude'] as num?)?.toDouble();
  final longitude = (body['longitude'] as num?)?.toDouble();

  if (latitude != null && (latitude < -90 || latitude > 90)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'latitude must be between -90 and 90'},
    );
  }
  if (longitude != null && (longitude < -180 || longitude > 180)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'longitude must be between -180 and 180'},
    );
  }

  if ((latitude == null) != (longitude == null)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error':
            'latitude and longitude must both be provided or both omitted',
      },
    );
  }

  final connection = await context.read<Future<Connection>>();
  final categoryRepo = CategoryRepository(connection);
  final transactionRepo = TransactionRepository(connection);

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

  final transaction = await transactionRepo.updateTransaction(
    id: id,
    userId: userId,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    transactionDate: transactionDate,
    placeName: body['place_name'] as String?,
    latitude: latitude,
    longitude: longitude,
  );

  if (transaction == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Transaction not found'},
    );
  }

  return Response.json(body: transaction.toJson());
}

Future<Response> _deleteTransaction(RequestContext context, String id) async {
  final userId = context.read<String>();
  final connection = await context.read<Future<Connection>>();
  final repo = TransactionRepository(connection);
  final deleted = await repo.deleteTransaction(id: id, userId: userId);

  if (!deleted) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Transaction not found'},
    );
  }

  return Response(statusCode: HttpStatus.noContent);
}
