import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/repository/auth_repo.dart';

class AuthenticationProvider with ChangeNotifier {
  final AuthRepo _authRepo;

  AuthenticationProvider(this._authRepo);

  User? _user;

  User? get user => _user;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    setLoading(true);
    await _authRepo.signIn(email, password);
    _user = _authRepo.user;
    setLoading(false);
  }

  Future<void> signUp(String email, String password, String name) async {
    setLoading(true);
    await _authRepo.signUp(email, password, name);
    _user = _authRepo.user;
    setLoading(false);
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    setLoading(true);
    await _authRepo.sendPasswordResetEmail(email);

    setLoading(false);
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _user = null;
    notifyListeners();
  }

  Stream<User?> get authStateChanges => _authRepo.authStateChanges;

  void init() {
    _user = _authRepo.user;
    notifyListeners();
  }
}
