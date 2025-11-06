import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/professor_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ProfessorsState extends Equatable {
  const ProfessorsState();

  @override
  List<Object> get props => [];
}

class ProfessorsInitial extends ProfessorsState {}

class ProfessorsLoading extends ProfessorsState {}

class ProfessorsError extends ProfessorsState {
  final String message;

  const ProfessorsError(this.message);

  @override
  List<Object> get props => [message];
}

class AllProfessorsLoaded extends ProfessorsState {
  final List<Professor> professors;

  const AllProfessorsLoaded(this.professors);

  @override
  List<Object> get props => [professors];
}

class ProfessorDetailsLoaded extends ProfessorsState {
  final Professor professor;

  const ProfessorDetailsLoaded(this.professor);

  @override
  List<Object> get props => [professor];
}

class ProfessorsByDepartmentLoaded extends ProfessorsState {
  final List<Professor> professors;
  final String departmentId;

  const ProfessorsByDepartmentLoaded(this.professors, this.departmentId);

  @override
  List<Object> get props => [professors, departmentId];
}
