import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/primary_button.dart';

class CreateSubjectScreen extends StatefulWidget {
  const CreateSubjectScreen({super.key});

  @override
  State<CreateSubjectScreen> createState() => _CreateSubjectScreenState();
}

class _CreateSubjectScreenState extends State<CreateSubjectScreen> {
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _hoursController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _handleCreateSubject() {
    final errorMessage =
        AppValidators.requiredField(_nameController.text, 'nome da materia') ??
            AppValidators.requiredField(
              _teacherController.text,
              'professor',
            ) ??
            AppValidators.requiredField(_hoursController.text, 'carga horaria');

    if (errorMessage != null) {
      SnackBarUtils.show(context, errorMessage, isError: true);
      return;
    }

    final studyHours = int.tryParse(_hoursController.text.trim());
    if (studyHours == null || studyHours <= 0) {
      SnackBarUtils.show(
        context,
        'Informe uma carga horaria semanal valida.',
        isError: true,
      );
      return;
    }

    context.read<StudyProvider>().addSubject(
          name: _nameController.text,
          teacher: _teacherController.text,
          studyHoursPerWeek: studyHours,
        );

    SnackBarUtils.show(context, 'Materia criada com sucesso.');
    Navigator.pushReplacementNamed(context, AppRoutes.subjectList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar materia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nome da materia',
                  prefixIcon: Icons.book_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _teacherController,
                  label: 'Professor',
                  prefixIcon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _hoursController,
                  label: 'Horas de estudo por semana',
                  prefixIcon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Salvar materia',
                  icon: Icons.save_outlined,
                  onPressed: _handleCreateSubject,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

