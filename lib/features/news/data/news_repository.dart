import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/news_model.dart';
import '../data/news_data_source.dart';

class NewsRepository {
  final NewsDataSource dataSource;

  NewsRepository({required this.dataSource});

  Future<List<News>> getAllNews() async {
    try {
      return await dataSource.getNews();
    } catch (e) {
      print('Error fetching all news: $e');
      throw Exception('Failed to fetch news from Firestore: ${e.toString()}');
    }
  }

  Future<List<News>> getNewsByYearId(String yearId) async {
    try {
      return await dataSource.getNewsByYearId(yearId);
    } catch (e) {
      print('Error fetching news for year $yearId: $e');
      throw Exception(
        'Failed to fetch news for your academic year: ${e.toString()}',
      );
    }
  }
}
