import 'package:flutter/material.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/empty_state_card.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  Future<void> _confirmDeleteSubject(
    BuildContext context,
    String subjectId,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Excluir materia'),
              content: const Text(
                'Deseja excluir esta materia? As tarefas relacionadas tambem serao removidas.',
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

    context.read<StudyProvider>().deleteSubject(subjectId);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Materia excluida com sucesso.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: studyProvider.subjects.isEmpty
            ? const EmptyStateCard(
                icon: Icons.menu_book_outlined,
                title: 'Nenhuma materia cadastrada',
                subtitle: 'Crie sua primeira materia para organizar os estudos.',
              )
            : ListView.separated(
                itemCount: studyProvider.subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final subject = studyProvider.subjects[index];
                  final totalTasks =
                      studyProvider.tasksCountForSubject(subject.id);
                  final completedTasks =
                      studyProvider.completedTasksForSubject(subject.id);
                  final progress =
                      (studyProvider.progressForSubject(subject.id) * 100)
                          .round();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.book_rounded),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  subject.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.editSubject,
                                    arguments: subject,
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () {
                                  _confirmDeleteSubject(context, subject.id);
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Professor: ${subject.teacher}'),
                          Text(
                            'Horas por semana: ${subject.studyHoursPerWeek}',
                          ),
                          Text('Tarefas: $completedTasks/$totalTasks concluidas'),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: studyProvider.progressForSubject(subject.id),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          const SizedBox(height: 8),
                          Text('Progresso da materia: $progress%'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
