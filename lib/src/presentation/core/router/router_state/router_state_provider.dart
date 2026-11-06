import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feature/onboarding/view_model/onboarding_status_provider.dart';
import '../../application_state/session_status_provider/session_status_provider.dart';
import '../../application_state/startup_provider/startup_provider.dart';
import '../routes.dart';

/// The gate destination the go_router enforces, based on app startup,
/// onboarding, and session status.
final routerStateProvider = Provider<Routes>((ref) {
  final startup = ref.watch(startupProvider);
  if (startup.isLoading || startup.hasError) return Routes.splash;

  if (!ref.watch(onboardingStatusProvider)) return Routes.onboarding;

  final session = ref.watch(sessionStatusProvider);
  return switch (session) {
    AsyncData(value: SessionStatus.authenticated) => Routes.dashboard,
    AsyncData() => Routes.login,
    _ => Routes.splash,
  };
});
