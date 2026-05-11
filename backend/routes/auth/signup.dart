import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:budgetting_backend/config.dart';
import 'package:budgetting_backend/repositories/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';

/// POST /auth/signup — create a new account, return a JWT.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final username = (body['username'] as String?)?.trim();
  final password = body['password'] as String?;

  // Validate inputs.
  if (username == null || username.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'username is required'},
    );
  }
  if (username.length < 3 || username.length > 30) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'username must be between 3 and 30 characters'},
    );
  }
  if (password == null || password.length < 8) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'password must be at least 8 characters'},
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = UserRepository(connection);

  // Reject duplicate usernames.
  final existing = await repo.findByUsername(username);
  if (existing != null) {
    return Response.json(
      statusCode: 409,
      body: {'error': 'Username already taken'},
    );
  }

  final hash = BCrypt.hashpw(password, BCrypt.gensalt());
  final user = await repo.createUser(
    username: username,
    passwordHash: hash,
    displayName: username,
  );

  final token = JWT({'sub': user.id}).sign(
    SecretKey(Config.jwtSecret),
    expiresIn: const Duration(days: 30),
  );

  return Response.json(
    statusCode: 201,
    body: {'token': token, 'user_id': user.id, 'username': user.username},
  );
}
