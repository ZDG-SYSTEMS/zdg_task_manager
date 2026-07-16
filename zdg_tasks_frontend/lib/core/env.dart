/// Build-time environment configuration. Select the target with
/// --dart-define, e.g.:
///   flutter run --dart-define=API_BASE_URL=https://staging.example.com/api
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
}
