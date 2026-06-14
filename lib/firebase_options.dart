import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase ainda nao configurado. Rode `flutterfire configure` para gerar '
      'lib/firebase_options.dart com as credenciais reais do seu projeto.',
    );
  }

  static bool get isConfigured {
    try {
      currentPlatform;
      return true;
    } on UnsupportedError {
      debugPrint(
        'Firebase nao configurado. Substitua lib/firebase_options.dart pelo '
        'arquivo gerado pelo FlutterFire CLI.',
      );
      return false;
    }
  }
}
