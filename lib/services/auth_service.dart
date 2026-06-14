import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:studytrack/models/app_user.dart';

class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final firebase_auth.FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  firebase_auth.FirebaseAuth get auth =>
      _firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  FirebaseFirestore get db => _firestore ?? FirebaseFirestore.instance;

  firebase_auth.User? get firebaseUser => auth.currentUser;

  String? get currentUserId => firebaseUser?.uid;

  Future<AppUser?> currentAppUser() async {
    final user = firebaseUser;
    if (user == null) {
      return null;
    }

    final snapshot = await db.collection('usuarios').doc(user.uid).get();
    final data = snapshot.data();
    if (data == null) {
      return AppUser(
        uid: user.uid,
        name: user.displayName ?? 'Estudante',
        email: user.email ?? '',
        phone: '',
        createdAt: DateTime.now(),
      );
    }

    return AppUser.fromMap(data);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Nao foi possivel autenticar o usuario.');
      }

      final appUser = await currentAppUser();
      if (appUser == null) {
        throw const AuthException('Dados do usuario nao encontrados.');
      }

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error));
    } catch (error) {
      if (error is AuthException) {
        rethrow;
      }
      throw AuthException(_mapUnknownError(error));
    }
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Nao foi possivel criar o usuario.');
      }

      final appUser = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );

      await user.updateDisplayName(appUser.name);
      await db.collection('usuarios').doc(user.uid).set({
        'uid': appUser.uid,
        'name': appUser.name,
        'email': appUser.email,
        'phone': appUser.phone,
        'createdAt': FieldValue.serverTimestamp(),
        'searchName': appUser.name.toLowerCase(),
      });

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error));
    } catch (error) {
      if (error is AuthException) {
        rethrow;
      }
      throw AuthException(_mapUnknownError(error));
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error));
    } catch (error) {
      throw AuthException(_mapUnknownError(error));
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  String _mapAuthError(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Informe um email valido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Email ou senha invalidos.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Ja existe um cadastro com este email.';
      case 'weak-password':
        return 'A senha informada e muito fraca.';
      case 'network-request-failed':
        return 'Falha de conexao. Verifique sua internet.';
      default:
        return error.message ?? 'Erro de autenticacao. Tente novamente.';
    }
  }

  String _mapUnknownError(Object error) {
    final message = error.toString();
    if (message.contains('Firebase ainda nao configurado') ||
        message.contains('No Firebase App')) {
      return 'Firebase nao configurado. Rode o FlutterFire CLI antes de usar o app.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
