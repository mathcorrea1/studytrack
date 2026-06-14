import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGoal {
  const StudyGoal({
    required this.id,
    this.userId = '',
    required this.title,
    required this.description,
    required this.targetHours,
    this.completedHours = 0,
    this.isActive = true,
    this.deadline,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final int targetHours;
  final int completedHours;
  final bool isActive;
  final DateTime? deadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get progress {
    if (targetHours <= 0) {
      return 0;
    }
    return (completedHours / targetHours).clamp(0, 1).toDouble();
  }

  Map<String, Object?> toCreateMap(String userId) {
    return {
      'userId': userId,
      'title': title.trim(),
      'description': description.trim(),
      'targetHours': targetHours,
      'completedHours': completedHours,
      'isActive': isActive,
      'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
      'titleLowercase': title.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory StudyGoal.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StudyGoal(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      targetHours: (data['targetHours'] as num?)?.toInt() ?? 0,
      completedHours: (data['completedHours'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      deadline: _dateFromValue(data['deadline']),
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
