import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/models/study_session.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/empty_state_card.dart';
import 'package:studytrack/widgets/primary_button.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedSubjectId;
  double _focusScore = 4;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    final errorMessage =
        AppValidators.requiredField(_titleController.text, 'titulo') ??
            AppValidators.requiredField(_minutesController.text, 'minutos') ??
            AppValidators.requiredField(_notesController.text, 'anotacoes');

    if (errorMessage != null) {
      SnackBarUtils.show(context, errorMessage, isError: true);
      return;
    }

    if (_selectedSubjectId == null) {
      SnackBarUtils.show(context, 'Selecione uma materia.', isError: true);
      return;
    }

    final minutes = int.tryParse(_minutesController.text.trim());
    if (minutes == null || minutes <= 0) {
      SnackBarUtils.show(context, 'Informe minutos validos.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<StudyProvider>().addSession(
            subjectId: _selectedSubjectId!,
            title: _titleController.text,
            minutes: minutes,
            focusScore: _focusScore.round(),
            notes: _notesController.text,
          );
    } catch (error) {
      if (!mounted) {
        return;
      }
      SnackBarUtils.show(context, error.toString(), isError: true);
      setState(() => _isSaving = false);
      return;
    }

    if (!mounted) {
      return;
    }

    _titleController.clear();
    _minutesController.clear();
    _notesController.clear();
    setState(() => _isSaving = false);
    SnackBarUtils.show(context, 'Sessao registrada com sucesso.');
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sessoes de estudo')),
      body: StreamBuilder<List<Subject>>(
        stream: studyProvider.subjectsStream(),
        builder: (context, subjectSnapshot) {
          if (subjectSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (subjectSnapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar materias: ${subjectSnapshot.error}'),
            );
          }

          final subjects = subjectSnapshot.data ?? const <Subject>[];
          if (_selectedSubjectId == null && subjects.isNotEmpty) {
            _selectedSubjectId = subjects.first.id;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (subjects.isEmpty)
                Column(
                  children: [
                    const EmptyStateCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Nenhuma materia disponivel',
                      subtitle:
                          'Cadastre uma materia antes de registrar sessoes.',
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.createSubject),
                      child: const Text('Criar materia agora'),
                    ),
                  ],
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Materia',
                            prefixIcon: Icon(Icons.bookmarks_outlined),
                          ),
                          items: subjects
                              .map(
                                (subject) => DropdownMenuItem<String>(
                                  value: subject.id,
                                  child: Text(subject.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedSubjectId = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _titleController,
                          label: 'Titulo da sessao',
                          prefixIcon: Icons.timer_outlined,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _minutesController,
                          label: 'Minutos estudados',
                          prefixIcon: Icons.schedule_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Text('Foco: ${_focusScore.round()}/5'),
                        Slider(
                          value: _focusScore,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '${_focusScore.round()}',
                          onChanged: (value) {
                            setState(() => _focusScore = value);
                          },
                        ),
                        AppTextField(
                          controller: _notesController,
                          label: 'Anotacoes',
                          prefixIcon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Registrar sessao',
                          icon: Icons.save_alt_rounded,
                          isLoading: _isSaving,
                          onPressed: _saveSession,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              StreamBuilder<List<StudySession>>(
                stream: studyProvider.sessionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Erro ao recuperar sessoes: ${snapshot.error}');
                  }

                  final sessions = snapshot.data ?? const <StudySession>[];
                  if (sessions.isEmpty) {
                    return const EmptyStateCard(
                      icon: Icons.timer_outlined,
                      title: 'Nenhuma sessao registrada',
                      subtitle:
                          'Registre sessoes para acompanhar tempo e foco.',
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final subjectName = studyProvider.subjectNameById(
                        subjects,
                        session.subjectId,
                      );

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(Icons.timer_rounded),
                          title: Text(session.title),
                          subtitle: Text(
                            '$subjectName • ${session.minutes} min • foco ${session.focusScore}/5\n${session.notes}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
