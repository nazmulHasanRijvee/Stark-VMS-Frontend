import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stark_vms/src/data/repositories/auth_repository_impl.dart';
import 'package:stark_vms/src/data/services/cache/cache_service.dart';
import 'package:stark_vms/src/domain/repositories/auth_repository.dart';
import 'package:stark_vms/src/presentation/feature/auth/view_model/auth_provider.dart';

class InMemoryAuthRepository implements AuthenticationRepository {
  final Map<String, String> _users = {'existing@stark.com': 'password123'};
  String? _currentUser;
  String? _lastError;

  @override
  String? get lastError => _lastError;

  @override
  Future<bool> login({
    required String username,
    required String password,
    bool shouldRemember = true,
  }) async {
    _lastError = null;
    if (_users[username] == password) {
      _currentUser = username;
      return true;
    }
    _lastError = 'Invalid email or password.';
    return false;
  }

  @override
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _lastError = null;
    if (_users.containsKey(email)) {
      _lastError = 'Email already in use';
      return false;
    }
    _users[email] = password;
    return true;
  }

  @override
  Future<bool> logout() async {
    _currentUser = null;
    return true;
  }

  @override
  Future<bool> rememberMe({bool? rememberMe}) async => true;

  @override
  Future<bool> restoreSession() async => _currentUser != null;

  @override
  String? getCachedUserName() => _currentUser != null ? 'Test User' : null;

  @override
  String? getCachedUserEmail() => _currentUser;
}

void main() {
  group('AuthProvider (Backend Integration)', () {
    late ProviderContainer container;
    late InMemoryAuthRepository authRepo;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      authRepo = InMemoryAuthRepository();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is unauthenticated', () {
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
    });

    test('login with valid credentials succeeds', () async {
      final notifier = container.read(authProvider.notifier);
      final success = await notifier.login(
        email: 'existing@stark.com',
        password: 'password123',
      );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.userEmail, 'existing@stark.com');
    });

    test('login with invalid credentials fails and sets error', () async {
      final notifier = container.read(authProvider.notifier);
      final success = await notifier.login(
        email: 'wrong@user.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, isNotNull);
    });

    test('demo account testuser@gmail.com auto-registers and logs in', () async {
      final notifier = container.read(authProvider.notifier);
      final success = await notifier.login(
        email: 'testuser@gmail.com',
        password: 'pass_test123',
      );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.userEmail, 'testuser@gmail.com');
    });

    test('signup creates account and logs in', () async {
      final notifier = container.read(authProvider.notifier);
      final success = await notifier.signUp(
        fullName: 'Tony Stark',
        email: 'tony@stark.com',
        password: 'ironmansecret',
        confirmPassword: 'ironmansecret',
      );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.userEmail, 'tony@stark.com');
    });

    test('logout clears user state', () async {
      final notifier = container.read(authProvider.notifier);
      await notifier.login(
        email: 'existing@stark.com',
        password: 'password123',
      );
      expect(container.read(authProvider).isAuthenticated, isTrue);

      await notifier.logout();
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });
  });
}
