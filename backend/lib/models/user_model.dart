import 'package:postgres/postgres.dart';

/// Represents a registered user.
class UserModel {
  /// Create a [UserModel].
  const UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.displayName,
  });

  /// Creates a [UserModel] from a postgres result row.
  factory UserModel.fromRow(ResultRow row) {
    final map = row.toColumnMap();
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      displayName: map['display_name'] as String,
    );
  }

  /// Unique identifier (UUID).
  final String id;

  /// Unique login username (case-insensitive).
  final String username;

  /// bcrypt password hash — never sent to clients.
  final String passwordHash;

  /// Human-readable display name.
  final String displayName;
}
