import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;

  AuthViewModel({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get user => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String _errorMessage = '';
  bool _isLoading = false;

  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<UserCredential?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _errorMessage = '';
      return cred;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Erreur de connexion';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _errorMessage = '';
      return cred;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Erreur d\'inscription';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
