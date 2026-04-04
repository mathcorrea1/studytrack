import 'package:flutter/material.dart';
import 'package:studytrack/models/app_user.dart';
import 'package:studytrack/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _currentUser = AppUser(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recoverPassword(String email) async {
    _setLoading(true);

    try {
      await _authService.recoverPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
