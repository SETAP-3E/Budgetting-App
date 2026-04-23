import 'package:budgetting_backend/db/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// Root middleware: provides a [Connection] and adds CORS headers.
Handler middleware(Handler handler) {
  return (context) async {
    // Handle CORS preflight requests from Flutter Web.
    if (context.request.method == HttpMethod.options) {
      return Response(
        headers: _corsHeaders,
      );
    }

    final response = await handler
        .use(
          provider<Future<Connection>>((_) async => Database.connection),
        )
        .call(context);

    return response.copyWith(headers: {...response.headers, ..._corsHeaders});
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
