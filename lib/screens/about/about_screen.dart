import 'package:flutter/material.dart';
import 'package:studytrack/core/constants/app_constants.dart';
import 'package:studytrack/widgets/app_logo.dart';
import 'package:studytrack/widgets/info_tile.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          AppLogo(),
          SizedBox(height: 24),
          InfoTile(
            label: 'Nome do app',
            value: AppConstants.appName,
            icon: Icons.apps_rounded,
          ),
          InfoTile(
            label: 'Objetivo',
            value: AppConstants.appGoal,
            icon: Icons.flag_outlined,
          ),
          InfoTile(
            label: 'Integrantes',
            value: AppConstants.studentName,
            icon: Icons.person_outline_rounded,
          ),
          InfoTile(
            label: 'Disciplina',
            value: AppConstants.courseName,
            icon: Icons.class_outlined,
          ),
          InfoTile(
            label: 'Instituicao',
            value: AppConstants.institutionName,
            icon: Icons.account_balance_outlined,
          ),
          InfoTile(
            label: 'Professor',
            value: AppConstants.professorName,
            icon: Icons.badge_outlined,
          ),
          InfoTile(
            label: 'Versao',
            value: AppConstants.appVersion,
            icon: Icons.verified_outlined,
          ),
        ],
      ),
    );
  }
}
