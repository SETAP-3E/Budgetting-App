import 'package:budgetting_backend/models/user_model.dart';
import 'package:postgres/postgres.dart';

/// Data access for user accounts.
class UserRepository {
  /// Create a [UserRepository] backed by [connection].
  const UserRepository(this.connection);

  /// The active database connection.
  final Connection connection;

  /// Inserts a new user and returns the created row.
  Future<UserModel> createUser({
    required String username,
    required String passwordHash,
    required String displayName,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'INSERT INTO users (username, password_hash, display_name) '
        'VALUES (@username, @passwordHash, @displayName) '
        'RETURNING id, username, password_hash, display_name',
      ),
      parameters: {
        'username': username,
        'passwordHash': passwordHash,
        'displayName': displayName,
      },
    );
    return UserModel.fromRow(result.first);
  }

  /// Returns the user with the given [username] (case-insensitive),
  /// or null if not found.
  Future<UserModel?> findByUsername(String username) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT id, username, password_hash, display_name '
        'FROM users '
        'WHERE lower(username) = lower(@username)',
      ),
      parameters: {'username': username},
    );
    if (result.isEmpty) return null;
    return UserModel.fromRow(result.first);
  }
}
