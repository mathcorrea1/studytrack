class StudyTask {
  const StudyTask({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  final String id;
  final String subjectId;
  final String title;
  final String description;
  final bool isCompleted;

  StudyTask copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return StudyTask(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

