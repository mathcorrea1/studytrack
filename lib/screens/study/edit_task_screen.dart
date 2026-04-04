import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/models/study_task.dart';
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
  bool _initialized = false;

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

  void _handleSave() {
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

    context.read<StudyProvider>().updateTask(
          taskId: _task!.id,
          subjectId: _selectedSubjectId!,
          title: _titleController.text,
          description: _descriptionController.text,
        );

    SnackBarUtils.show(context, 'Tarefa atualizada com sucesso.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar tarefa')),
      body: SingleChildScrollView(
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
                  label: 'Salvar alteracoes',
                  icon: Icons.edit_rounded,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
