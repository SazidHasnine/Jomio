import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<String?> login(String email, String password);
  Future<String?> register(String email, String password);
  Future<void> logout();
  Stream<String?> get authStateChanges;
}

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user?.uid;
  }

  @override
  Future<String?> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user?.uid;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Stream<String?> get authStateChanges => _auth.authStateChanges().map((user) => user?.uid);
}
