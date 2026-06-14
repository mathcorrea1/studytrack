import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  const StudySession({
    required this.id,
    this.userId = '',
    required this.subjectId,
    required this.title,
    required this.minutes,
    required this.focusScore,
    required this.notes,
    this.studiedAt,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String title;
  final int minutes;
  final int focusScore;
  final String notes;
  final DateTime? studiedAt;
  final DateTime? createdAt;

  Map<String, Object?> toCreateMap(String userId) {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'title': title.trim(),
      'minutes': minutes,
      'focusScore': focusScore,
      'notes': notes.trim(),
      'studiedAt': Timestamp.fromDate(studiedAt ?? DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory StudySession.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StudySession(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      minutes: (data['minutes'] as num?)?.toInt() ?? 0,
      focusScore: (data['focusScore'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String? ?? '',
      studiedAt: _dateFromValue(data['studiedAt']),
      createdAt: _dateFromValue(data['createdAt']),
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
