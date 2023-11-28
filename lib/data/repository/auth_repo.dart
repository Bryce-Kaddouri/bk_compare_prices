import 'package:firebase_auth/firebase_auth.dart';
import '../datasource/exception.dart';

class AuthRepo {
  final FirebaseAuth _firebaseAuth;

  AuthRepo(this._firebaseAuth);

  Future<User?> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
  }

  User? get user => _firebaseAuth.currentUser;

  Future<User?> signUp(String email, String password, String name) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firebaseAuth.currentUser!.updateDisplayName(name);
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      HandleException.handleException(e.code, message: e.message);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
