import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_just/core/models/quiz_model.dart';
import '../../../core/models/lecture_model.dart';
import '../../../core/models/file_model.dart';
import '../../../core/models/video_model.dart';
import '../../../core/models/year_model.dart';
import '../../../core/models/subject_model.dart';
import 'year_data_source.dart';

class ResourcesRepository {
  final ResourcesFirestoreDataSource _dataSource;

  ResourcesRepository({FirebaseFirestore? firestore})
    : _dataSource = ResourcesFirestoreDataSource(firestore: firestore);

  Future<List<Year>> getYears() async {
    try {
      return await _dataSource.getYears();
    } catch (e) {
      print('Error fetching years: $e');
      throw Exception('Failed to load years: $e');
    }
  }

  // Add method for subjects by year
  Future<List<Subject>> getSubjectsByYear(String yearId) async {
    // Use the temporary fix method from your data source
    return await _dataSource.getSubjectsByYear(yearId);
  }

  // Add the rest of your resource methods using the data source
  Future<List<Lecture>> getLecturesBySubject(String subjectId) =>
      _dataSource.getLecturesBySubject(subjectId);

  Future<List<FileModel>?> getFilesByLecture(String lectureId) =>
      _dataSource.getFilesByLecture(lectureId);

  Future<List> getVideosByLecture(String lectureId) =>
      _dataSource.getVideosByLecture(lectureId);

  Future<Quiz?> getQuizById(String quizId) => _dataSource.getQuizById(quizId);

  Future<List<Quiz>> getQuizzesByLecture(String lectureId) =>
      _dataSource.getQuizzesByLecture(lectureId);

  Future<Lecture> getLectureById(String lectureId) async {
    try {
      print('Getting lecture by ID: $lectureId');
      final lecture = await _dataSource.getLectureById(lectureId);

      if (lecture == null) {
        print('Lecture not found with ID: $lectureId');
        throw Exception('Lecture not found');
      }

      print('Lecture found: ${lecture.title}');

      // Get files and videos for this lecture
      final files = await _dataSource.getFilesByLecture(lectureId);
      final videos = await _dataSource.getVideosByLecture(lectureId);

      return lecture;
    } catch (e) {
      print('Error getting lecture details: $e');
      throw Exception('Failed to get lecture: $e');
    }
  }

  Future<FileModel?> getFileById(String fileId) =>
      _dataSource.getFileById(fileId);

  Future<dynamic> getVideoById(String videoId) =>
      _dataSource.getVideoById(videoId);

  Future getSubjectResourcesSummary(String subjectId) async {
    _dataSource.getSubjectResourcesSummary(subjectId);
  }
}
