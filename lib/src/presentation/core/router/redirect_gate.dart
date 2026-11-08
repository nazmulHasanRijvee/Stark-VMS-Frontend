import 'routes.dart';

/// Pure redirect logic for Stark VMS.
///
/// Has zero dependency on BuildContext or Ref, making it 100% unit-testable.
abstract final class RedirectGate {
  /// Evaluates target path against authentication status.
  static String? redirect({
    required String currentPath,
    required bool isAuthenticated,
  }) {
    final isAuthFlow =
        currentPath == Routes.login.path || currentPath == Routes.signup.path;

    if (!isAuthenticated) {
      // Unauthenticated users are allowed on login & signup, otherwise sent to login
      if (isAuthFlow) return null;
      return Routes.login.path;
    }

    // Authenticated users landing on login, signup, or root '/' are redirected to dashboard
    if (isAuthFlow || currentPath == '/') {
      return Routes.dashboard.path;
    }

    // Allow all other routes
    return null;
  }
}
