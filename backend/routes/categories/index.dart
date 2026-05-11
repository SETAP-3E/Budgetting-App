import 'package:budgetting_backend/repositories/category_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// GET /categories — all categories available to the authenticated user.
///
/// Returns predefined categories plus any custom ones belonging to the user,
/// ordered predefined-first then alphabetically.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final userId = context.read<String>();

  try {
    final connection = await context.read<Future<Connection>>();
    final repo = CategoryRepository(connection);
    final categories = await repo.getCategories(userId);
    return Response.json(body: categories.map((c) => c.toJson()).toList());
  } catch (e, st) {
    print('ERROR in /categories: $e\n$st');
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
