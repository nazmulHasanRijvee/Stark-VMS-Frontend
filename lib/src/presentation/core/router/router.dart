import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/riverpod_extensions.dart';
import '../../feature/auth/login_screen/view/login_screen.dart';
import '../../feature/auth/signup_screen/view/signup_screen.dart';
import '../../feature/auth/view_model/mock_auth_provider.dart';
import '../../feature/dashboard/view/dashboard_screen.dart';
import '../../feature/onboarding/view/start_today_screen.dart';
import '../../feature/splash/splash_screen/view/splash_screen.dart';
import '../../feature/vehicles/view/vehicle_form_screen.dart';
import '../../feature/vehicles/view/vehicles_screen.dart';
import '../shell/vms_app_shell.dart';
import '../widgets/not_found_screen.dart';
import 'custom_transition_page.dart';
import 'redirect_gate.dart';
import 'routes.dart';

part 'parts/authentication_routes.dart';
part 'parts/onboarding_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'RootNavigator');

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.asListenable(mockAuthProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshListenable,
    initialLocation: Routes.login.path,
    redirect: (context, state) {
      final auth = ref.read(mockAuthProvider);
      return RedirectGate.redirect(
        currentPath: state.uri.path,
        isAuthenticated: auth.isAuthenticated,
      );
    },
    errorBuilder: (context, state) => NotFoundScreen(uri: state.uri),
    routes: [
      // Authentication Routes Part (Login, Sign Up)
      ..._authenticationRoutes(ref),

      // Onboarding & Splash Routes Part
      ..._onboardingRoutes(ref),

      // Authenticated Stateful App Shell (Dashboard & Vehicles)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return VmsAppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard.path,
                name: Routes.dashboard.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),

          // Branch 1: Vehicles & Sub-routes (Register / Edit)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.vehicles.path,
                name: Routes.vehicles.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: VehiclesScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'register',
                    name: Routes.vehicleRegister.name,
                    pageBuilder: (context, state) => buildTransitionPage(
                      child: const VehicleFormScreen(
                        mode: VehicleFormMode.register,
                      ),
                      key: const ValueKey('register_vehicle_screen'),
                      type: AppTransitionType.fade,
                    ),
                  ),
                  GoRoute(
                    path: 'edit/:vehicleNumber',
                    name: Routes.vehicleEdit.name,
                    pageBuilder: (context, state) {
                      final rawNumber = state.pathParameters['vehicleNumber'] ?? '';
                      final vehicleNumber = Uri.decodeComponent(rawNumber);
                      return buildTransitionPage(
                        child: VehicleFormScreen(
                          mode: VehicleFormMode.edit,
                          initialVehicleNumber: vehicleNumber,
                        ),
                        key: ValueKey('edit_vehicle_$vehicleNumber'),
                        type: AppTransitionType.fade,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
