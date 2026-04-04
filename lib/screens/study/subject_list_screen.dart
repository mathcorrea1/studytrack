import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/empty_state_card.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

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
