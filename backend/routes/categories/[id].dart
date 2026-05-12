import 'dart:io';

import 'package:budgetting_backend/repositories/category_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// PUT /categories/[id] — update the name and/or colour of a custom category.
Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
      return _updateCategory(context, id);
    case HttpMethod.delete:
    case HttpMethod.get:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _updateCategory(RequestContext context, String id) async {
  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;
  final name = (body['name'] as String?)?.trim();
  final colourValue = body['colour_value'] as int?;

  if (name == null || name.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name is required'},
    );
  }
  if (name.length < 2 || name.length > 30) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name must be between 2 and 30 characters'},
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = CategoryRepository(connection);

  // Read current colour so callers can omit it.
  final existing = await repo.getCategories(userId);
  final matching = existing.where((c) => c.id == id);
  final current = matching.isEmpty ? null : matching.first;
  final resolvedColour = colourValue ?? current?.colourValue ?? 0xFF9E9E9E;

  final updated = await repo.updateCategory(
    userId,
    id,
    name: name,
    colourValue: resolvedColour,
  );

  if (updated == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Category not found or cannot be edited'},
    );
  }
  return Response.json(body: updated.toJson());
}
