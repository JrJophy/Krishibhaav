import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../app_router.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _userRole;
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  String? get userRole => _userRole;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      _userId = user.uid;
    }
  }

  String _mapFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This mobile number is already registered. Try signing in instead.';
        case 'user-not-found':
          return 'No account found with this mobile number.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect mobile number or password.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  Future<bool> register({
    required String name,
    required String mobile,
    required String password,
    required String role,
    required String location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = await _authService.registerUser(
        name: name,
        mobile: mobile,
        password: password,
        role: role,
        location: location,
      );
      _userId = uid;
      _userRole = role;
      return true;
    } catch (e) {
      _errorMessage = _mapFirebaseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String mobile, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userRole = await _authService.signIn(mobile: mobile, password: password);
      _userId = _authService.getCurrentUser()?.uid;
      return true;
    } catch (e) {
      _errorMessage = _mapFirebaseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.signOut();
    _userRole = null;
    _userId = null;
    _errorMessage = null;
    
    resetAuthCache();
    
    _isLoading = false;
    notifyListeners();
  }
}
