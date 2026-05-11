import 'package:budgetting_frontend/core/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Holds in-memory auth state and notifies GoRouter when it changes.
///
/// The token is kept in memory so interceptors can read it synchronously,
/// avoiding any async secure-storage race on the first request after login.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() : _authService = AuthService();

  final AuthService _authService;
  bool isAuthenticated = false;

  /// The current bearer token, held in memory for instant interceptor access.
  String? token;

  /// Call once at startup to sync state from secure storage.
  Future<void> init() async {
    token = await _authService.getToken();
    isAuthenticated = token != null;
  }

  /// Call after a successful login or signup, passing the received token.
  void notifyLogin({required String newToken}) {
    token = newToken;
    isAuthenticated = true;
    notifyListeners();
  }

  Future<void> notifyLogout() async {
    token = null;
    await _authService.clearSession();
    isAuthenticated = false;
    notifyListeners();
  }
}
