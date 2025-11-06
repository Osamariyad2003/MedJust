abstract class ProfessorsEvent {}

class LoadAllProfessors extends ProfessorsEvent {}

class LoadProfessorDetails extends ProfessorsEvent {
  final String professorId;

  LoadProfessorDetails(this.professorId);
}

class LoadProfessorsByDepartment extends ProfessorsEvent {
  final String departmentId;

  LoadProfessorsByDepartment(this.departmentId);
}
