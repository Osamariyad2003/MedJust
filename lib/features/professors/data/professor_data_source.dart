import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/professor_model.dart';

abstract class ProfessorsDataSource {
  Future<List<Professor>> getAllProfessors();
  Future<Professor?> getProfessorById(String professorId);
  Future<List<Professor>> getProfessorsByDepartment(String departmentId);
}

class ProfessorsFirestoreDataSource implements ProfessorsDataSource {
  final FirebaseFirestore _firestore;

  ProfessorsFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Professor>> getAllProfessors() async {
    try {
      final snapshot =
          await _firestore.collection('professors').orderBy('name').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Professor.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Error fetching professors: $e');
      return [];
    }
  }

  @override
  Future<Professor?> getProfessorById(String professorId) async {
    try {
      final docSnapshot =
          await _firestore.collection('professors').doc(professorId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return Professor.fromJson({'id': docSnapshot.id, ...docSnapshot.data()!});
    } catch (e) {
      print('Error fetching professor $professorId: $e');
      return null;
    }
  }

  @override
  Future<List<Professor>> getProfessorsByDepartment(String departmentId) async {
    try {
      final snapshot =
          await _firestore
              .collection('professors')
              .where('department', isEqualTo: departmentId)
              .orderBy('name')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Professor.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Error fetching professors for department $departmentId: $e');
      return [];
    }
  }
}
