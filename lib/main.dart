import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_constants.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/theme/app_theme.dart';
import 'package:studytrack/firebase_options.dart';
import 'package:studytrack/providers/auth_provider.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/routes/app_router.dart';
import 'package:studytrack/services/auth_service.dart';
import 'package:studytrack/services/study_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError catch (error) {
    debugPrint(error.toString());
  } catch (error) {
    debugPrint('Falha ao inicializar Firebase: $error');
  }

  runApp(const StudyTrackApp());
}

class StudyTrackApp extends StatelessWidget {
  const StudyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProvider<StudyProvider>(
          create: (_) => StudyProvider(StudyService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
