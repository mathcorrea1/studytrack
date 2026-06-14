class BookSuggestion {
  const BookSuggestion({
    required this.title,
    required this.author,
    required this.firstPublishYear,
    required this.subjects,
  });

  final String title;
  final String author;
  final int? firstPublishYear;
  final List<String> subjects;

  factory BookSuggestion.fromJson(Map<String, dynamic> json) {
    final authors = json['author_name'];
    final subjects = json['subject'];

    return BookSuggestion(
      title: json['title'] as String? ?? 'Titulo nao informado',
      author: authors is List && authors.isNotEmpty
          ? authors.first.toString()
          : 'Autor nao informado',
      firstPublishYear: json['first_publish_year'] as int?,
      subjects: subjects is List
          ? subjects.take(3).map((subject) => subject.toString()).toList()
          : const [],
    );
  }
}
