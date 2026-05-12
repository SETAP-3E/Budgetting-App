/// Shared network configuration used by all API clients.
class NetworkConfig {
  NetworkConfig._();

  /// Base URL for the backend API.
  ///
  /// Reads the compile-time variable API_BASE_URL if supplied
  /// (e.g. `--dart-define=API_BASE_URL=https://api.example.com`),
  /// defaulting to localhost for local development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
