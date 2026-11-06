import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for mock authentication in Stark VMS Part 1.
///
/// NOTE: This is an in-memory mock session for the UI prototype, NOT
/// production authentication. Real JWT tokens and Spring Boot backend
/// integration are intentionally reserved for later project phases.
@immutable
class MockAuthState {
  final bool isAuthenticated;
  final String userName;
  final String userEmail;
  final String? errorMessage;

  const MockAuthState({
    required this.isAuthenticated,
    required this.userName,
    required this.userEmail,
    this.errorMessage,
  });

  factory MockAuthState.initial() => const MockAuthState(
        isAuthenticated: false,
        userName: 'John Doe',
        userEmail: 'john.doe@stark.com',
        errorMessage: null,
      );

  MockAuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? userEmail,
    String? errorMessage,
  }) {
    return MockAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage,
    );
  }
}

class MockAuthNotifier extends Notifier<MockAuthState> {
  @override
  MockAuthState build() {
    return MockAuthState.initial();
  }

  /// Perform mock login with basic format validation.
  bool login({required String email, required String password}) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter both email and password.');
      return false;
    }

    state = state.copyWith(
      isAuthenticated: true,
      userEmail: trimmedEmail,
      userName: 'John Doe',
      errorMessage: null,
    );
    return true;
  }

  /// Perform mock sign-up.
  bool signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final name = fullName.trim();
    final mail = email.trim();

    if (name.isEmpty || mail.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'All fields are required.');
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match.');
      return false;
    }

    state = state.copyWith(
      isAuthenticated: true,
      userName: name.isNotEmpty ? name : 'John Doe',
      userEmail: mail,
      errorMessage: null,
    );
    return true;
  }

  /// Clear session and return to login.
  void logout() {
    state = MockAuthState.initial();
  }
}

final mockAuthProvider = NotifierProvider<MockAuthNotifier, MockAuthState>(
  MockAuthNotifier.new,
);

