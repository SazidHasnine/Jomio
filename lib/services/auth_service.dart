abstract class IAuthService {
  Future<String?> login(String email, String password);
  Future<String?> register(String email, String password);
  Future<void> logout();
  Stream<String?> get authStateChanges;
}

class FirebaseAuthService implements IAuthService {
  // TODO: Inject real FirebaseAuth instance
  @override
  Future<String?> login(String email, String password) async {
    // Mock login
    return 'mock_user_123';
  }

  @override
  Future<String?> register(String email, String password) async {
    // Mock register
    return 'mock_user_123';
  }

  @override
  Future<void> logout() async {
    // Mock logout
  }

  @override
  Stream<String?> get authStateChanges => Stream.value('mock_user_123'); // Always authenticated for mockup
}
