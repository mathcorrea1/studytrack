import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:studytrack/models/study_goal.dart';
import 'package:studytrack/models/study_session.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';

class StudyService {
  StudyService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final firebase_auth.FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  firebase_auth.FirebaseAuth get auth =>
      _firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  FirebaseFirestore get db => _firestore ?? FirebaseFirestore.instance;

  String get _requiredUserId {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw const StudyDataException('Usuario nao autenticado.');
    }
    return uid;
  }

  Stream<List<Subject>> watchSubjects() {
    return _safeStream(() {
      final userId = _requiredUserId;
      return db
          .collection('materias')
          .where('userId', isEqualTo: userId)
          .orderBy('searchName')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map(Subject.fromDocument).toList(growable: false),
          );
    });
  }

  Stream<List<StudyTask>> watchTasks({bool onlyPending = false}) {
    return _safeStream(() {
      final userId = _requiredUserId;
      Query<Map<String, dynamic>> query = db
          .collection('tarefas')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (onlyPending) {
        query = query.where('isCompleted', isEqualTo: false);
      }

      return query.snapshots().map(
            (snapshot) => snapshot.docs
                .map(StudyTask.fromDocument)
                .toList(growable: false),
          );
    });
  }

  Stream<List<StudyGoal>> watchGoals() {
    return _safeStream(() {
      final userId = _requiredUserId;
      return db
          .collection('metas_estudo')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(StudyGoal.fromDocument)
                .toList(growable: false),
          );
    });
  }

  Stream<List<StudySession>> watchSessions() {
    return _safeStream(() {
      final userId = _requiredUserId;
      return db
          .collection('sessoes_estudo')
          .where('userId', isEqualTo: userId)
          .orderBy('studiedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(StudySession.fromDocument)
                .toList(growable: false),
          );
    });
  }

  Stream<List<StudyTask>> searchTasks({
    required String term,
    required TaskSearchOrder order,
  }) {
    return _safeStream(() {
      final userId = _requiredUserId;
      final normalizedTerm = term.trim().toLowerCase();

      Query<Map<String, dynamic>> query =
          db.collection('tarefas').where('userId', isEqualTo: userId);

      if (normalizedTerm.isNotEmpty) {
        query = query
            .orderBy('titleLowercase')
            .startAt([normalizedTerm]).endAt(['$normalizedTerm\uf8ff']);
      } else {
        switch (order) {
          case TaskSearchOrder.alphabetical:
            query = query.orderBy('titleLowercase');
            break;
          case TaskSearchOrder.createdAt:
            query = query.orderBy('createdAt', descending: true);
            break;
          case TaskSearchOrder.status:
            query = query.orderBy('status').orderBy('titleLowercase');
            break;
        }
      }

      return query.snapshots().map((snapshot) {
        final tasks = snapshot.docs
            .map(StudyTask.fromDocument)
            .toList(growable: false);

        if (normalizedTerm.isEmpty || order == TaskSearchOrder.alphabetical) {
          return tasks;
        }

        final sortedTasks = [...tasks];
        switch (order) {
          case TaskSearchOrder.alphabetical:
            break;
          case TaskSearchOrder.createdAt:
            sortedTasks.sort(
              (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                a.createdAt ?? DateTime(0),
              ),
            );
            break;
          case TaskSearchOrder.status:
            sortedTasks.sort((a, b) {
              final statusComparison = a.status.compareTo(b.status);
              if (statusComparison != 0) {
                return statusComparison;
              }
              return a.titleLowercase.compareTo(b.titleLowercase);
            });
            break;
        }
        return sortedTasks;
      });
    });
  }

  Future<void> addSubject({
    required String name,
    required String teacher,
    required int studyHoursPerWeek,
  }) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final subject = Subject(
        id: '',
        name: name,
        teacher: teacher,
        studyHoursPerWeek: studyHoursPerWeek,
      );
      await db.collection('materias').add(subject.toCreateMap(userId));
    });
  }

  Future<void> updateSubject({
    required String subjectId,
    required String name,
    required String teacher,
    required int studyHoursPerWeek,
  }) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final subjectRef = db.collection('materias').doc(subjectId);
      final snapshot = await subjectRef.get();
      if (snapshot.data()?['userId'] != userId) {
        throw const StudyDataException('Voce nao pode editar esta materia.');
      }

      final subject = Subject(
        id: subjectId,
        userId: userId,
        name: name,
        teacher: teacher,
        studyHoursPerWeek: studyHoursPerWeek,
      );
      await subjectRef.update(subject.toUpdateMap());
    });
  }

  Future<void> deleteSubject(String subjectId) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final subjectRef = db.collection('materias').doc(subjectId);
      final snapshot = await subjectRef.get();
      if (snapshot.data()?['userId'] != userId) {
        throw const StudyDataException('Voce nao pode excluir esta materia.');
      }

      final relatedTasks = await db
          .collection('tarefas')
          .where('userId', isEqualTo: userId)
          .where('subjectId', isEqualTo: subjectId)
          .get();

      final batch = db.batch();
      batch.delete(subjectRef);
      for (final task in relatedTasks.docs) {
        batch.delete(task.reference);
      }
      await batch.commit();
    });
  }

  Future<void> addTask({
    required String subjectId,
    required String title,
    required String description,
    String priority = 'Media',
    DateTime? dueDate,
  }) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final task = StudyTask(
        id: '',
        subjectId: subjectId,
        title: title,
        description: description,
        isCompleted: false,
        priority: priority,
        dueDate: dueDate,
      );
      await db.collection('tarefas').add(task.toCreateMap(userId));
    });
  }

  Future<void> updateTask({
    required String taskId,
    required String subjectId,
    required String title,
    required String description,
    required bool isCompleted,
    required String priority,
    DateTime? dueDate,
  }) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final taskRef = db.collection('tarefas').doc(taskId);
      final snapshot = await taskRef.get();
      if (snapshot.data()?['userId'] != userId) {
        throw const StudyDataException('Voce nao pode editar esta tarefa.');
      }

      final task = StudyTask(
        id: taskId,
        userId: userId,
        subjectId: subjectId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        dueDate: dueDate,
      );
      await taskRef.update(task.toUpdateMap());
    });
  }

  Future<void> toggleTaskCompletion(StudyTask task) async {
    await updateTask(
      taskId: task.id,
      subjectId: task.subjectId,
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
      priority: task.priority,
      dueDate: task.dueDate,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final taskRef = db.collection('tarefas').doc(taskId);
      final snapshot = await taskRef.get();
      if (snapshot.data()?['userId'] != userId) {
        throw const StudyDataException('Voce nao pode excluir esta tarefa.');
      }
      await taskRef.delete();
    });
  }

  Future<void> addGoal({
    required String title,
    required String description,
    required int targetHours,
    required DateTime deadline,
  }) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final goal = StudyGoal(
        id: '',
        title: title,
        description: description,
        targetHours: targetHours,
        deadline: deadline,
      );
      await db.collection('metas_estudo').add(goal.toCreateMap(userId));
    });
  }

  Future<void> addSession({
    required String subjectId,
    required String title,
    required int minutes,
    required int focusScore,
    required String notes,
  }) async {
    await _runFirestoreAction(() async {
      final userId = _requiredUserId;
      final session = StudySession(
        id: '',
        subjectId: subjectId,
        title: title,
        minutes: minutes,
        focusScore: focusScore,
        notes: notes,
        studiedAt: DateTime.now(),
      );
      await db.collection('sessoes_estudo').add(session.toCreateMap(userId));
    });
  }

  Stream<T> _safeStream<T>(Stream<T> Function() createStream) {
    try {
      return createStream();
    } catch (error) {
      return Stream<T>.error(_mapFirestoreError(error));
    }
  }

  Future<void> _runFirestoreAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      throw _mapFirestoreError(error);
    }
  }

  StudyDataException _mapFirestoreError(Object error) {
    if (error is StudyDataException) {
      return error;
    }

    final message = error.toString();
    if (message.contains('No Firebase App') ||
        message.contains('Firebase ainda nao configurado')) {
      return const StudyDataException(
        'Firebase nao configurado. Gere o arquivo firebase_options.dart real.',
      );
    }
    return StudyDataException('Erro ao acessar o Firestore: $message');
  }
}

enum TaskSearchOrder {
  alphabetical,
  createdAt,
  status,
}

class StudyDataException implements Exception {
  const StudyDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
