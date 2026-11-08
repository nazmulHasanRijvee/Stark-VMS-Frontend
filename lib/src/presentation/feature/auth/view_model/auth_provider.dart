import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../data/repositories/router_repository_impl.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../core/application_state/localization_provider/localization_provider.dart';
import '../../../core/application_state/theme_mode_provider/theme_mode_provider.dart';

/// State representation for authentication in Stark VMS.
@immutable
class AuthState {
  final bool isAuthenticated;
  final String userName;
  final String userEmail;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.isAuthenticated,
    required this.userName,
    required this.userEmail,
    this.errorMessage,
    this.isLoading = false,
  });

  factory AuthState.initial() => const AuthState(
    isAuthenticated: false,
    userName: 'Test User',
    userEmail: 'testuser@gmail.com',
    errorMessage: null,
    isLoading: false,
  );

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? userEmail,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthenticationRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    final cachedName = _repository.getCachedUserName();
    final cachedEmail = _repository.getCachedUserEmail();

    // Check if session exists in router repository
    final routerRepo = ref.watch(routerRepoProvider);
    Future.microtask(() async {
      final hasSession = await routerRepo.hasSession();
      if (hasSession && !state.isAuthenticated) {
        state = state.copyWith(
          isAuthenticated: true,
          userName: cachedName ?? 'Test User',
          userEmail: cachedEmail ?? 'testuser@gmail.com',
        );
      }
    });

    return AuthState(
      isAuthenticated: false,
      userName: cachedName ?? 'Test User',
      userEmail: cachedEmail ?? 'testuser@gmail.com',
      errorMessage: null,
      isLoading: false,
    );
  }

  /// Perform login against the backend REST API.
  Future<bool> login({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter both email and password.',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    bool success = await _repository.login(
      username: trimmedEmail,
      password: password,
    );

    // If demo account and not yet seeded in backend DB, auto-register and retry login
    if (!success &&
        trimmedEmail == 'testuser@gmail.com' &&
        password == 'pass_test123') {
      final regSuccess = await _repository.register(
        fullName: 'Test User',
        email: trimmedEmail,
        password: password,
      );
      if (regSuccess) {
        success = await _repository.login(
          username: trimmedEmail,
          password: password,
        );
      }
    }

    if (success) {
      final cachedName = _repository.getCachedUserName();
      final cachedEmail = _repository.getCachedUserEmail();
      state = state.copyWith(
        isAuthenticated: true,
        userName: cachedName ?? 'Test User',
        userEmail: cachedEmail ?? trimmedEmail,
        errorMessage: null,
        isLoading: false,
      );
      await ref.read(themeModeProvider.notifier).persistCurrentTheme();
      await ref.read(localizationProvider.notifier).persistCurrentLocale();
      return true;
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: _repository.lastError ?? 'Invalid email or password.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Perform sign-up against the backend REST API.
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final name = fullName.trim();
    final mail = email.trim();

    if (name.isEmpty || mail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'All fields are required.',
        isLoading: false,
      );
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(
        errorMessage: 'Passwords do not match.',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final success = await _repository.register(
      fullName: name,
      email: mail,
      password: password,
    );

    if (success) {
      // Auto login after registration
      final loginSuccess = await _repository.login(
        username: mail,
        password: password,
      );
      if (loginSuccess) {
        state = state.copyWith(
          isAuthenticated: true,
          userName: name,
          userEmail: mail,
          errorMessage: null,
          isLoading: false,
        );
        await ref.read(themeModeProvider.notifier).persistCurrentTheme();
        await ref.read(localizationProvider.notifier).persistCurrentLocale();
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } else {
      state = state.copyWith(
        errorMessage: _repository.lastError ?? 'Registration failed.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Clear session and return to login.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    await ref.read(themeModeProvider.notifier).clearTheme();
    await ref.read(localizationProvider.notifier).clearLocale();
    state = AuthState.initial();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
