import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/empty_state_card.dart';
import 'package:studytrack/widgets/stat_summary_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      body: StreamBuilder<List<Subject>>(
        stream: studyProvider.subjectsStream(),
        builder: (context, subjectSnapshot) {
          return StreamBuilder<List<StudyTask>>(
            stream: studyProvider.tasksStream(),
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
              final progress = studyProvider.progress(tasks);
              final progressPercentage = (progress * 100).round();

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        StatSummaryCard(
                          title: 'Total tarefas',
                          value: '${tasks.length}',
                          icon: Icons.assignment_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        StatSummaryCard(
                          title: 'Concluidas',
                          value: '${studyProvider.completedTasksCount(tasks)}',
                          icon: Icons.emoji_events_outlined,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progresso geral',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            const SizedBox(height: 10),
                            Text('$progressPercentage% concluido'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: subjects.isEmpty
                          ? const EmptyStateCard(
                              icon: Icons.analytics_outlined,
                              title: 'Sem dados para progresso',
                              subtitle:
                                  'Cadastre materias e tarefas para acompanhar a evolucao.',
                            )
                          : ListView.separated(
                              itemCount: subjects.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final subject = subjects[index];
                                final totalTasks =
                                    studyProvider.tasksCountForSubject(
                                  tasks,
                                  subject.id,
                                );
                                final completedTasks =
                                    studyProvider.completedTasksForSubject(
                                  tasks,
                                  subject.id,
                                );
                                final subjectProgress =
                                    studyProvider.progressForSubject(
                                  tasks,
                                  subject.id,
                                );
                                final percentage =
                                    (subjectProgress * 100).round();

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '$completedTasks de $totalTasks tarefas concluidas',
                                        ),
                                        const SizedBox(height: 12),
                                        LinearProgressIndicator(
                                          value: subjectProgress,
                                          minHeight: 8,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Aproveitamento: $percentage%'),
                                      ],
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
}
