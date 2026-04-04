import 'package:studytrack/core/constants/app_constants.dart';
import 'package:studytrack/models/app_user.dart';

class AuthService {
  final Map<String, _RegisteredUser> _registeredUsers = {};

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(AppConstants.simulatedDelay);

    final normalizedEmail = email.trim().toLowerCase();
    final registeredUser = _registeredUsers[normalizedEmail];

    if (registeredUser == null) {
      throw const AuthException(
        'Usuario nao encontrado. Faca o cadastro antes de entrar.',
      );
    }

    if (registeredUser.password != password.trim()) {
      throw const AuthException('Senha incorreta.');
    }

    return registeredUser.user;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(AppConstants.simulatedDelay);

    final normalizedEmail = email.trim().toLowerCase();
    if (_registeredUsers.containsKey(normalizedEmail)) {
      throw const AuthException('Ja existe um cadastro com este email.');
    }

    _registeredUsers[normalizedEmail] = _RegisteredUser(
      user: AppUser(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      ),
      password: password.trim(),
    );
  }

  Future<void> recoverPassword(String email) async {
    await Future<void>.delayed(AppConstants.simulatedDelay);

    final normalizedEmail = email.trim().toLowerCase();
    if (!_registeredUsers.containsKey(normalizedEmail)) {
      throw const AuthException('Nao existe cadastro para este email.');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _RegisteredUser {
  const _RegisteredUser({
    required this.user,
    required this.password,
  });

  final AppUser user;
  final String password;
}
