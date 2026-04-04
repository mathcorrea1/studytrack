import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_constants.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/theme/app_theme.dart';
import 'package:studytrack/providers/auth_provider.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/routes/app_router.dart';
import 'package:studytrack/services/auth_service.dart';
import 'package:studytrack/services/mock_study_service.dart';

void main() {
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
          create: (_) => StudyProvider(MockStudyService()),
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
