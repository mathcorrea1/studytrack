import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/constants/app_routes.dart';
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

    context.read<AuthProvider>().logout();
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
    final progressPercentage = (studyProvider.progress * 100).round();

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                    value: studyProvider.progress,
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
                value: '${studyProvider.subjects.length}',
                icon: Icons.book_outlined,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              StatSummaryCard(
                title: 'Concluidas',
                value: '${studyProvider.completedTasksCount}',
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.createSubject),
          ),
          DashboardActionCard(
            icon: Icons.list_alt_rounded,
            title: 'Listar materias',
            subtitle: 'Visualize todas as materias cadastradas.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.subjectList),
          ),
          DashboardActionCard(
            icon: Icons.note_add_outlined,
            title: 'Criar tarefa',
            subtitle: 'Adicione uma nova tarefa para uma materia.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.createTask),
          ),
          DashboardActionCard(
            icon: Icons.checklist_rounded,
            title: 'Tarefas de estudo',
            subtitle: 'Marque suas tarefas como concluidas.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.taskList),
          ),
          DashboardActionCard(
            icon: Icons.analytics_outlined,
            title: 'Progresso',
            subtitle: 'Acompanhe sua porcentagem de conclusao.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.progress),
          ),
          DashboardActionCard(
            icon: Icons.info_outline_rounded,
            title: 'Sobre',
            subtitle: 'Veja os dados do aplicativo e da disciplina.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

