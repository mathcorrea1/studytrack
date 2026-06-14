import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/empty_state_card.dart';
import 'package:studytrack/widgets/primary_button.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSubjectId;
  String _priority = 'Media';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTask() async {
    final errorMessage =
        AppValidators.requiredField(_titleController.text, 'titulo') ??
            AppValidators.requiredField(
              _descriptionController.text,
              'descricao',
            );

    if (errorMessage != null) {
      SnackBarUtils.show(context, errorMessage, isError: true);
      return;
    }

    if (_selectedSubjectId == null) {
      SnackBarUtils.show(
        context,
        'Cadastre uma materia antes de criar tarefas.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<StudyProvider>().addTask(
            subjectId: _selectedSubjectId!,
            title: _titleController.text,
            description: _descriptionController.text,
            priority: _priority,
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

    SnackBarUtils.show(context, 'Tarefa criada com sucesso.');
    Navigator.pushReplacementNamed(context, AppRoutes.taskList);
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar tarefa')),
      body: StreamBuilder<List<Subject>>(
        stream: studyProvider.subjectsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar materias: ${snapshot.error}'));
          }

          final subjects = snapshot.data ?? const <Subject>[];
          if (_selectedSubjectId == null && subjects.isNotEmpty) {
            _selectedSubjectId = subjects.first.id;
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: subjects.isEmpty
                ? Column(
                    children: [
                      const EmptyStateCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Nenhuma materia disponivel',
                        subtitle:
                            'Cadastre ao menos uma materia antes de criar tarefas.',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.createSubject);
                        },
                        child: const Text('Criar materia agora'),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Card(
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
                                setState(() {
                                  _selectedSubjectId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _titleController,
                              label: 'Titulo da tarefa',
                              prefixIcon: Icons.task_outlined,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _descriptionController,
                              label: 'Descricao',
                              prefixIcon: Icons.notes_rounded,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _priority,
                              decoration: const InputDecoration(
                                labelText: 'Prioridade',
                                prefixIcon: Icon(Icons.priority_high_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Baixa',
                                  child: Text('Baixa'),
                                ),
                                DropdownMenuItem(
                                  value: 'Media',
                                  child: Text('Media'),
                                ),
                                DropdownMenuItem(
                                  value: 'Alta',
                                  child: Text('Alta'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _priority = value);
                              },
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Salvar tarefa',
                              icon: Icons.save_alt_rounded,
                              isLoading: _isSaving,
                              onPressed: _handleCreateTask,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
