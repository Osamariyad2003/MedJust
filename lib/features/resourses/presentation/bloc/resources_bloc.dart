import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/notes_model.dart';
import 'package:med_just/core/models/quiz_model.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/file_model.dart';
import '../../../../core/models/lecture_model.dart';
import '../../../../core/models/video_model.dart';
import '../../../../core/models/year_model.dart';
import '../../../../core/models/subject_model.dart';
import '../../data/resources_repository.dart';

// --- Bloc Implementation ---
class ResourcesBloc extends Bloc<ResourcesEvent, ResourcesState> {
  final ResourcesRepository _repository;

  ResourcesBloc({required ResourcesRepository repository})
    : _repository = repository,
      super(ResourcesInitial()) {
    // Add these new handlers
    on<LoadYears>(_onLoadYears);
    on<LoadSubjectsByYear>(_onLoadSubjectsByYear);
    on<LoadSubjectById>(_onLoadSubjectById);
    // on<LoadAllSubjects>(_onLoadAllSubjects);

    // Your existing handlers
    on<LoadLecturesBySubject>(_onLoadLecturesBySubject);
    on<LoadFilesByLecture>(_onLoadFilesByLecture);
    on<LoadVideosByLecture>(_onLoadVideosByLecture);
    on<LoadLectureById>(_onLoadLectureById);
    on<LoadFileById>(_onLoadFileById);
    on<LoadVideoById>(_onLoadVideoById);
    on<LoadSubjectResourcesSummary>(_onLoadSubjectResourcesSummary);
    on<LoadResourcesByLecture>(_onLoadResourcesByLecture);
    on<LoadVideoNotes>(_onLoadVideoNotes);
    on<AddVideoNote>(_onAddVideoNote);
    on<DeleteVideoNote>(_onDeleteVideoNote); // new
  }

  // Implement the new handlers
  Future<void> _onLoadYears(
    LoadYears event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final years = await _repository.getYears();
      emit(YearsLoaded(years));
    } catch (e) {
      emit(ResourcesError('Failed to load years: $e'));
    }
  }

  Future<void> _onLoadSubjectById(
    LoadSubjectById event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    // Future<void> _onLoadAllSubjects(
    //   LoadAllSubjects event,
    //   Emitter<ResourcesState> emit,
    // ) async {
    //   emit(ResourcesLoading());
    //   try {
    //     final subjects = await _repository.getYears();
    //     emit(SubjectsLoaded(subjects));
    //   } catch (e) {
    //     print('Error loading all subjects: $e');
    //     emit(ResourcesError('Failed to load subjects: $e'));
    //   }
    // }
    // Future<void> _onLoadAllSubjects(
    //   LoadAllSubjects event,
    //   Emitter<ResourcesState> emit,
    // ) async {
    //   emit(ResourcesLoading());
    //   try {
    //     final subjects = await _repository..getYears();
    //     emit(SubjectsLoaded(subjects));
    //   } catch (e) {
    //     print('Error loading all subjects: $e');
    //     emit(ResourcesError('Failed to load subjects: $e'));
    //   }
  }

  // Update your existing LoadSubjectsByYear handler with better error handling
  Future<void> _onLoadSubjectsByYear(
    LoadSubjectsByYear event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      print('Loading subjects for year: ${event.yearId}');
      if (event.yearId == null || event.yearId.isEmpty) {
        emit(ResourcesError('Invalid year ID'));
        return;
      }

      final subjects = await _repository.getSubjectsByYear(event.yearId);
      print('Loaded ${subjects.length} subjects');
      emit(SubjectsLoaded(subjects));
    } catch (e) {
      print('Error in _onLoadSubjectsByYear: $e');
      if (e.toString().contains("'Null' is not a subtype of type 'String'")) {
        emit(
          ResourcesError('Invalid data in subjects. Please contact support.'),
        );
      } else {
        emit(ResourcesError('Failed to load subjects: $e'));
      }
    }
  }

  Future<void> _onLoadLecturesBySubject(
    LoadLecturesBySubject event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final lectures = await _repository.getLecturesBySubject(event.subjectId);
      emit(LecturesLoaded(lectures));
    } catch (e) {
      emit(ResourcesError('Failed to load lectures: $e'));
    }
  }

  Future<void> _onLoadResourcesByLecture(
    LoadResourcesByLecture event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final files = await _repository.getFileById(event.lectureId);
      final dynamicVideos = await _repository.getVideosByLecture(
        event.lectureId,
      );
      final dynamicQuizzes = await _repository.getQuizById(event.lectureId);

      // Convert to proper Video objects
      final videos =
          dynamicVideos is List
              ? (dynamicVideos as List).map((video) {
                if (video is Video) return video;
                return Video.fromJson(
                  video is Map<String, dynamic>
                      ? video
                      : video is Map
                      ? Map<String, dynamic>.from(video)
                      : {'id': 'unknown'},
                );
              }).toList()
              : <Video>[];

      // Convert files to a list
      final typedFiles =
          files is List
              ? files as List<FileModel>
              : files != null
              ? [files as FileModel]
              : <FileModel>[];

      // Convert quizzes to a list
      final quizzes =
          dynamicQuizzes is List<Quiz>
              ? dynamicQuizzes
              : dynamicQuizzes is List
              ? (dynamicQuizzes as List).map((quiz) {
                if (quiz is Quiz) return quiz;
                return Quiz.fromJson(
                  quiz is Map<String, dynamic>
                      ? quiz
                      : quiz is Map
                      ? Map<String, dynamic>.from(quiz)
                      : {'id': 'unknown'},
                );
              }).toList()
              : <Quiz>[];

      emit(
        ResourcesByLectureLoaded(
          files: typedFiles,
          videos: videos,
          quizzes: quizzes as List<Quiz>,
        ),
      );
    } catch (e) {
      emit(ResourcesError('Failed to load resources: $e'));
    }
  }

  Future<void> _onLoadFilesByLecture(
    LoadFilesByLecture event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final files = await _repository.getFilesByLecture(event.lectureId);
      emit(FilesLoaded(files as List<FileModel>));
    } catch (e) {
      emit(ResourcesError('Failed to load files: $e'));
    }
  }

  // Fix the _onLoadVideosByLecture method
  Future<void> _onLoadVideosByLecture(
    LoadVideosByLecture event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final dynamicVideos = await _repository.getVideosByLecture(
        event.lectureId,
      );

      // Convert to proper Video objects
      final videos =
          dynamicVideos is List
              ? (dynamicVideos as List).map((video) {
                if (video is Video) return video;
                return Video.fromJson(
                  video is Map<String, dynamic>
                      ? video
                      : video is Map
                      ? Map<String, dynamic>.from(video)
                      : {'id': 'unknown'},
                );
              }).toList()
              : <Video>[];

      // Emit with the list of videos, not a single video
      emit(VideosLoaded(videos));
    } catch (e) {
      emit(ResourcesError('Failed to load videos: $e'));
    }
  }

  // Fix the _onLoadLectureById method to properly fetch files and videos
  Future<void> _onLoadLectureById(
    LoadLectureById event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      print('Loading lecture with ID: ${event.lectureId}');

      // Get lecture data
      final lecture = await _repository.getLectureById(event.lectureId);

      // Fetch files and videos separately
      final filesResult = await _repository.getFilesByLecture(event.lectureId);
      final videosList = await _repository.getVideosByLecture(event.lectureId);
      final quizzes = await _repository.getQuizzesByLecture(event.lectureId);

      // Convert files to a list
      final files =
          filesResult is List
              ? filesResult as List<FileModel>
              : filesResult != null
              ? [filesResult as FileModel]
              : <FileModel>[];

      // Convert videos from dynamic to Video type if needed
      final typedVideos =
          videosList is List
              ? (videosList as List).map((video) {
                if (video is Video) return video;
                return Video.fromJson(
                  video is Map
                      ? Map<String, dynamic>.from(video)
                      : {'id': 'unknown'},
                );
              }).toList()
              : <Video>[];

      // Emit state with all data
      emit(
        SingleLectureLoaded(
          lecture: lecture,
          files: files,
          videos: typedVideos,
          quizzes: quizzes,
        ),
      );
    } catch (e) {
      print('Error loading lecture: $e');
      emit(ResourcesError('Failed to load lecture: $e'));
    }
  }

  Future<void> _onLoadFileById(
    LoadFileById event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final file = await _repository.getFileById(event.fileId);
      if (file != null) {
        emit(SingleFileLoaded(file));
      } else {
        emit(ResourcesError('File not found'));
      }
    } catch (e) {
      emit(ResourcesError('Failed to load file: $e'));
    }
  }

  Future<void> _onLoadVideoById(
    LoadVideoById event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final video = await _repository.getVideoById(event.videoId);
      if (video != null) {
        emit(SingleVideoLoaded(video));
      } else {
        emit(ResourcesError('Video not found'));
      }
    } catch (e) {
      emit(ResourcesError('Failed to load video: $e'));
    }
  }

  Future<void> _onLoadSubjectResourcesSummary(
    LoadSubjectResourcesSummary event,
    Emitter<ResourcesState> emit,
  ) async {
    try {
      emit(ResourcesLoading());

      // Add debugging
      print('Loading subject summary for ID: ${event.subjectId}');

      // Check if ID is valid
      if (event.subjectId.isEmpty) {
        emit(ResourcesError('Invalid subject ID'));
        return;
      }

      final summary = await _repository.getSubjectResourcesSummary(
        event.subjectId,
      );

      // Validate the summary is not null
      if (summary == null) {
        emit(ResourcesError('Subject summary not found'));
        return;
      }

      print('Successfully loaded subject summary: ${summary['subjectName']}');
      emit(SubjectResourcesSummaryLoaded(summary));
    } catch (e) {
      print('Error in _onLoadSubjectResourcesSummary: $e');
      emit(ResourcesError('Failed to load subject summary: $e'));
    }
  }

  Future<void> _onLoadVideoNotes(
    LoadVideoNotes event,
    Emitter<ResourcesState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notes_${event.videoId}';
    final notesJson = prefs.getStringList(key) ?? [];
    final notes =
        notesJson
            .map((noteStr) => VideoNote.fromJson(jsonDecode(noteStr)))
            .toList();
    emit(VideoNotesLoaded(notes));
  }

  Future<void> _onAddVideoNote(
    AddVideoNote event,
    Emitter<ResourcesState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notes_${event.videoId}';
    final notesJson = prefs.getStringList(key) ?? [];
    // Provide a unique id for the note (using timestamp)
    final note = VideoNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.content,
      createdAt: DateTime.now(),
    );
    notesJson.add(jsonEncode(note.toJson()));
    await prefs.setStringList(key, notesJson);
    final notes =
        notesJson
            .map((noteStr) => VideoNote.fromJson(jsonDecode(noteStr)))
            .toList();
    emit(VideoNotesLoaded(notes));
  }

  Future<void> _onDeleteVideoNote(
    DeleteVideoNote event,
    Emitter<ResourcesState> emit,
  ) async {
    emit(ResourcesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notes_${event.videoId}';
      final notesJson = prefs.getStringList(key) ?? [];

      // find index by id
      final index = notesJson.indexWhere((noteStr) {
        try {
          final map = jsonDecode(noteStr);
          return map['id'] == event.noteId;
        } catch (_) {
          return false;
        }
      });

      if (index != -1) {
        notesJson.removeAt(index);
        await prefs.setStringList(key, notesJson);
      }

      final notes =
          notesJson
              .map((noteStr) => VideoNote.fromJson(jsonDecode(noteStr)))
              .toList();
      emit(VideoNotesLoaded(notes));
    } catch (e) {
      emit(ResourcesError('Failed to delete note: $e'));
    }
  }
}
