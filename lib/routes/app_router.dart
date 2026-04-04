import 'package:flutter/material.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/screens/about/about_screen.dart';
import 'package:studytrack/screens/auth/forgot_password_screen.dart';
import 'package:studytrack/screens/auth/login_screen.dart';
import 'package:studytrack/screens/auth/register_screen.dart';
import 'package:studytrack/screens/home/home_screen.dart';
import 'package:studytrack/screens/study/create_subject_screen.dart';
import 'package:studytrack/screens/study/create_task_screen.dart';
import 'package:studytrack/screens/study/progress_screen.dart';
import 'package:studytrack/screens/study/subject_list_screen.dart';
import 'package:studytrack/screens/study/task_list_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);
      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case AppRoutes.home:
        return _buildRoute(const HomeScreen(), settings);
      case AppRoutes.about:
        return _buildRoute(const AboutScreen(), settings);
      case AppRoutes.createSubject:
        return _buildRoute(const CreateSubjectScreen(), settings);
      case AppRoutes.subjectList:
        return _buildRoute(const SubjectListScreen(), settings);
      case AppRoutes.createTask:
        return _buildRoute(const CreateTaskScreen(), settings);
      case AppRoutes.taskList:
        return _buildRoute(const TaskListScreen(), settings);
      case AppRoutes.progress:
        return _buildRoute(const ProgressScreen(), settings);
      default:
        return _buildRoute(const LoginScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}
