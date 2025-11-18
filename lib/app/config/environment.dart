final class Environment {
  static const appName = String.fromEnvironment("APP_NAME");
  static const isProduction = bool.fromEnvironment('IS_PRODUCTION');
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
}
