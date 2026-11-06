part of "../router.dart";

List<GoRoute> _authenticationRoutes(Ref ref) {
  return [
    GoRoute(
      path: Routes.login.path,
      name: Routes.login.name,
      pageBuilder: (context, state) => buildTransitionPage(
        child: const LoginScreen(),
        key: ValueKey(Routes.login.name),
        type: AppTransitionType.fade,
      ),
    ),
    GoRoute(
      path: Routes.signup.path,
      name: Routes.signup.name,
      pageBuilder: (context, state) => buildTransitionPage(
        child: const SignUpScreen(),
        key: ValueKey(Routes.signup.name),
        type: AppTransitionType.fade,
      ),
    ),
  ];
}
