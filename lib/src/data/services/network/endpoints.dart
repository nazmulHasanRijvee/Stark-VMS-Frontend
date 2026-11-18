class Endpoints {
  static const base = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  ); // https://stark-vms-backend-yxhg.onrender.com/api/v1

  /// Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  /// Vehicles
  static const String vehicles = '/vehicles';
  static const String vehicleDriver = '/vehicles/{vehicleNumber}/driver';
  static const String vehicleDocuments = '/vehicles/{vehicleNumber}/documents';
  static const String documentDownload =
      '/vehicles/{vehicleNumber}/documents/{documentId}/download';
  static const String vehicleMaintenance =
      '/vehicles/{vehicleNumber}/maintenance';

  /// Drivers
  static const String drivers = '/drivers';

  /// Dashboard
  static const String dashboardStats = '/dashboard/stats';
}
