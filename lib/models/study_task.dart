import 'package:cloud_firestore/cloud_firestore.dart';

class StudyTask {
  const StudyTask({
    required this.id,
    this.userId = '',
    required this.subjectId,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.priority = 'Media',
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String title;
  final String description;
  final bool isCompleted;
  final String priority;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get status => isCompleted ? 'Concluida' : 'Pendente';
  String get titleLowercase => title.toLowerCase();

  StudyTask copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyTask(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toCreateMap(String userId) {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'title': title.trim(),
      'description': description.trim(),
      'isCompleted': isCompleted,
      'status': status,
      'priority': priority,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'titleLowercase': titleLowercase,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, Object?> toUpdateMap() {
    return {
      'subjectId': subjectId,
      'title': title.trim(),
      'description': description.trim(),
      'isCompleted': isCompleted,
      'status': status,
      'priority': priority,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'titleLowercase': titleLowercase,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory StudyTask.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StudyTask(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
      priority: data['priority'] as String? ?? 'Media',
      dueDate: _dateFromValue(data['dueDate']),
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

