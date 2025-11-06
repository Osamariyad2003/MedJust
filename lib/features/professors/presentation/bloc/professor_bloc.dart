import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:med_just/features/professors/data/professor_repo.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_event.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_state.dart';
import 'package:meta/meta.dart';

import '../../../../core/models/professor_model.dart';

class ProfessorsBloc extends Bloc<ProfessorsEvent, ProfessorsState> {
  final ProfessorsRepository _repository;

  ProfessorsBloc({required ProfessorsRepository repository})
    : _repository = repository,
      super(ProfessorsInitial()) {
    on<LoadAllProfessors>(_onLoadAllProfessors);
    on<LoadProfessorDetails>(_onLoadProfessorDetails);
    on<LoadProfessorsByDepartment>(_onLoadProfessorsByDepartment);
  }

  Future<void> _onLoadAllProfessors(
    LoadAllProfessors event,
    Emitter<ProfessorsState> emit,
  ) async {
    emit(ProfessorsLoading());
    try {
      final professors = await _repository.getAllProfessors();
      emit(AllProfessorsLoaded(professors));
    } catch (e) {
      emit(ProfessorsError('Failed to load professors: $e'));
    }
  }

  Future<void> _onLoadProfessorDetails(
    LoadProfessorDetails event,
    Emitter<ProfessorsState> emit,
  ) async {
    emit(ProfessorsLoading());
    try {
      final professor = await _repository.getProfessorById(event.professorId);
      if (professor != null) {
        emit(ProfessorDetailsLoaded(professor));
      } else {
        emit(const ProfessorsError('Professor not found'));
      }
    } catch (e) {
      emit(ProfessorsError('Failed to load professor details: $e'));
    }
  }

  Future<void> _onLoadProfessorsByDepartment(
    LoadProfessorsByDepartment event,
    Emitter<ProfessorsState> emit,
  ) async {
    emit(ProfessorsLoading());
    try {
      final professors = await _repository.getProfessorsByDepartment(
        event.departmentId,
      );
      emit(ProfessorsByDepartmentLoaded(professors, event.departmentId));
    } catch (e) {
      emit(ProfessorsError('Failed to load professors by department: $e'));
    }
  }
}
