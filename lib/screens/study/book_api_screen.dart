import 'package:flutter/material.dart';
import 'package:studytrack/models/book_suggestion.dart';
import 'package:studytrack/services/book_api_service.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/empty_state_card.dart';
import 'package:studytrack/widgets/primary_button.dart';

class BookApiScreen extends StatefulWidget {
  const BookApiScreen({super.key});

  @override
  State<BookApiScreen> createState() => _BookApiScreenState();
}

class _BookApiScreenState extends State<BookApiScreen> {
  final _queryController = TextEditingController(text: 'study skills');
  final _bookApiService = BookApiService();
  late Future<List<BookSuggestion>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _bookApiService.searchStudyBooks(_queryController.text);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _searchBooks() {
    setState(() {
      _booksFuture = _bookApiService.searchStudyBooks(_queryController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sugestoes de livros')),
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
                      controller: _queryController,
                      label: 'Tema para buscar',
                      hint: 'Ex.: matematica, flutter, produtividade',
                      prefixIcon: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Buscar na Open Library',
                      icon: Icons.cloud_download_outlined,
                      onPressed: _searchBooks,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<BookSuggestion>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao consultar API: ${snapshot.error}'),
                    );
                  }

                  final books = snapshot.data ?? const <BookSuggestion>[];
                  if (books.isEmpty) {
                    return const EmptyStateCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Nenhum livro encontrado',
                      subtitle: 'Tente pesquisar outro tema de estudo.',
                    );
                  }

                  return ListView.separated(
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final year = book.firstPublishYear == null
                          ? 'Ano nao informado'
                          : 'Publicado em ${book.firstPublishYear}';
                      final subjects = book.subjects.isEmpty
                          ? 'Sem assuntos listados'
                          : book.subjects.join(', ');

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(Icons.auto_stories_outlined),
                          title: Text(book.title),
                          subtitle: Text(
                            '${book.author}\n$year\nAssuntos: $subjects',
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
