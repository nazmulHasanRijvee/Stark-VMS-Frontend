class Endpoints {
  static const base = String.fromEnvironment("BASE_URL");

  /// Authentication
  static const String register = '/auth/register/';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh_token/';
}
