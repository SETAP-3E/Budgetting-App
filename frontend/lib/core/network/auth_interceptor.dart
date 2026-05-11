import 'package:budgetting_frontend/core/auth/auth_notifier.dart';
import 'package:dio/dio.dart';

/// Attaches the Bearer token to every outgoing request.
/// On 401 responses, clears the session and redirects to /login via [AuthNotifier].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.authNotifier});

  final AuthNotifier authNotifier;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authNotifier.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      authNotifier.notifyLogout();
    }
    handler.next(err);
  }
}
