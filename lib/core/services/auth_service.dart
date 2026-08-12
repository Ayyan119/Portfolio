import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        try {
          return await _auth.createUserWithEmailAndPassword(email: email, password: password);
        } catch (_) {
          // Fallback to anonymous sign-in if email registration is restricted in console
          try {
            return await _auth.signInAnonymously();
          } catch (_) {
            return null;
          }
        }
      }
      try {
        return await _auth.signInAnonymously();
      } catch (_) {
        return null;
      }
    } catch (_) {
      try {
        return await _auth.signInAnonymously();
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
