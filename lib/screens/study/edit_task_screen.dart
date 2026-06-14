import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/primary_button.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  StudyTask? _task;
  String? _selectedSubjectId;
  String _priority = 'Media';
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is StudyTask) {
      _task = arguments;
      _selectedSubjectId = arguments.subjectId;
      _priority = arguments.priority;
      _titleController.text = arguments.title;
      _descriptionController.text = arguments.description;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_task == null) {
      SnackBarUtils.show(context, 'Tarefa nao encontrada.', isError: true);
      return;
    }

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
      SnackBarUtils.show(context, 'Selecione uma materia.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<StudyProvider>().updateTask(
            taskId: _task!.id,
            subjectId: _selectedSubjectId!,
            title: _titleController.text,
            description: _descriptionController.text,
            isCompleted: _task!.isCompleted,
            priority: _priority,
            dueDate: _task!.dueDate,
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

    SnackBarUtils.show(context, 'Tarefa atualizada com sucesso.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar tarefa')),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),
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
                      label: 'Salvar alteracoes',
                      icon: Icons.edit_rounded,
                      isLoading: _isSaving,
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
