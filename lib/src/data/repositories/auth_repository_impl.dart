import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../services/cache/cache_service.dart';
import '../services/network/api_handler.dart';
import '../services/network/auth/token_manager.dart';
import '../services/network/rest_client.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl({
    required this.remote,
    required this.local,
    required this.tokens,
  });

  final RestClient remote;
  final CacheService local;
  final TokenManager tokens;

  String? _lastError;

  @override
  String? get lastError => _lastError;

  @override
  Future<bool> login({
    required String username,
    required String password,
    bool shouldRemember = true,
  }) async {
    bool loggedIn = false;
    _lastError = null;

    await Api.call(
      action: remote.login({'username': username, 'password': password}),
      onSuccess: (response) async {
        final dataMap = response is Map<String, dynamic>
            ? response
            : <String, dynamic>{};
        final innerData = dataMap['data'] is Map<String, dynamic>
            ? dataMap['data'] as Map<String, dynamic>
            : dataMap;

        final accessToken = innerData['accessToken'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          await tokens.saveTokens(access: accessToken);
        }

        // Cache user info if present
        final user = innerData['user'] as Map<String, dynamic>?;
        final fullName = user?['fullName'] as String? ?? 'User';
        final email = user?['email'] as String? ?? username;
        await local.save(CacheKey.user, '$fullName|$email');

        if (shouldRemember) {
          try {
            await _saveSession();
          } catch (_) {
            await tokens.clearSession();
            rethrow;
          }
        }

        loggedIn = true;
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return loggedIn;
  }

  @override
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    bool registered = false;
    _lastError = null;

    await Api.call(
      action: remote.register({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
      onSuccess: (response) async {
        registered = true;
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return registered;
  }

  Future<void> _saveSession() async {
    await local.save(CacheKey.isLoggedIn, true);
  }

  @override
  Future<bool> rememberMe({bool? rememberMe}) async {
    if (rememberMe == null) {
      /// Defaults to true
      return local.get<bool>(CacheKey.rememberMe) ?? true;
    }

    await local.save(CacheKey.rememberMe, rememberMe);
    return rememberMe;
  }

  @override
  Future<bool> restoreSession() async {
    final remembered = local.get<bool>(CacheKey.isLoggedIn) ?? false;

    final accessToken = await tokens.accessToken;
    final hasSession = accessToken != null && accessToken.isNotEmpty;

    if (!remembered && hasSession) {
      await tokens.clearSession();
    }
    return remembered && hasSession;
  }

  @override
  Future<bool> logout() async {
    await local.remove([
      CacheKey.isLoggedIn,
      CacheKey.rememberMe,
      CacheKey.user,
      CacheKey.themeMode,
      CacheKey.language,
    ]);
    await tokens.clearSession();
    return true;
  }

  @override
  String? getCachedUserName() {
    final raw = local.get<String>(CacheKey.user);
    if (raw == null || !raw.contains('|')) return null;
    final parts = raw.split('|');
    return parts.first.trim().isNotEmpty ? parts.first.trim() : null;
  }

  @override
  String? getCachedUserEmail() {
    final raw = local.get<String>(CacheKey.user);
    if (raw == null || !raw.contains('|')) return null;
    final parts = raw.split('|');
    return parts.length > 1 && parts[1].trim().isNotEmpty
        ? parts[1].trim()
        : null;
  }
}

final authRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  return AuthenticationRepositoryImpl(
    remote: ref.watch(restClientProvider),
    local: ref.watch(cacheServiceProvider),
    tokens: ref.watch(tokenManagerProvider),
  );
});
