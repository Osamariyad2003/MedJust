import 'package:med_just/features/professors/data/professor_data_source.dart';

import '../../../core/models/professor_model.dart';

class ProfessorsRepository {
  final ProfessorsDataSource _dataSource;

  ProfessorsRepository({ProfessorsDataSource? dataSource})
    : _dataSource = dataSource ?? ProfessorsFirestoreDataSource();

  Future<List<Professor>> getAllProfessors() async {
    try {
      return await _dataSource.getAllProfessors();
    } catch (e) {
      throw Exception('Failed to load professors: $e');
    }
  }

  Future<Professor?> getProfessorById(String professorId) async {
    try {
      return await _dataSource.getProfessorById(professorId);
    } catch (e) {
      throw Exception('Failed to load professor: $e');
    }
  }

  Future<List<Professor>> getProfessorsByDepartment(String departmentId) async {
    try {
      return await _dataSource.getProfessorsByDepartment(departmentId);
    } catch (e) {
      throw Exception('Failed to load professors by department: $e');
    }
  }
}
