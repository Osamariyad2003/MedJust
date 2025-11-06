import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/news_model.dart';

abstract class NewsDataSource {
  Future<List<News>> getNews();
  Future<List<News>> getNewsByYearId(String yearId);
}

class NewsFirestoreDataSource implements NewsDataSource {
  final FirebaseFirestore _firestore;

  NewsFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<News>> getNews() async {
    try {
      final snapshot =
          await _firestore
              .collection('news')
              .orderBy('updatedAt', descending: true)
              .get();

      print('[DEBUG] getNews: Raw docs count: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('[DEBUG] getNews: doc data: ${doc.data()}');
      }

      final newsList =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return News.fromJson({'id': doc.id, ...data});
          }).toList();

      print('[DEBUG] getNews: News list length: ${newsList.length}');
      return newsList;
    } catch (e) {
      print('Error in getNews: $e');
      throw Exception('Failed to fetch news from Firestore');
    }
  }

  @override
  Future<List<News>> getNewsByYearId(String yearId) async {
    try {
      print('Fetching news for yearId: $yearId');

      QuerySnapshot snapshot;
      try {
        snapshot =
            await _firestore
                .collection('news')
                .where('yearId', isEqualTo: yearId)
                .orderBy('updatedAt', descending: true)
                .get();
      } catch (e) {
        print('Error with ordered query: $e');
        snapshot =
            await _firestore
                .collection('news')
                .where('yearId', isEqualTo: yearId)
                .get();
      }

      print('[DEBUG] getNewsByYearId: Raw docs count: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('[DEBUG] getNewsByYearId: doc data: ${doc.data()}');
      }

      final docs = snapshot.docs;
      if (!snapshot.metadata.isFromCache) {
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = aData['publishedAt'] as Timestamp;
          final bDate = bData['publishedAt'] as Timestamp;
          return bDate.compareTo(aDate); // Descending
        });
      }

      final newsList =
          docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return News.fromJson({'id': doc.id, ...data});
          }).toList();

      print('[DEBUG] getNewsByYearId: News list length: ${newsList.length}');
      return newsList;
    } catch (e) {
      print('Error in getNewsByYearId: $e');
      throw Exception('Failed to fetch news for yearId: $yearId');
    }
  }
}
