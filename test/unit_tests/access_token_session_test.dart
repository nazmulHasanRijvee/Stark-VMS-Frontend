import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stark_vms/src/data/repositories/auth_repository_impl.dart';
import 'package:stark_vms/src/data/repositories/router_repository_impl.dart';
import 'package:stark_vms/src/data/services/cache/cache_service.dart';
import 'package:stark_vms/src/data/services/network/auth/token_manager.dart';
import 'package:stark_vms/src/data/services/network/auth/token_store.dart';
import 'package:stark_vms/src/data/services/network/rest_client.dart';

class InMemoryTokenStore implements TokenStore {
  final Map<TokenKey, String> _store = {};

  @override
  Future<String?> read(TokenKey key) async => _store[key];

  @override
  Future<void> write(TokenKey key, String value) async => _store[key] = value;

  @override
  Future<void> delete(TokenKey key) async => _store.remove(key);

  @override
  Future<void> clear() async => _store.clear();
}

class InMemoryCacheService implements CacheService {
  final Map<CacheKey, dynamic> _cache = {};

  @override
  Future<void> save<T>(CacheKey key, T value) async => _cache[key] = value;

  @override
  T? get<T>(CacheKey key) => _cache[key] as T?;

  @override
  Future<void> remove(List<CacheKey> keys) async {
    for (final key in keys) {
      _cache.remove(key);
    }
  }

  @override
  Future<void> clear() async => _cache.clear();
}

class FakeRestClient implements RestClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpResponse<dynamic>> login(Map<String, dynamic> request) async {
    return HttpResponse({
      'accessToken': 'fake_access_token_123',
      'user': {'name': 'John Doe'},
    }, Response(requestOptions: RequestOptions(), statusCode: 200));
  }
}

void main() {
  group('Access-Token-Only Session & TokenManager', () {
    late InMemoryTokenStore tokenStore;
    late TokenManager tokenManager;

    setUp(() {
      tokenStore = InMemoryTokenStore();
      tokenManager = TokenManager(store: tokenStore);
    });

    tearDown(() {
      tokenManager.dispose();
    });

    test('initial state has no session', () async {
      expect(tokenManager.hasSession, isFalse);
      expect(await tokenManager.accessToken, isNull);
    });

    test('saveTokens stores access token and activates session', () async {
      final sessionEvents = <bool>[];
      final subscription = tokenManager.sessionStream.listen(sessionEvents.add);

      final saved = await tokenManager.saveTokens(
        access: 'stark_jwt_access_abc',
      );

      expect(saved, isTrue);
      expect(tokenManager.hasSession, isTrue);
      expect(await tokenManager.accessToken, equals('stark_jwt_access_abc'));

      // Wait a microtask for stream event
      await Future<void>.delayed(Duration.zero);
      expect(sessionEvents, contains(true));

      await subscription.cancel();
    });

    test('clearSession removes access token and deactivates session', () async {
      await tokenManager.saveTokens(access: 'stark_jwt_access_abc');
      expect(tokenManager.hasSession, isTrue);

      final sessionEvents = <bool>[];
      final subscription = tokenManager.sessionStream.listen(sessionEvents.add);

      await tokenManager.clearSession();

      expect(tokenManager.hasSession, isFalse);
      expect(await tokenManager.accessToken, isNull);

      await Future<void>.delayed(Duration.zero);
      expect(sessionEvents, contains(false));

      await subscription.cancel();
    });
  });

  group('RouterRepositoryImpl Session Integration', () {
    test('hasSession checks access token presence', () async {
      final tokenStore = InMemoryTokenStore();
      final tokenManager = TokenManager(store: tokenStore);
      final cacheService = InMemoryCacheService();
      final routerRepo = RouterRepositoryImpl(
        cacheService: cacheService,
        tokens: tokenManager,
      );

      expect(await routerRepo.hasSession(), isFalse);

      await tokenManager.saveTokens(access: 'test_token');
      expect(await routerRepo.hasSession(), isTrue);

      await tokenManager.clearSession();
      expect(await routerRepo.hasSession(), isFalse);

      tokenManager.dispose();
    });
  });

  group('AuthenticationRepositoryImpl Access-Token-Only Flow', () {
    test('login saves access token only', () async {
      final tokenStore = InMemoryTokenStore();
      final tokenManager = TokenManager(store: tokenStore);
      final cacheService = InMemoryCacheService();
      final authRepo = AuthenticationRepositoryImpl(
        remote: FakeRestClient(),
        local: cacheService,
        tokens: tokenManager,
      );

      final loggedIn = await authRepo.login(
        username: 'admin@stark.com',
        password: 'password123',
      );

      expect(loggedIn, isTrue);
      expect(await tokenManager.accessToken, equals('fake_access_token_123'));
      expect(tokenManager.hasSession, isTrue);

      tokenManager.dispose();
    });

    test('logout clears tokens and cache session', () async {
      final tokenStore = InMemoryTokenStore();
      final tokenManager = TokenManager(store: tokenStore);
      final cacheService = InMemoryCacheService();
      final authRepo = AuthenticationRepositoryImpl(
        remote: FakeRestClient(),
        local: cacheService,
        tokens: tokenManager,
      );

      await tokenManager.saveTokens(access: 'token_to_clear');
      await cacheService.save(CacheKey.isLoggedIn, true);

      final loggedOut = await authRepo.logout();
      expect(loggedOut, isTrue);
      expect(await tokenManager.accessToken, isNull);
      expect(tokenManager.hasSession, isFalse);
      expect(cacheService.get<bool>(CacheKey.isLoggedIn), isNull);

      tokenManager.dispose();
    });

    test('restoreSession validates both cache and access token', () async {
      final tokenStore = InMemoryTokenStore();
      final tokenManager = TokenManager(store: tokenStore);
      final cacheService = InMemoryCacheService();
      final authRepo = AuthenticationRepositoryImpl(
        remote: FakeRestClient(),
        local: cacheService,
        tokens: tokenManager,
      );

      // 1. Neither present -> false
      expect(await authRepo.restoreSession(), isFalse);

      // 2. Token present but not remembered -> clears token and returns false
      await tokenManager.saveTokens(access: 'dangling_token');
      expect(await authRepo.restoreSession(), isFalse);
      expect(await tokenManager.accessToken, isNull);

      // 3. Both present -> returns true
      await cacheService.save(CacheKey.isLoggedIn, true);
      await tokenManager.saveTokens(access: 'valid_token');
      expect(await authRepo.restoreSession(), isTrue);
      expect(tokenManager.hasSession, isTrue);

      tokenManager.dispose();
    });
  });
}
