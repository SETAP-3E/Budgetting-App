import 'package:budgetting_backend/config.dart';
import 'package:budgetting_backend/db/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';

/// Root middleware: provides a DB connection, adds CORS headers, and validates
/// JWT tokens for all non-auth routes.
Handler middleware(Handler handler) {
  return (context) async {
    // Handle CORS preflight requests from Flutter Web.
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    // Provide the database connection to all downstream handlers.
    final withDb = handler.use(
      provider<Future<Connection>>((_) async => Database.connection),
    );

    // Auth routes (/auth/login, /auth/signup) are publicly accessible.
    final path = context.request.uri.path;
    if (path.startsWith('/auth')) {
      final response = await withDb(context);
      return response.copyWith(headers: {...response.headers, ..._corsHeaders});
    }

    // All other routes require a valid Bearer token.
    final authHeader = context.request.headers['Authorization'] ?? '';
    if (!authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        headers: _corsHeaders,
        body: {'error': 'Unauthorized'},
      );
    }

    try {
      final jwt = JWT.verify(
        authHeader.substring(7),
        SecretKey(Config.jwtSecret),
      );
      final payload = jwt.payload as Map<String, dynamic>;
      final userId = payload['sub'] as String;

      // Inject the authenticated user's ID for downstream route handlers.
      final withUser = withDb.use(provider<String>((_) => userId));
      final response = await withUser(context);
      return response.copyWith(headers: {...response.headers, ..._corsHeaders});
    } on JWTExpiredException {
      return Response.json(
        statusCode: 401,
        headers: _corsHeaders,
        body: {'error': 'Token expired'},
      );
    } catch (_) {
      return Response.json(
        statusCode: 401,
        headers: _corsHeaders,
        body: {'error': 'Invalid token'},
      );
    }
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
