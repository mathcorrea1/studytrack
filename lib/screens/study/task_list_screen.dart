import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/empty_state_card.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  Future<void> _toggleTask(BuildContext context, StudyTask task) async {
    final actionLabel =
        task.isCompleted ? 'reabrir a tarefa' : 'marcar como concluida';

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Confirmar acao'),
              content: Text('Deseja realmente $actionLabel?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await context.read<StudyProvider>().toggleTaskCompletion(task);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      SnackBarUtils.show(context, error.toString(), isError: true);
      return;
    }

    if (context.mounted) {
      SnackBarUtils.show(
        context,
        task.isCompleted
            ? 'Tarefa reaberta com sucesso.'
            : 'Tarefa marcada como concluida.',
      );
    }
  }

  Future<void> _confirmDeleteTask(BuildContext context, StudyTask task) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Excluir tarefa'),
              content: const Text(
                'Deseja realmente excluir esta tarefa de estudo?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Excluir'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) {
      return;
    }

    try {
      await context.read<StudyProvider>().deleteTask(task.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      SnackBarUtils.show(context, error.toString(), isError: true);
      return;
    }

    if (context.mounted) {
      SnackBarUtils.show(context, 'Tarefa excluida com sucesso.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas de estudo')),
      body: StreamBuilder<List<Subject>>(
        stream: studyProvider.subjectsStream(),
        builder: (context, subjectSnapshot) {
          return StreamBuilder<List<StudyTask>>(
            stream: studyProvider.tasksStream(applyPendingFilter: true),
            builder: (context, taskSnapshot) {
              final isLoading = subjectSnapshot.connectionState ==
                      ConnectionState.waiting ||
                  taskSnapshot.connectionState == ConnectionState.waiting;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final error = subjectSnapshot.error ?? taskSnapshot.error;
              if (error != null) {
                return Center(child: Text('Erro ao recuperar dados: $error'));
              }

              final subjects = subjectSnapshot.data ?? const <Subject>[];
              final tasks = taskSnapshot.data ?? const <StudyTask>[];

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      child: SwitchListTile(
                        value: studyProvider.showOnlyPending,
                        onChanged: studyProvider.setShowOnlyPending,
                        title: const Text('Mostrar apenas pendentes'),
                        subtitle: const Text(
                          'Use o filtro para focar no que ainda falta concluir.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: tasks.isEmpty
                          ? const EmptyStateCard(
                              icon: Icons.task_alt_outlined,
                              title: 'Nenhuma tarefa encontrada',
                              subtitle:
                                  'Crie novas tarefas ou desative o filtro de pendencias.',
                            )
                          : ListView.separated(
                              itemCount: tasks.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                final subjectName =
                                    studyProvider.subjectNameById(
                                  subjects,
                                  task.subjectId,
                                );

                                return Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: task.isCompleted
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.orange.withValues(
                                              alpha: 0.15,
                                            ),
                                      child: Icon(
                                        task.isCompleted
                                            ? Icons.check_rounded
                                            : Icons.schedule_rounded,
                                        color: task.isCompleted
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(task.description),
                                          const SizedBox(height: 8),
                                          Text('Materia: $subjectName'),
                                          Text('Prioridade: ${task.priority}'),
                                          Text('Status: ${task.status}'),
                                        ],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () =>
                                          _showTaskActions(context, task),
                                      icon: const Icon(Icons.more_vert_rounded),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showTaskActions(BuildContext context, StudyTask task) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  task.isCompleted
                      ? Icons.undo_rounded
                      : Icons.check_circle_outline_rounded,
                ),
                title: Text(
                  task.isCompleted ? 'Reabrir tarefa' : 'Marcar como concluida',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _toggleTask(context, task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar tarefa'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editTask,
                    arguments: task,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Excluir tarefa'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDeleteTask(context, task);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
