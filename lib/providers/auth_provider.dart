import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _hasCheckedInitialAuth = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  bool get hasCheckedInitialAuth => _hasCheckedInitialAuth;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (!_hasCheckedInitialAuth) {
        _hasCheckedInitialAuth = true;
      }
      notifyListeners();
    });
  }

  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.registerWithEmailAndPassword(email, password, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return userCredential != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserName(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateUserName(name);
      // Force a refresh of the user data
      _user = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();

      // Explicitly clear user data
      _user = null;
      _hasCheckedInitialAuth = true;
    } catch (e) {
      _error = e.toString();
      print('Error in AuthProvider.signOut: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Manually check the authentication state
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      // The current user will be updated through the authStateChanges listener in _init()
      // This is just to force a refresh of the auth state
      _user = _authService.currentUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
