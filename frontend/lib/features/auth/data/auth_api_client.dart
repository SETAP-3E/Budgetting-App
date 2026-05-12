import 'package:budgetting_frontend/core/auth/auth_service.dart';
import 'package:budgetting_frontend/core/network/network_config.dart';
import 'package:dio/dio.dart';

/// Credentials returned after a successful login or signup.
class AuthCredentials {
  /// Create [AuthCredentials].
  const AuthCredentials({
    required this.token,
    required this.userId,
    required this.username,
  });

  /// JWT bearer token.
  final String token;

  /// Authenticated user's UUID.
  final String userId;

  /// Authenticated user's username.
  final String username;
}

/// HTTP client for unauthenticated auth endpoints.
class AuthApiClient {
  /// Create an [AuthApiClient].
  AuthApiClient()
      : _dio = Dio(BaseOptions(baseUrl: NetworkConfig.baseUrl)),
        _authService = AuthService();

  final Dio _dio;
  final AuthService _authService;

  /// Creates a new account and persists the session.
  Future<AuthCredentials> signup({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {'username': username, 'password': password},
    );
    final creds = _fromJson(response.data!);
    await _authService.saveSession(
      token: creds.token,
      userId: creds.userId,
      username: creds.username,
    );
    return creds;
  }

  /// Authenticates with existing credentials and persists the session.
  Future<AuthCredentials> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    final creds = _fromJson(response.data!);
    await _authService.saveSession(
      token: creds.token,
      userId: creds.userId,
      username: creds.username,
    );
    return creds;
  }

  AuthCredentials _fromJson(Map<String, dynamic> json) => AuthCredentials(
        token: json['token'] as String,
        userId: json['user_id'] as String,
        username: json['username'] as String,
      );
}
