import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class LoadAllNews extends NewsEvent {}

class LoadNewsById extends NewsEvent {
  final String newsId;

  const LoadNewsById(this.newsId);

  @override
  List<Object> get props => [newsId];
}

class LoadNewsByYearId extends NewsEvent {
  final String yearId;

  LoadNewsByYearId(this.yearId);
}
