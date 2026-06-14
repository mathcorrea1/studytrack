# StudyTrack

Aplicativo Flutter para organizacao de estudos com `Provider`,
rotas centralizadas, Firebase Authentication, Cloud Firestore,
Firebase Hosting e consumo da API publica Open Library.

## Comandos principais

```bash
flutter pub get
flutterfire configure
flutter run
flutter build web
firebase deploy --only firestore,hosting
```

## Configuracao externa obrigatoria

1. Criar um projeto no Firebase.
2. Ativar Authentication com provedor Email/senha.
3. Criar o Cloud Firestore.
4. Rodar `flutterfire configure` para substituir `lib/firebase_options.dart`
   pelas credenciais reais.
5. Publicar no Firebase Hosting apos `flutter build web`.
