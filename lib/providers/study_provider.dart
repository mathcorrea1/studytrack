import 'package:flutter/material.dart';
import 'package:studytrack/models/study_goal.dart';
import 'package:studytrack/models/study_session.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/services/study_service.dart';

class StudyProvider extends ChangeNotifier {
  StudyProvider(this._studyService);

  final StudyService _studyService;
  bool _showOnlyPending = false;

  bool get showOnlyPending => _showOnlyPending;

  Stream<List<Subject>> subjectsStream() => _studyService.watchSubjects();

  Stream<List<StudyTask>> tasksStream({bool applyPendingFilter = false}) {
    return _studyService.watchTasks(
      onlyPending: applyPendingFilter && _showOnlyPending,
    );
  }

  Stream<List<StudyGoal>> goalsStream() => _studyService.watchGoals();

  Stream<List<StudySession>> sessionsStream() => _studyService.watchSessions();

  Stream<List<StudyTask>> searchTasks({
    required String term,
    required TaskSearchOrder order,
  }) {
    return _studyService.searchTasks(term: term, order: order);
  }

  Future<void> addSubject({
    required String name,
    required String teacher,
    required int studyHoursPerWeek,
  }) {
    return _studyService.addSubject(
      name: name,
      teacher: teacher,
      studyHoursPerWeek: studyHoursPerWeek,
    );
  }

  Future<void> updateSubject({
    required String subjectId,
    required String name,
    required String teacher,
    required int studyHoursPerWeek,
  }) {
    return _studyService.updateSubject(
      subjectId: subjectId,
      name: name,
      teacher: teacher,
      studyHoursPerWeek: studyHoursPerWeek,
    );
  }

  Future<void> deleteSubject(String subjectId) {
    return _studyService.deleteSubject(subjectId);
  }

  Future<void> addTask({
    required String subjectId,
    required String title,
    required String description,
    required String priority,
    DateTime? dueDate,
  }) {
    return _studyService.addTask(
      subjectId: subjectId,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
  }

  Future<void> updateTask({
    required String taskId,
    required String subjectId,
    required String title,
    required String description,
    required bool isCompleted,
    required String priority,
    DateTime? dueDate,
  }) {
    return _studyService.updateTask(
      taskId: taskId,
      subjectId: subjectId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      priority: priority,
      dueDate: dueDate,
    );
  }

  Future<void> deleteTask(String taskId) {
    return _studyService.deleteTask(taskId);
  }

  Future<void> toggleTaskCompletion(StudyTask task) {
    return _studyService.toggleTaskCompletion(task);
  }

  Future<void> addGoal({
    required String title,
    required String description,
    required int targetHours,
    required DateTime deadline,
  }) {
    return _studyService.addGoal(
      title: title,
      description: description,
      targetHours: targetHours,
      deadline: deadline,
    );
  }

  Future<void> addSession({
    required String subjectId,
    required String title,
    required int minutes,
    required int focusScore,
    required String notes,
  }) {
    return _studyService.addSession(
      subjectId: subjectId,
      title: title,
      minutes: minutes,
      focusScore: focusScore,
      notes: notes,
    );
  }

  void setShowOnlyPending(bool value) {
    _showOnlyPending = value;
    notifyListeners();
  }

  int completedTasksCount(List<StudyTask> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  double progress(List<StudyTask> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }
    return completedTasksCount(tasks) / tasks.length;
  }

  int tasksCountForSubject(List<StudyTask> tasks, String subjectId) {
    return tasks.where((task) => task.subjectId == subjectId).length;
  }

  int completedTasksForSubject(List<StudyTask> tasks, String subjectId) {
    return tasks
        .where((task) => task.subjectId == subjectId && task.isCompleted)
        .length;
  }

  double progressForSubject(List<StudyTask> tasks, String subjectId) {
    final totalTasks = tasksCountForSubject(tasks, subjectId);
    if (totalTasks == 0) {
      return 0;
    }
    return completedTasksForSubject(tasks, subjectId) / totalTasks;
  }

  String subjectNameById(List<Subject> subjects, String subjectId) {
    return subjects
        .firstWhere(
          (subject) => subject.id == subjectId,
          orElse: () => const Subject(
            id: 'unknown',
            name: 'Materia nao encontrada',
            teacher: '-',
            studyHoursPerWeek: 0,
          ),
        )
        .name;
  }
}
