import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/models/study_task.dart';
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

    context.read<StudyProvider>().toggleTaskCompletion(task.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            task.isCompleted
                ? 'Tarefa reaberta com sucesso.'
                : 'Tarefa marcada como concluida.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final tasks = studyProvider.visibleTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas de estudo')),
      body: Padding(
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
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final subjectName =
                            studyProvider.subjectNameById(task.subjectId);

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: task.isCompleted
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.description),
                                  const SizedBox(height: 8),
                                  Text('Materia: $subjectName'),
                                  const SizedBox(height: 8),
                                  Text(
                                    task.isCompleted
                                        ? 'Status: Concluida'
                                        : 'Status: Pendente',
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () => _toggleTask(context, task),
                              icon: Icon(
                                task.isCompleted
                                    ? Icons.undo_rounded
                                    : Icons.check_circle_outline_rounded,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

