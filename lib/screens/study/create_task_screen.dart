import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final subjects = context.read<StudyProvider>().subjects;
    if (_selectedSubjectId == null && subjects.isNotEmpty) {
      _selectedSubjectId = subjects.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreateTask() {
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

    context.read<StudyProvider>().addTask(
          subjectId: _selectedSubjectId!,
          title: _titleController.text,
          description: _descriptionController.text,
        );

    SnackBarUtils.show(context, 'Tarefa criada com sucesso.');
    Navigator.pushReplacementNamed(context, AppRoutes.taskList);
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: studyProvider.subjects.isEmpty
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
                          items: studyProvider.subjects
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
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Salvar tarefa',
                          icon: Icons.save_alt_rounded,
                          onPressed: _handleCreateTask,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
