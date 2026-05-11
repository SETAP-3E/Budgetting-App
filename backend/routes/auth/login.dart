import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:budgetting_backend/config.dart';
import 'package:budgetting_backend/repositories/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';

/// POST /auth/login — validate credentials, return a JWT.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final username = (body['username'] as String?)?.trim();
  final password = body['password'] as String?;

  if (username == null || username.isEmpty || password == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'username and password are required'},
    );
  }

  final connection = await context.read<Future<Connection>>();
  final repo = UserRepository(connection);
  final user = await repo.findByUsername(username);

  // Generic message — never reveal which field is wrong.
  const invalidCredentials = {'error': 'Invalid username or password'};

  if (user == null) {
    return Response.json(statusCode: 401, body: invalidCredentials);
  }

  final passwordCorrect = BCrypt.checkpw(password, user.passwordHash);
  if (!passwordCorrect) {
    return Response.json(statusCode: 401, body: invalidCredentials);
  }

  final token = JWT({'sub': user.id}).sign(
    SecretKey(Config.jwtSecret),
    expiresIn: const Duration(days: 30),
  );

  return Response.json(
    body: {'token': token, 'user_id': user.id, 'username': user.username},
  );
}
