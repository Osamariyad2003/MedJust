import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/file_model.dart';
import 'package:med_just/core/models/lecture_model.dart';
import 'package:med_just/core/models/notes_model.dart';
import 'package:med_just/core/models/quiz_model.dart';
import 'package:med_just/core/models/subject_model.dart';
import 'package:med_just/core/models/video_model.dart';
import 'package:med_just/core/models/year_model.dart';

abstract class ResourcesState extends Equatable {
  const ResourcesState();

  @override
  List<Object?> get props => [];
}

class ResourcesInitial extends ResourcesState {}

class ResourcesLoading extends ResourcesState {}

class ResourcesError extends ResourcesState {
  final String message;

  const ResourcesError(this.message);

  @override
  List<Object?> get props => [message];
}

class YearsLoaded extends ResourcesState {
  final List<Year> years;

  const YearsLoaded(this.years);

  @override
  List<Object?> get props => [years];
}

class YearImageLoaded extends ResourcesState {
  final String yearId;
  final String imageUrl;

  const YearImageLoaded(this.yearId, this.imageUrl);

  @override
  List<Object?> get props => [yearId, imageUrl];
}

class SubjectsLoaded extends ResourcesState {
  final List<Subject> subjects;

  const SubjectsLoaded(this.subjects);

  @override
  List<Object?> get props => [subjects];
}

class SingleSubjectLoaded extends ResourcesState {
  final Subject subject;

  const SingleSubjectLoaded(this.subject);

  @override
  List<Object?> get props => [subject];
}

class LecturesLoaded extends ResourcesState {
  final List<Lecture> lectures;

  const LecturesLoaded(this.lectures);

  @override
  List<Object?> get props => [lectures];
}

class FilesLoaded extends ResourcesState {
  final List<FileModel> files;

  const FilesLoaded(this.files);

  @override
  List<Object?> get props => [files];
}

class VideosLoaded extends ResourcesState {
  final List<Video> videos;

  const VideosLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

class SubjectResourcesSummaryLoaded extends ResourcesState {
  final Map<String, dynamic> summary;

  const SubjectResourcesSummaryLoaded(this.summary);

  @override
  List<Object> get props => [summary];
}

class ResourcesByLectureLoaded extends ResourcesState {
  final List<FileModel> files;
  final List<Video> videos;
  final List<Quiz> quizzes;

  const ResourcesByLectureLoaded({
    required this.files,
    required this.videos,
    required this.quizzes,
  });
}

class SingleLectureLoaded extends ResourcesState {
  final Lecture lecture;
  final List<FileModel> files;
  final List<Video> videos;
  final List<Quiz> quizzes;

  const SingleLectureLoaded({
    required this.lecture,
    required this.files,
    required this.videos,
    this.quizzes = const [],
  });

  @override
  List<Object?> get props => [lecture, files, videos, quizzes];
}

class SingleFileLoaded extends ResourcesState {
  final FileModel file;

  const SingleFileLoaded(this.file);

  @override
  List<Object?> get props => [file];
}

class SingleVideoLoaded extends ResourcesState {
  final Video video;
  final List<VideoNote> notes;

  const SingleVideoLoaded(this.video, {this.notes = const []});

  @override
  List<Object?> get props => [video, notes];
}

class VideoNotesLoaded extends ResourcesState {
  final List<VideoNote> notes;
  VideoNotesLoaded(this.notes);
}
