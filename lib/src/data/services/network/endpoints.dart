class Endpoints {
  static const base = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://stark-vms-backend-yxhg.onrender.com/api/v1',
  );

  /// Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  /// Vehicles
  static const String vehicles = '/vehicles';

  /// Dashboard
  static const String dashboardStats = '/dashboard/stats';
}
