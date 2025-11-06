import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/features/news/presentation/bloc/news_event.dart';
import 'package:med_just/features/news/presentation/bloc/news_state.dart';
import '../../data/news_repository.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository repository;

  NewsBloc({required this.repository}) : super(NewsInitial()) {
    on<LoadAllNews>((event, emit) async {
      emit(NewsLoading());
      try {
        final newsList = await repository.getAllNews();
        print('[DEBUG] fetchAllNews returned: ${newsList.length} items');
        emit(NewsLoaded(newsList));
      } catch (e) {
        emit(NewsError('Failed to load news: $e'));
      }
    });

    on<LoadNewsByYearId>((event, emit) async {
      emit(NewsLoading());
      try {
        final newsList = await repository.getNewsByYearId(event.yearId);
        print(
          '[DEBUG] getNewsByYearId(${event.yearId}) returned: ${newsList.length} items',
        );
        emit(NewsLoaded(newsList));
      } catch (e) {
        emit(NewsError('Failed to load news: $e'));
      }
    });
  }
}
