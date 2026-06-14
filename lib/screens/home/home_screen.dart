import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/providers/auth_provider.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/widgets/dashboard_action_card.dart';
import 'package:studytrack/widgets/stat_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Sair da conta'),
              content: const Text(
                'Deseja realmente encerrar a sessao atual?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Sair'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !context.mounted) {
      return;
    }

    await context.read<AuthProvider>().logout();
    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyTrack'),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<Subject>>(
        stream: studyProvider.subjectsStream(),
        builder: (context, subjectSnapshot) {
          return StreamBuilder<List<StudyTask>>(
            stream: studyProvider.tasksStream(),
            builder: (context, taskSnapshot) {
              final subjects = subjectSnapshot.data ?? const <Subject>[];
              final tasks = taskSnapshot.data ?? const <StudyTask>[];
              final isLoading = subjectSnapshot.connectionState ==
                      ConnectionState.waiting ||
                  taskSnapshot.connectionState == ConnectionState.waiting;
              final error = subjectSnapshot.error ?? taskSnapshot.error;
              final progress = studyProvider.progress(tasks);
              final progressPercentage = (progress * 100).round();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (isLoading) const LinearProgressIndicator(),
                  if (error != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Erro ao carregar dados: $error',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo, ${authProvider.currentUser?.name ?? 'estudante'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Organize materias, acompanhe tarefas e mantenha seu progresso em dia.',
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          const SizedBox(height: 8),
                          Text('$progressPercentage% das tarefas concluidas'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      StatSummaryCard(
                        title: 'Materias',
                        value: '${subjects.length}',
                        icon: Icons.book_outlined,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      StatSummaryCard(
                        title: 'Concluidas',
                        value: '${studyProvider.completedTasksCount(tasks)}',
                        icon: Icons.task_alt_rounded,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DashboardActionCard(
                    icon: Icons.post_add_rounded,
                    title: 'Criar materia',
                    subtitle: 'Cadastre uma nova materia de estudo.',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.createSubject),
                  ),
                  DashboardActionCard(
                    icon: Icons.list_alt_rounded,
                    title: 'Listar materias',
                    subtitle: 'Visualize todas as materias cadastradas.',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.subjectList),
                  ),
                  DashboardActionCard(
                    icon: Icons.note_add_outlined,
                    title: 'Criar tarefa',
                    subtitle: 'Adicione uma nova tarefa para uma materia.',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.createTask),
                  ),
                  DashboardActionCard(
                    icon: Icons.checklist_rounded,
                    title: 'Tarefas de estudo',
                    subtitle: 'Marque suas tarefas como concluidas.',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.taskList),
                  ),
                  DashboardActionCard(
                    icon: Icons.flag_outlined,
                    title: 'Metas de estudo',
                    subtitle: 'Defina objetivos de carga horaria.',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
                  ),
                  DashboardActionCard(
                    icon: Icons.timer_outlined,
                    title: 'Sessoes de estudo',
                    subtitle: 'Registre minutos estudados e foco.',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.sessions),
                  ),
                  DashboardActionCard(
                    icon: Icons.search_rounded,
                    title: 'Pesquisar tarefas',
                    subtitle: 'Busque tarefas com ordenacao personalizada.',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                  ),
                  DashboardActionCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Sugestoes de livros',
                    subtitle: 'Consulte a API publica Open Library.',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.apiTips),
                  ),
                  DashboardActionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Progresso',
                    subtitle: 'Acompanhe sua porcentagem de conclusao.',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.progress),
                  ),
                  DashboardActionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Sobre',
                    subtitle: 'Veja os dados do aplicativo e da disciplina.',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
