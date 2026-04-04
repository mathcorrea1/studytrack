class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.studyHoursPerWeek,
  });

  final String id;
  final String name;
  final String teacher;
  final int studyHoursPerWeek;

  Subject copyWith({
    String? id,
    String? name,
    String? teacher,
    int? studyHoursPerWeek,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      studyHoursPerWeek: studyHoursPerWeek ?? this.studyHoursPerWeek,
    );
  }
}
