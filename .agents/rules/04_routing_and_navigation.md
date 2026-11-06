# Rule: Routing & Navigation with go_router

Stark VMS utilizes **declarative, reactive state-driven routing** with `go_router`.

## 1. Defining Routes in `Routes` Enum

All route names and paths MUST be defined in `lib/src/presentation/core/router/routes.dart`:

```dart
enum Routes {
  splash('/splash'),
  onboarding('/onboarding'),
  login('/login'),
  register('/register_screen'),

  // VMS Core Routes
  homeScreen('/home_screen'),
  vehicles('/vehicles'),
  vehicleDetails('/vehicles/detail'),
  drivers('/drivers'),
  maintenance('/maintenance'),
  dispatch('/dispatch');

  const Routes(this.path);
  final String path;
}
```

## 2. Gating and Redirection via `RedirectGate`

The navigation gate destination is computed reactively by `routerStateProvider`:
- Startup pending/failed ➡️ `Routes.splash`
- Onboarding incomplete ➡️ `Routes.onboarding`
- Unauthenticated ➡️ `Routes.login`
- Authenticated ➡️ `Routes.homeScreen`

The actual routing redirect logic is completely pure in `RedirectGate.redirect(String path, Routes gate)`:
- `_isAuthFlowPath(path)`: checks if the path belongs to unauthenticated flow (login, register, forgot password).
- `_isGateOnlyPath(path)`: checks if the path is splash, onboarding, auth flow, or `/`. Authenticated users attempting to visit gate-only paths are redirected to `Routes.homeScreen`.
- Always verify idempotency: Never redirect to the path currently being visited (`path == gate.path ? null : gate.path`).

## 3. Modular Route Parts

Do NOT dump all routes in `router.dart`. Divide routes into parts inside `lib/src/presentation/core/router/parts/`:
- `authentication_routes.dart`
- `onboarding_routes.dart`
- `vehicle_routes.dart`
- `driver_routes.dart`

Example:
```dart
part of '../router.dart';

List<GoRoute> _vehicleRoutes(Ref ref) {
  return [
    GoRoute(
      path: Routes.vehicles.path,
      name: Routes.vehicles.name,
      pageBuilder: (context, state) => buildTransitionPage(
        child: const VehiclesScreen(),
        key: ValueKey(Routes.vehicles.name),
        type: AppTransitionType.fade,
      ),
      routes: [
        GoRoute(
          path: ':id',
          name: Routes.vehicleDetails.name,
          pageBuilder: (context, state) => buildTransitionPage(
            child: VehicleDetailsScreen(vehicleId: state.pathParameters['id']!),
            key: ValueKey('${Routes.vehicleDetails.name}_${state.pathParameters['id']}'),
          ),
        ),
      ],
    ),
  ];
}
```

Include part files in `router.dart` and append them to `routes: <RouteBase>[...]`.

## 4. Custom Page Transitions

Always wrap route screen widgets using `buildTransitionPage` from `lib/src/presentation/core/router/custom_transition_page.dart`:
Supported `AppTransitionType`:
- `rightToLeft` (default slide transition)
- `leftToRight`
- `bottomToTop`
- `topToBottom`
- `fade` (recommended for desktop/web tabs and dashboard navigation)
- `scale`
- `none`

## 5. Web Error Handling

`GoRouter.errorBuilder` is wired to `NotFoundScreen(uri: state.uri)`. If a user enters an invalid URL or a broken deep link, `NotFoundScreen` displays the broken URI and a button navigating to `Routes.homeScreen`.

