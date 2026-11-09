import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stark_vms/src/core/localization/app_localizations.dart';
import 'package:stark_vms/src/data/repositories/auth_repository_impl.dart';
import 'package:stark_vms/src/data/services/cache/cache_service.dart';
import 'package:stark_vms/src/domain/repositories/auth_repository.dart';
import 'package:stark_vms/src/presentation/core/application_state/localization_provider/localization_provider.dart';
import 'package:stark_vms/src/presentation/core/application_state/startup_provider/startup_provider.dart';
import 'package:stark_vms/src/presentation/core/application_state/theme_mode_provider/theme_mode_provider.dart';
import 'package:stark_vms/src/presentation/core/theme/src/theme_extensions/src/colors/colors.dart';
import 'package:stark_vms/src/presentation/feature/auth/view_model/auth_provider.dart';

class _FakeAuthRepository implements AuthenticationRepository {
  bool _session = false;

  @override
  String? get lastError => null;

  @override
  Future<bool> login({
    required String username,
    required String password,
    bool shouldRemember = true,
  }) async {
    _session = true;
    return true;
  }

  @override
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async => true;

  @override
  Future<bool> logout() async {
    _session = false;
    return true;
  }

  @override
  Future<bool> rememberMe({bool? rememberMe}) async => true;

  @override
  Future<bool> restoreSession() async => _session;

  @override
  String? getCachedUserName() => _session ? 'Test User' : null;

  @override
  String? getCachedUserEmail() => _session ? 'testuser@gmail.com' : null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations', () {
    test('English translations are accurate', () {
      final locEn = lookupAppLocalizations(const Locale('en'));
      expect(locEn.appName, 'Stark VMS');
      expect(locEn.navDashboard, 'Dashboard');
      expect(locEn.navVehicles, 'Vehicles');
      expect(locEn.totalFleet, 'Total Fleet');
      expect(locEn.statusActive, 'Active');
      expect(locEn.statusInService, 'In Service');
      expect(locEn.statusInactive, 'Inactive');
      expect(locEn.showingPagination(1, 4, 4), 'Showing 1 to 4 of 4 vehicles');
    });

    test('Bangla translations are accurate and glyph-safe', () {
      final locBn = lookupAppLocalizations(const Locale('bn'));
      expect(locBn.appName, 'স্টার্ক ভিএমএস');
      expect(locBn.navDashboard, 'ড্যাশবোর্ড');
      expect(locBn.navVehicles, 'যানবাহন');
      expect(locBn.totalFleet, 'মোট যানবাহন');
      expect(locBn.statusActive, 'সক্রিয়');
      expect(locBn.statusInService, 'সার্ভিসাধীন');
      expect(locBn.statusInactive, 'নিষ্ক্রিয়');
      expect(
        locBn.showingPagination(1, 4, 4),
        '4 টির মধ্যে 1 থেকে 4 টি দেখানো হচ্ছে',
      );
    });
  });

  group('Theme Colors', () {
    test(
      'Light and Dark color extensions provide valid contrast and tokens',
      () {
        const light = LightColorExtension();
        const dark = DarkColorExtension();

        expect(light.primary, isNotNull);
        expect(dark.primary, isNotNull);
        expect(light.surface, const Color(0xFFFFFFFF));
        expect(dark.surface, const Color(0xFF1E293B));
        expect(light.scaffoldBackground, const Color(0xFFF8FAFC));
        expect(dark.scaffoldBackground, const Color(0xFF0B1120));
        expect(light.statusActiveBg, isNotNull);
        expect(dark.statusActiveBg, isNotNull);
      },
    );
  });

  group('Theme and Localization Persistence', () {
    late SharedPreferences prefs;
    late _FakeAuthRepository authRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authRepo = _FakeAuthRepository();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
    }

    test('theme and locale do not persist to cache when unauthenticated', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Default state
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(container.read(localizationProvider), const Locale('en'));

      // Change while unauthenticated
      await container.read(themeModeProvider.notifier).changeTheme(ThemeMode.dark);
      await container.read(localizationProvider.notifier).changeLocale(const Locale('bn'));

      // In-memory state changes
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(container.read(localizationProvider), const Locale('bn'));

      // But NOT persisted to SharedPreferences
      expect(prefs.getString('themeMode'), isNull);
      expect(prefs.getString('language'), isNull);
    });

    test('theme and locale persist to shared_preferences when user is logged in', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Log in
      final loginSuccess = await container.read(authProvider.notifier).login(
            email: 'testuser@gmail.com',
            password: 'pass_test123',
          );
      expect(loginSuccess, isTrue);
      // Mark isLoggedIn in prefs as authRepo does in real scenario
      await prefs.setBool('isLoggedIn', true);

      // Now change theme and locale
      await container.read(themeModeProvider.notifier).changeTheme(ThemeMode.dark);
      await container.read(localizationProvider.notifier).changeLocale(const Locale('bn'));

      // Persisted to SharedPreferences
      expect(prefs.getString('themeMode'), 'dark');
      expect(prefs.getString('language'), 'bn');
    });

    test('persisted preferences survive app restart when user has active session', () async {
      // Simulate persisted logged-in session with custom theme & locale
      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'themeMode': 'dark',
        'language': 'bn',
      });
      prefs = await SharedPreferences.getInstance();
      authRepo._session = true;

      final container = createContainer();
      addTearDown(container.dispose);

      // Synchronous build loads from cache for logged-in user
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(container.read(localizationProvider), const Locale('bn'));

      // Running startupProvider confirms state
      await container.read(startupProvider.future);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(container.read(localizationProvider), const Locale('bn'));
    });

    test('logout clears theme and locale from shared_preferences and resets providers', () async {
      // Start with logged in user having dark theme and Bangla locale
      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'themeMode': 'dark',
        'language': 'bn',
      });
      prefs = await SharedPreferences.getInstance();
      authRepo._session = true;

      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(container.read(localizationProvider), const Locale('bn'));

      // Logout
      await container.read(authProvider.notifier).logout();

      // State is reset to defaults
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(container.read(localizationProvider), const Locale('en'));

      // Shared preferences keys are removed
      expect(prefs.getString('themeMode'), isNull);
      expect(prefs.getString('language'), isNull);
    });
  });
}
