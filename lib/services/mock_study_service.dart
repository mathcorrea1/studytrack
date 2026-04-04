import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/models/subject.dart';

class MockStudyService {
  List<Subject> getInitialSubjects() {
    return const [
      Subject(
        id: 'sub-1',
        name: 'Flutter',
        teacher: 'Prof. Ana',
        studyHoursPerWeek: 6,
      ),
      Subject(
        id: 'sub-2',
        name: 'Banco de Dados',
        teacher: 'Prof. Carlos',
        studyHoursPerWeek: 4,
      ),
      Subject(
        id: 'sub-3',
        name: 'Arquitetura de Software',
        teacher: 'Prof. Marina',
        studyHoursPerWeek: 3,
      ),
    ];
  }

  List<StudyTask> getInitialTasks() {
    return const [
      StudyTask(
        id: 'task-1',
        subjectId: 'sub-1',
        title: 'Revisar widgets basicos',
        description: 'Estudar Scaffold, Column, Row e ListView.',
        isCompleted: true,
      ),
      StudyTask(
        id: 'task-2',
        subjectId: 'sub-2',
        title: 'Resolver lista de SQL',
        description: 'Fazer 10 exercicios de SELECT e JOIN.',
        isCompleted: false,
      ),
      StudyTask(
        id: 'task-3',
        subjectId: 'sub-3',
        title: 'Ler sobre SOLID',
        description: 'Registrar os principais principios em um resumo.',
        isCompleted: false,
      ),
    ];
  }
}

