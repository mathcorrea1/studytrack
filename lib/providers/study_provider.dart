import 'package:flutter/material.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';
import 'package:studytrack/services/mock_study_service.dart';

class StudyProvider extends ChangeNotifier {
  StudyProvider(this._mockStudyService) {
    _subjects = List<Subject>.from(_mockStudyService.getInitialSubjects());
    _tasks = List<StudyTask>.from(_mockStudyService.getInitialTasks());
  }

  final MockStudyService _mockStudyService;

  late final List<Subject> _subjects;
  late final List<StudyTask> _tasks;
  bool _showOnlyPending = false;

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<StudyTask> get allTasks => List.unmodifiable(_tasks);
  bool get showOnlyPending => _showOnlyPending;

  List<StudyTask> get visibleTasks {
    if (!_showOnlyPending) {
      return List.unmodifiable(_tasks);
    }

    return List.unmodifiable(
      _tasks.where((task) => !task.isCompleted),
    );
  }

  double get progress {
    if (_tasks.isEmpty) {
      return 0;
    }

    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    return completedTasks / _tasks.length;
  }

  int get completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;

  int tasksCountForSubject(String subjectId) {
    return _tasks.where((task) => task.subjectId == subjectId).length;
  }

  int completedTasksForSubject(String subjectId) {
    return _tasks
        .where(
          (task) => task.subjectId == subjectId && task.isCompleted,
        )
        .length;
  }

  double progressForSubject(String subjectId) {
    final totalTasks = tasksCountForSubject(subjectId);
    if (totalTasks == 0) {
      return 0;
    }

    return completedTasksForSubject(subjectId) / totalTasks;
  }

  void addSubject({
    required String name,
    required String teacher,
    required int studyHoursPerWeek,
  }) {
    final subject = Subject(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      teacher: teacher.trim(),
      studyHoursPerWeek: studyHoursPerWeek,
    );

    _subjects.add(subject);
    notifyListeners();
  }

  void updateSubject({
    required String subjectId,
    required String name,
    required String teacher,
    required int studyHoursPerWeek,
  }) {
    final index = _subjects.indexWhere((subject) => subject.id == subjectId);
    if (index == -1) {
      return;
    }

    _subjects[index] = _subjects[index].copyWith(
      name: name.trim(),
      teacher: teacher.trim(),
      studyHoursPerWeek: studyHoursPerWeek,
    );
    notifyListeners();
  }

  void deleteSubject(String subjectId) {
    _subjects.removeWhere((subject) => subject.id == subjectId);
    _tasks.removeWhere((task) => task.subjectId == subjectId);
    notifyListeners();
  }

  void addTask({
    required String subjectId,
    required String title,
    required String description,
  }) {
    final task = StudyTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      subjectId: subjectId,
      title: title.trim(),
      description: description.trim(),
      isCompleted: false,
    );

    _tasks.add(task);
    notifyListeners();
  }

  void updateTask({
    required String taskId,
    required String subjectId,
    required String title,
    required String description,
  }) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(
      subjectId: subjectId,
      title: title.trim(),
      description: description.trim(),
    );
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    final selectedTask = _tasks[index];
    _tasks[index] = selectedTask.copyWith(
      isCompleted: !selectedTask.isCompleted,
    );
    notifyListeners();
  }

  void setShowOnlyPending(bool value) {
    _showOnlyPending = value;
    notifyListeners();
  }

  String subjectNameById(String subjectId) {
    return _subjects
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
