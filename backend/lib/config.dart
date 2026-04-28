import 'dart:io';

/// Application config read from environment variables.
///
/// In Docker, vars are injected by Compose. In local dev, falls back to
/// parsing the `.env` file from the repo root so no manual export is needed.
class Config {
  Config._();

  static final Map<String, String> _env = _load();

  static Map<String, String> _load() {
    // If the key is already in the process environment (Docker / exported
    // shell var) use that directly — no file parsing needed.
    if (Platform.environment.containsKey('GOOGLE_PLACES_API_KEY')) {
      return Platform.environment;
    }

    // dart_frog dev runs with the backend/ dir as cwd, so ../.env is the
    // repo-root .env file.
    final file = File('../.env');
    if (!file.existsSync()) return Platform.environment;

    final merged = <String, String>{...Platform.environment};
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final idx = line.indexOf('=');
      if (idx < 1) continue;
      final key = line.substring(0, idx).trim();
      final value = line.substring(idx + 1).trim();
      merged.putIfAbsent(key, () => value);
    }
    return merged;
  }

  /// Google Places API key (server-side). Never sent to the browser.
  static String? get placesApiKey => _env['GOOGLE_PLACES_API_KEY'];
}
