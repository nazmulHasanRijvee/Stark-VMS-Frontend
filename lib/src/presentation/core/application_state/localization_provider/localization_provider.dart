import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/locale_repository_impl.dart';
import '../../../../data/services/cache/cache_service.dart';

class LocalizationNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final cacheService = ref.watch(cacheServiceProvider);
    final isLoggedIn = cacheService.get<bool>(CacheKey.isLoggedIn) ?? false;
    if (isLoggedIn) {
      final savedLang = cacheService.get<String>(CacheKey.language);
      if (savedLang != null && savedLang.isNotEmpty) {
        return Locale(savedLang);
      }
    }
    return const Locale('en');
  }

  Future<void> changeLocale(Locale locale) async {
    state = locale;
    final cacheService = ref.read(cacheServiceProvider);
    final isLoggedIn = cacheService.get<bool>(CacheKey.isLoggedIn) ?? false;
    if (isLoggedIn) {
      final repo = ref.read(localeRepositoryProvider);
      await repo.setLanguage(locale.languageCode);
    }
  }

  /// Persists current active locale to shared_preferences for the logged in user.
  Future<void> persistCurrentLocale() async {
    final repo = ref.read(localeRepositoryProvider);
    await repo.setLanguage(state.languageCode);
  }

  Future<void> setCurrentLocale() async {
    final cacheService = ref.read(cacheServiceProvider);
    final isLoggedIn = cacheService.get<bool>(CacheKey.isLoggedIn) ?? false;
    if (!isLoggedIn) {
      state = const Locale('en');
      return;
    }

    final repo = ref.read(localeRepositoryProvider);
    final language = await repo.getLanguage();
    state = Locale(language);
  }

  /// Clears persisted locale from shared_preferences and resets to default (English).
  Future<void> clearLocale() async {
    final repo = ref.read(localeRepositoryProvider);
    await repo.clearLanguage();
    state = const Locale('en');
  }
}

final localizationProvider = NotifierProvider<LocalizationNotifier, Locale>(
  LocalizationNotifier.new,
);
