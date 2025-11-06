import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ResourcesEvent extends Equatable {
  const ResourcesEvent();

  @override
  List<Object?> get props => [];
}

class LoadYears extends ResourcesEvent {
  const LoadYears();

  @override
  List<Object?> get props => [];
}

class LoadImageYear extends ResourcesEvent {
  final String yearId;
  final String imagePath;

  const LoadImageYear(this.yearId, this.imagePath);

  @override
  List<Object?> get props => [yearId, imagePath];
}

class LoadSubjectsByYear extends ResourcesEvent {
  final String yearId;

  const LoadSubjectsByYear(this.yearId);

  @override
  List<Object?> get props => [yearId];
}

class LoadSubjectById extends ResourcesEvent {
  final String subjectId;

  const LoadSubjectById(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

class LoadAllSubjects extends ResourcesEvent {}

// Your existing events
class LoadLecturesBySubject extends ResourcesEvent {
  final String subjectId;

  const LoadLecturesBySubject(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

class LoadFilesByLecture extends ResourcesEvent {
  final String lectureId;

  const LoadFilesByLecture(this.lectureId);

  @override
  List<Object?> get props => [lectureId];
}

class LoadVideosByLecture extends ResourcesEvent {
  final String lectureId;

  const LoadVideosByLecture(this.lectureId);

  @override
  List<Object?> get props => [lectureId];
}

class LoadLectureById extends ResourcesEvent {
  final String lectureId;

  const LoadLectureById(this.lectureId);

  @override
  List<Object?> get props => [lectureId];
}

class LoadFileById extends ResourcesEvent {
  final String fileId;

  const LoadFileById(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

class LoadResourcesByLecture extends ResourcesEvent {
  final String lectureId;

  LoadResourcesByLecture(this.lectureId);
}

class LoadVideoById extends ResourcesEvent {
  final String videoId;

  const LoadVideoById(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class LoadVideoNotes extends ResourcesEvent {
  final String videoId;
  LoadVideoNotes(this.videoId);
}

class AddVideoNote extends ResourcesEvent {
  final String videoId;
  final String content;
  AddVideoNote(this.videoId, this.content);
}

class DeleteVideoNote extends ResourcesEvent {
  final String videoId;
  final String noteId;
  DeleteVideoNote(this.videoId, this.noteId);

  @override
  List<Object?> get props => [videoId, noteId];
}

class LoadSubjectResourcesSummary extends ResourcesEvent {
  final String subjectId;

  const LoadSubjectResourcesSummary(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}
