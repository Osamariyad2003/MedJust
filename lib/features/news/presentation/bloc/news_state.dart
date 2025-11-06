import 'package:equatable/equatable.dart';
import '../../data/news_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<News> newsList;

  const NewsLoaded(this.newsList);

  @override
  List<Object> get props => [newsList];
}

class SingleNewsLoaded extends NewsState {
  final News news;

  const SingleNewsLoaded(this.news);

  @override
  List<Object> get props => [news];
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object> get props => [message];
}
