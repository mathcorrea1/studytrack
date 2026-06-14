import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/models/study_goal.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/empty_state_card.dart';
import 'package:studytrack/widgets/primary_button.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    final errorMessage =
        AppValidators.requiredField(_titleController.text, 'titulo') ??
            AppValidators.requiredField(
              _descriptionController.text,
              'descricao',
            ) ??
            AppValidators.requiredField(_hoursController.text, 'horas alvo');

    if (errorMessage != null) {
      SnackBarUtils.show(context, errorMessage, isError: true);
      return;
    }

    final targetHours = int.tryParse(_hoursController.text.trim());
    if (targetHours == null || targetHours <= 0) {
      SnackBarUtils.show(context, 'Informe horas alvo validas.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<StudyProvider>().addGoal(
            title: _titleController.text,
            description: _descriptionController.text,
            targetHours: targetHours,
            deadline: DateTime.now().add(const Duration(days: 30)),
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
    _descriptionController.clear();
    _hoursController.clear();
    setState(() => _isSaving = false);
    SnackBarUtils.show(context, 'Meta cadastrada com sucesso.');
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Metas de estudo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: 'Titulo da meta',
                    prefixIcon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Descricao',
                    prefixIcon: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _hoursController,
                    label: 'Horas alvo',
                    prefixIcon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Salvar meta',
                    icon: Icons.save_outlined,
                    isLoading: _isSaving,
                    onPressed: _saveGoal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<StudyGoal>>(
            stream: studyProvider.goalsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Erro ao recuperar metas: ${snapshot.error}');
              }

              final goals = snapshot.data ?? const <StudyGoal>[];
              if (goals.isEmpty) {
                return const EmptyStateCard(
                  icon: Icons.flag_outlined,
                  title: 'Nenhuma meta cadastrada',
                  subtitle: 'Crie metas para direcionar seus estudos.',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = (goal.progress * 100).round();

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.flag_circle_outlined),
                      title: Text(goal.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.description),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: goal.progress),
                          const SizedBox(height: 6),
                          Text(
                            '${goal.completedHours}/${goal.targetHours} horas - $progress%',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
