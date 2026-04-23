import 'package:budgetting_backend/db/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// Root middleware: provides a [Connection] to every route handler.
Handler middleware(Handler handler) {
  return handler.use(
    provider<Future<Connection>>((_) async => Database.connection),
  );
}
