import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:studytrack/models/book_suggestion.dart';

class BookApiService {
  BookApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<BookSuggestion>> searchStudyBooks(String query) async {
    final normalizedQuery = query.trim().isEmpty ? 'study skills' : query.trim();
    final books = await _fetchBooks(normalizedQuery);

    if (books.isNotEmpty || normalizedQuery == 'study skills') {
      return books;
    }

    return _fetchBooks('study skills');
  }

  Future<List<BookSuggestion>> _fetchBooks(String query) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': query,
      'limit': '12',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Erro ${response.statusCode} ao consultar livros.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'];
    if (docs is! List) {
      return const [];
    }

    return docs
        .whereType<Map<String, dynamic>>()
        .map(BookSuggestion.fromJson)
        .toList(growable: false);
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
