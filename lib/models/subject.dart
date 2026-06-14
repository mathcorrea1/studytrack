import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  const Subject({
    required this.id,
    this.userId = '',
    required this.name,
    required this.teacher,
    required this.studyHoursPerWeek,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String teacher;
  final int studyHoursPerWeek;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get searchName => name.toLowerCase();

  Subject copyWith({
    String? id,
    String? userId,
    String? name,
    String? teacher,
    int? studyHoursPerWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      studyHoursPerWeek: studyHoursPerWeek ?? this.studyHoursPerWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toCreateMap(String userId) {
    return {
      'userId': userId,
      'name': name.trim(),
      'teacher': teacher.trim(),
      'studyHoursPerWeek': studyHoursPerWeek,
      'searchName': searchName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, Object?> toUpdateMap() {
    return {
      'name': name.trim(),
      'teacher': teacher.trim(),
      'studyHoursPerWeek': studyHoursPerWeek,
      'searchName': searchName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Subject.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Subject(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      teacher: data['teacher'] as String? ?? '',
      studyHoursPerWeek: (data['studyHoursPerWeek'] as num?)?.toInt() ?? 0,
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }
}

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}
