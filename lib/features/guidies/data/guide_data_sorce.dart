import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/guide_model.dart';

abstract class GuideDataSource {
  Future<List<GuideCategory>> getCategories();
  Future<List<GuideContent>> getContentByCategory(String categoryId);
  Future<List<GuideContent>> getAllContent();
  Future<List<FAQItem>> getFAQs([String? categoryId]);
  Future<GuideContent?> getContentById(String id);
  Future<void> incrementViewCount(String contentId);
  Future<void> saveViewHistory(
    String userId,
    String contentId,
    String categoryId,
  );
  Future<List<GuideContent>> searchContentByIntent(String intent, String query);
}

class LocalGuideDataSource implements GuideDataSource {
  // Cache keys
  static const String _categoriesCacheKey = 'guide_categories_cache';
  static const String _contentCacheKey = 'guide_content_cache';
  static const String _faqsCacheKey = 'guide_faqs_cache';
  static const String _viewHistoryPrefix = 'guide_view_history_';

  // Intent to Category mapping
  static const Map<String, String> _intentToCategoryMap = {
    'location': '1', // الوصول إلى المباني
    'registration': '2', // التسجيل والإجراءات
    'services': '3', // الخدمات الطلابية
    'activities': '4', // الأنشطة والفعاليات
    'academic': '5', // الدعم الأكاديمي
  };

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<List<GuideCategory>> getCategories() async {
    try {
      final prefs = await _preferences;
      final cachedData = prefs.getString(_categoriesCacheKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => GuideCategory.fromJson(json)).toList();
      }

      try {
        final jsonString = await rootBundle.loadString(
          'assets/data/guide_categories.json',
        );
        final List<dynamic> jsonList = json.decode(jsonString);
        await prefs.setString(_categoriesCacheKey, jsonString);
        return jsonList.map((json) => GuideCategory.fromJson(json)).toList();
      } catch (e) {
        final defaultCategories = _getDefaultCategories();
        final jsonString = json.encode(
          defaultCategories.map((c) => c.toJson()).toList(),
        );
        await prefs.setString(_categoriesCacheKey, jsonString);
        return defaultCategories;
      }
    } catch (e) {
      print('Error loading categories: $e');
      return _getDefaultCategories();
    }
  }

  @override
  Future<List<GuideContent>> getAllContent() async {
    try {
      final prefs = await _preferences;
      final cachedData = prefs.getString(_contentCacheKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => GuideContent.fromJson(json)).toList();
      }

      try {
        final jsonString = await rootBundle.loadString(
          'assets/data/guide_content.json',
        );
        final List<dynamic> jsonList = json.decode(jsonString);
        await prefs.setString(_contentCacheKey, jsonString);
        return jsonList.map((json) => GuideContent.fromJson(json)).toList();
      } catch (e) {
        final defaultContent = _getDefaultContent();
        final jsonString = json.encode(
          defaultContent.map((c) => c.toJson()).toList(),
        );
        await prefs.setString(_contentCacheKey, jsonString);
        return defaultContent;
      }
    } catch (e) {
      print('Error loading content: $e');
      return _getDefaultContent();
    }
  }

  @override
  Future<List<GuideContent>> getContentByCategory(String categoryId) async {
    final allContent = await getAllContent();
    return allContent
        .where((content) => content.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<GuideContent>> searchContentByIntent(
    String intent,
    String query,
  ) async {
    final allContent = await getAllContent();

    // Get category ID from intent
    final categoryId = _intentToCategoryMap[intent.toLowerCase()];

    if (categoryId != null) {
      // Filter by category first
      return allContent
          .where((content) => content.categoryId == categoryId)
          .toList();
    }

    // If no specific intent, return all content
    return allContent;
  }

  @override
  Future<List<FAQItem>> getFAQs([String? categoryId]) async {
    try {
      final prefs = await _preferences;
      final cachedData = prefs.getString(_faqsCacheKey);

      List<FAQItem> faqs;

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        faqs = jsonList.map((json) => FAQItem.fromJson(json)).toList();
      } else {
        try {
          final jsonString = await rootBundle.loadString(
            'assets/data/faqs.json',
          );
          final List<dynamic> jsonList = json.decode(jsonString);
          await prefs.setString(_faqsCacheKey, jsonString);
          faqs = jsonList.map((json) => FAQItem.fromJson(json)).toList();
        } catch (e) {
          faqs = _getDefaultFAQs();
          final jsonString = json.encode(faqs.map((f) => f.toJson()).toList());
          await prefs.setString(_faqsCacheKey, jsonString);
        }
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        return faqs.where((faq) => faq.categoryId == categoryId).toList();
      }

      return faqs;
    } catch (e) {
      print('Error loading FAQs: $e');
      return _getDefaultFAQs();
    }
  }

  @override
  Future<GuideContent?> getContentById(String id) async {
    try {
      final allContent = await getAllContent();
      return allContent.firstWhere((content) => content.id == id);
    } catch (e) {
      print('Content not found: $id');
      return null;
    }
  }

  @override
  Future<void> incrementViewCount(String contentId) async {
    try {
      final prefs = await _preferences;
      final key = 'view_count_$contentId';
      final currentCount = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, currentCount + 1);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  @override
  Future<void> saveViewHistory(
    String userId,
    String contentId,
    String categoryId,
  ) async {
    try {
      final prefs = await _preferences;
      final key = '$_viewHistoryPrefix$userId';

      final historyJson = prefs.getString(key);
      List<Map<String, dynamic>> history = [];

      if (historyJson != null) {
        history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      }

      history.insert(0, {
        'contentId': contentId,
        'categoryId': categoryId,
        'viewedAt': DateTime.now().toIso8601String(),
      });

      if (history.length > 50) {
        history = history.sublist(0, 50);
      }

      await prefs.setString(key, json.encode(history));
    } catch (e) {
      print('Error saving view history: $e');
    }
  }

  Future<List<GuideContent>> getRecommendedContent(String userId) async {
    try {
      final prefs = await _preferences;
      final key = '$_viewHistoryPrefix$userId';
      final historyJson = prefs.getString(key);

      if (historyJson == null) {
        return (await getAllContent()).take(5).toList();
      }

      final history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      final categoryViews = <String, int>{};

      for (final entry in history) {
        final categoryId = entry['categoryId'] as String;
        categoryViews[categoryId] = (categoryViews[categoryId] ?? 0) + 1;
      }

      final sortedCategories =
          categoryViews.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final allContent = await getAllContent();
      final recommended = <GuideContent>[];

      for (final entry in sortedCategories) {
        final categoryContent =
            allContent.where((c) => c.categoryId == entry.key).toList();
        recommended.addAll(categoryContent);
        if (recommended.length >= 10) break;
      }

      return recommended.take(10).toList();
    } catch (e) {
      print('Error getting recommended content: $e');
      return (await getAllContent()).take(5).toList();
    }
  }

  List<GuideCategory> _getDefaultCategories() {
    return [
      GuideCategory(
        id: '1',
        name: 'الوصول إلى المباني',
        description: 'كيفية الوصول للمباني والقاعات',
        icon: 'location_on',
        order: 1,
      ),
      GuideCategory(
        id: '2',
        name: 'التسجيل والإجراءات',
        description: 'التسجيل والإجراءات الأكاديمية',
        icon: 'assignment',
        order: 2,
      ),
      GuideCategory(
        id: '3',
        name: 'الخدمات الطلابية',
        description: 'المكتبات، المطاعم، والخدمات',
        icon: 'local_library',
        order: 3,
      ),
      GuideCategory(
        id: '4',
        name: 'الأنشطة والفعاليات',
        description: 'الأنشطة الطلابية والفعاليات',
        icon: 'event',
        order: 4,
      ),
      GuideCategory(
        id: '5',
        name: 'الدعم الأكاديمي',
        description: 'التواصل مع الأساتذة والدعم',
        icon: 'school',
        order: 5,
      ),
    ];
  }

  List<GuideContent> _getDefaultContent() {
    final now = DateTime.now();
    return [
      GuideContent(
        id: '1',
        categoryId: '1',
        title: 'كيفية الوصول إلى مبنى الطب',
        content:
            'مبنى الطب يقع في الجهة الشمالية من الحرم الجامعي. يمكنك الوصول إليه من البوابة الرئيسية باتباع اللافتات الموجهة.',
        keywords: ['الطب', 'مبنى', 'وصول', 'موقع', 'طريق', 'اين', 'كيف'],
        createdAt: now,
        updatedAt: now,
      ),

      GuideContent(
        id: '2',
        categoryId: '1',
        title: 'موقع المكتبة المركزية',
        content:
            'المكتبة المركزية تقع في قلب الحرم الجامعي، بجانب المبنى الإداري. ساعات العمل: 8 صباحاً - 10 مساءً.',
        keywords: ['مكتبة', 'كتب', 'دراسة', 'موقع', 'اين'],
        createdAt: now,
        updatedAt: now,
      ),

      GuideContent(
        id: '3',
        categoryId: '2',
        title: 'خطوات التسجيل للفصل الدراسي',
        content:
            'يتم التسجيل عبر البوابة الإلكترونية:\n1. تسجيل الدخول\n2. اختيار المواد\n3. مراجعة الجدول\n4. تأكيد التسجيل',
        keywords: ['تسجيل', 'مواد', 'جدول', 'فصل', 'بوابة', 'كيف'],
        createdAt: now,
        updatedAt: now,
      ),

      GuideContent(
        id: '4',
        categoryId: '3',
        title: 'خدمات المطاعم الجامعية',
        content:
            'يوجد ثلاثة مطاعم: المطعم الرئيسي، المقهى الثقافي، ومطعم الوجبات السريعة. الأسعار مدعومة 40% للطلاب.',
        keywords: ['مطعم', 'طعام', 'وجبات', 'كافيتيريا', 'اين'],
        createdAt: now,
        updatedAt: now,
      ),

      GuideContent(
        id: '5',
        categoryId: '4',
        title: 'الأندية الطلابية المتاحة',
        content:
            'أندية متنوعة: النادي العلمي، الثقافي، الرياضي، والتطوع. التسجيل من مكتب الأنشطة الطلابية.',
        keywords: ['نادي', 'أنشطة', 'فعاليات', 'تسجيل', 'كيف'],
        createdAt: now,
        updatedAt: now,
      ),

      GuideContent(
        id: '6',
        categoryId: '5',
        title: 'ساعات الإرشاد الأكاديمي',
        content:
            'كل طالب له مرشد أكاديمي. اعرف مرشدك من البوابة الإلكترونية. احجز موعد مسبقاً للساعات المكتبية.',
        keywords: ['مرشد', 'أكاديمي', 'دكتور', 'موعد', 'كيف'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<FAQItem> _getDefaultFAQs() {
    return [
      FAQItem(
        id: '1',
        question: 'كيف أحصل على بطاقة الطالب؟',
        answer:
            'من مكتب القبول والتسجيل بصورة شخصية وإثبات هوية. تستغرق 3 أيام عمل.',
        categoryId: '2',
        viewCount: 0,
      ),
      FAQItem(
        id: '2',
        question: 'ما مواعيد الحافلات الجامعية?',
        answer: 'من 7 صباحاً حتى 6 مساءً بفواصل 30 دقيقة.',
        categoryId: '3',
        viewCount: 0,
      ),
      FAQItem(
        id: '3',
        question: 'كيف أتواصل مع الأساتذة؟',
        answer:
            'عبر البريد الإلكتروني، الساعات المكتبية، أو منصة التعليم الإلكتروني.',
        categoryId: '5',
        viewCount: 0,
      ),
    ];
  }

  Future<void> clearCache() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_categoriesCacheKey);
      await prefs.remove(_contentCacheKey);
      await prefs.remove(_faqsCacheKey);
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
