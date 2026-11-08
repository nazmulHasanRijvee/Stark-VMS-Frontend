abstract interface class AuthenticationRepository {
  Future<bool> login({
    required String username,
    required String password,
    bool shouldRemember = true,
  });

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<bool> rememberMe({bool? rememberMe});

  Future<bool> logout();

  /// Called once at startup. Clears tokens left from a previous run when the
  /// user did not choose to keep the session across restarts.
  Future<bool> restoreSession();

  String? get lastError;

  String? getCachedUserName();

  String? getCachedUserEmail();
}
