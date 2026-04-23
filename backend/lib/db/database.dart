import 'dart:io';

import 'package:postgres/postgres.dart';

/// Manages the singleton PostgreSQL connection for the application.
///
/// Reads connection parameters from environment variables so the same
/// binary works in both local dev and Docker environments.
class Database {
  Database._();

  static Connection? _connection;

  /// Returns the shared [Connection], opening it on first call.
  static Future<Connection> get connection async {
    if (_connection != null) return _connection!;

    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 5433;
    final database = Platform.environment['DB_NAME'] ?? 'budgetting';
    final username = Platform.environment['DB_USER'] ?? 'budgetting_user';
    final password = Platform.environment['DB_PASSWORD'] ?? 'changeme';

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    return _connection!;
  }
}
