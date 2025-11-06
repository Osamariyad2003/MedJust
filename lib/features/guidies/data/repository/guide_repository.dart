import '../guide_data_sorce.dart';
import '../models/guide_model.dart';
import '../tflite_service.dart';

class GuideRepository {
  final GuideDataSource _dataSource;
  final TFLiteService _tfliteService;

  GuideRepository({GuideDataSource? dataSource, TFLiteService? tfliteService})
    : _dataSource = dataSource ?? LocalGuideDataSource(),
      _tfliteService = tfliteService ?? TFLiteService();

  /// Initialize repository (load TFLite model)
  Future<void> initialize() async {
    try {
      await _tfliteService.initialize();
      print('✓ GuideRepository initialized successfully');
    } catch (e) {
      print('✗ GuideRepository initialization failed: $e');
      throw Exception('Failed to initialize guide repository: $e');
    }
  }

  /// Get all categories
  Future<List<GuideCategory>> getCategories() async {
    try {
      return await _dataSource.getCategories();
    } catch (e) {
      print('Error getting categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Get content by category
  Future<List<GuideContent>> getContentByCategory(String categoryId) async {
    try {
      return await _dataSource.getContentByCategory(categoryId);
    } catch (e) {
      print('Error getting content by category: $e');
      throw Exception('Failed to load content: $e');
    }
  }

  /// Search content using TFLite intent classification
  Future<List<GuideContent>> searchContent(String query) async {
    try {
      // Get intent classification from TFLite
      final intent = await _tfliteService.classifyIntent(query);

      // Map intent to category ID
      final categoryMap = {
        'location': '1',
        'registration': '2',
        'services': '3',
        'activities': '4',
        'academic': '5',
      };

      // Get all content
      final allContent = await _dataSource.getAllContent();

      // Filter by intent category first (if classified)
      final categoryId = categoryMap[intent];
      final candidateContent =
          categoryId != null
              ? allContent.where((c) => c.categoryId == categoryId).toList()
              : allContent;

      // Calculate similarity scores for each candidate
      final scoredResults =
          candidateContent.map((content) {
            // Title similarity (higher weight)
            final titleSimilarity = _tfliteService.calculateSimilarity(
              query,
              content.title,
            );

            // Content similarity
            final contentSimilarity = _tfliteService.calculateSimilarity(
              query,
              content.content,
            );

            // Keyword matching
            final keywordMatch = content.keywords.any(
              (k) =>
                  query.toLowerCase().contains(k.toLowerCase()) ||
                  k.toLowerCase().contains(query.toLowerCase()),
            );

            // Combined score (title weighted 2x, keyword bonus)
            final score =
                (titleSimilarity * 2.0) +
                contentSimilarity +
                (keywordMatch ? 0.5 : 0);

            return {'content': content, 'score': score};
          }).toList();

      // Sort by score descending
      scoredResults.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double),
      );

      // Return top results with minimum threshold
      return scoredResults
          .where((r) => (r['score'] as double) > 0.1)
          .take(5)
          .map((r) => r['content'] as GuideContent)
          .toList();
    } catch (e) {
      print('Error searching content: $e');
      throw Exception('Search failed: $e');
    }
  }

  /// Get FAQs (optionally filtered by category)
  Future<List<FAQItem>> getFAQs([String? categoryId]) async {
    try {
      return await _dataSource.getFAQs(categoryId);
    } catch (e) {
      print('Error getting FAQs: $e');
      throw Exception('Failed to load FAQs: $e');
    }
  }

  /// Get content by ID
  Future<GuideContent?> getContentById(String id) async {
    try {
      return await _dataSource.getContentById(id);
    } catch (e) {
      print('Error getting content by ID: $e');
      return null;
    }
  }

  /// Get recommended content based on user history
  Future<List<GuideContent>> getRecommendedContent(String userId) async {
    try {
      if (_dataSource is LocalGuideDataSource) {
        return await (_dataSource as LocalGuideDataSource)
            .getRecommendedContent(userId);
      }
      // Fallback: return first 5 items
      final allContent = await _dataSource.getAllContent();
      return allContent.take(5).toList();
    } catch (e) {
      print('Error getting recommended content: $e');
      return [];
    }
  }

  /// Increment view count for content
  Future<void> incrementViewCount(String contentId) async {
    try {
      await _dataSource.incrementViewCount(contentId);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  /// Save view history for personalization
  Future<void> saveViewHistory(
    String userId,
    String contentId,
    String categoryId,
  ) async {
    try {
      await _dataSource.saveViewHistory(userId, contentId, categoryId);
    } catch (e) {
      print('Error saving view history: $e');
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      if (_dataSource is LocalGuideDataSource) {
        await (_dataSource as LocalGuideDataSource).clearCache();
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _tfliteService.dispose();
  }
}
