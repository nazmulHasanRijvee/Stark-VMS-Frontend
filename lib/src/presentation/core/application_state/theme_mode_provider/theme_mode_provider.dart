import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/services/cache/cache_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final cacheService = ref.watch(cacheServiceProvider);
    final isLoggedIn = cacheService.get<bool>(CacheKey.isLoggedIn) ?? false;
    if (isLoggedIn) {
      final savedTheme = cacheService.get<String>(CacheKey.themeMode);
      if (savedTheme != null) {
        return ThemeMode.values.firstWhere(
          (element) => element.name == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    }
    return ThemeMode.system;
  }

  ThemeMode get themeMode => state;

  List<ThemeMode> get supportedThemes => ThemeMode.values;

  Future<void> changeTheme(ThemeMode newTheme) async {
    state = newTheme;
    final cacheService = ref.read(cacheServiceProvider);
    final isLoggedIn = cacheService.get<bool>(CacheKey.isLoggedIn) ?? false;
    if (isLoggedIn) {
      await _saveTheme(newTheme);
    }
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.save<String>(CacheKey.themeMode, themeMode.name);
  }

  /// Persists current active theme mode to shared_preferences for the logged in user.
  Future<void> persistCurrentTheme() async {
    await _saveTheme(state);
  }

  Future<void> setCurrentThemeMode() async {
    final cacheService = ref.read(cacheServiceProvider);
    final isLoggedIn = cacheService.get<bool>(CacheKey.isLoggedIn) ?? false;
    if (!isLoggedIn) {
      state = ThemeMode.system;
      return;
    }

    final String? themeMode = cacheService.get<String>(CacheKey.themeMode);
    if (themeMode == null) {
      state = ThemeMode.system;
      return;
    }

    state = ThemeMode.values.firstWhere(
      (element) => element.name == themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  /// Clears persisted theme mode from shared_preferences and resets to system default.
  Future<void> clearTheme() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.remove([CacheKey.themeMode]);
    state = ThemeMode.system;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
