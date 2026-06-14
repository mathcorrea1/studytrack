import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/providers/study_provider.dart';
import 'package:studytrack/services/study_service.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/empty_state_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  TaskSearchOrder _order = TaskSearchOrder.alphabetical;
  String _term = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar tarefas')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _searchController,
                      label: 'Buscar por titulo',
                      hint: 'Ex.: prova, leitura, flutter',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (value) {
                        setState(() => _term = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskSearchOrder>(
                      initialValue: _order,
                      decoration: const InputDecoration(
                        labelText: 'Ordenar por',
                        prefixIcon: Icon(Icons.sort_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TaskSearchOrder.alphabetical,
                          child: Text('Ordem alfabetica'),
                        ),
                        DropdownMenuItem(
                          value: TaskSearchOrder.createdAt,
                          child: Text('Mais recentes'),
                        ),
                        DropdownMenuItem(
                          value: TaskSearchOrder.status,
                          child: Text('Status'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _order = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<StudyTask>>(
                stream: studyProvider.searchTasks(term: _term, order: _order),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro na pesquisa: ${snapshot.error}'),
                    );
                  }

                  final tasks = snapshot.data ?? const <StudyTask>[];
                  if (tasks.isEmpty) {
                    return const EmptyStateCard(
                      icon: Icons.search_off_rounded,
                      title: 'Nenhum resultado encontrado',
                      subtitle:
                          'Tente outro termo ou altere o criterio de ordenacao.',
                    );
                  }

                  return ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            task.isCompleted
                                ? Icons.check_circle_outline_rounded
                                : Icons.radio_button_unchecked_rounded,
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            '${task.description}\nStatus: ${task.status} • Prioridade: ${task.priority}',
                          ),
                        ),
                      );
                    },
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
