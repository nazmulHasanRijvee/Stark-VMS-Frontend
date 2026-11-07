import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_vms/src/presentation/feature/auth/view_model/mock_auth_provider.dart';

void main() {
  group('MockAuthProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is unauthenticated', () {
      final state = container.read(mockAuthProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('login with valid credentials succeeds', () {
      final notifier = container.read(mockAuthProvider.notifier);
      final success = notifier.login(
        email: 'admin@stark.com',
        password: 'password123',
      );

      expect(success, isTrue);
      final state = container.read(mockAuthProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.userEmail, 'admin@stark.com');
    });

    test('login with invalid credentials fails and sets error', () {
      final notifier = container.read(mockAuthProvider.notifier);
      final success = notifier.login(
        email: 'wrong@user.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      final state = container.read(mockAuthProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, isNotNull);
    });

    test('signup creates account and logs in', () {
      final notifier = container.read(mockAuthProvider.notifier);
      final success = notifier.signUp(
        fullName: 'Tony Stark',
        email: 'tony@stark.com',
        password: 'ironmansecret',
        confirmPassword: 'ironmansecret',
      );

      expect(success, isTrue);
      final state = container.read(mockAuthProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.userName, 'Tony Stark');
      expect(state.userEmail, 'tony@stark.com');
    });

    test('logout clears user state', () {
      final notifier = container.read(mockAuthProvider.notifier);
      notifier.login(email: 'admin@stark.com', password: 'password123');
      expect(container.read(mockAuthProvider).isAuthenticated, isTrue);

      notifier.logout();
      expect(container.read(mockAuthProvider).isAuthenticated, isFalse);
    });
  });
}
