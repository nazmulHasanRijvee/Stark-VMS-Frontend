import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logger/app_logger.dart';
import 'secure_token.dart';
import 'token_store.dart';

/// Owns the application's access token in an access-token-only session model.
///
/// [TokenManager] loads, exposes, saves, and clears access tokens.
/// Session changes are broadcast via [sessionStream] for Riverpod and GoRouter.
class TokenManager {
  TokenManager({required this.store}) {
    _ready = _loadTokens();
  }

  final TokenStore store;
  final StreamController<bool> _sessionController =
      StreamController<bool>.broadcast();
  late final Future<void> _ready;
  String? _accessToken;
  int _sessionEpoch = 0;

  /// The current session epoch. Incremented whenever the session is cleared.
  int get sessionEpoch => _sessionEpoch;

  /// Emits `true` when an access token is saved and `false` when cleared.
  Stream<bool> get sessionStream => _sessionController.stream.distinct();

  /// The token used by the access-token interceptor.
  Future<String?> get accessToken async {
    await _ready;
    return _accessToken;
  }

  /// True if an active session exists (i.e. access token is present).
  /// Returns false once a logout occurs or session is cleared.
  bool get hasSession => _accessToken != null && _accessToken!.isNotEmpty;

  /// Saves the given access token to secure storage and memory.
  Future<bool> saveTokens({required String access, int? expectedEpoch}) async {
    await _ready;

    if (expectedEpoch != null && expectedEpoch != _sessionEpoch) {
      return false;
    }

    // Complete storage writes before changing memory, so a failed secure
    // storage write cannot leave the in-memory session ahead of storage.
    await store.write(TokenKey.access, access);
    _accessToken = access;

    _sessionController.add(true);
    return true;
  }

  /// Removes the current session from memory and secure storage.
  Future<void> clearSession() async {
    _sessionEpoch++;
    await _ready;
    await store.clear();
    _accessToken = null;
    _sessionController.add(false);
  }

  /// Closes the session broadcast controller.
  void dispose() {
    _sessionController.close();
  }

  Future<void> _loadTokens() async {
    try {
      _accessToken = await store.read(TokenKey.access);
    } catch (error, stackTrace) {
      AppLogger.error(
        "TokenManager._loadTokens failed",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return SecureTokenStore();
});

final tokenManagerProvider = Provider<TokenManager>((ref) {
  final manager = TokenManager(store: ref.read(tokenStoreProvider));

  ref.onDispose(manager.dispose);
  return manager;
});
