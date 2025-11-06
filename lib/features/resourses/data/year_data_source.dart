import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:med_just/core/models/quiz_model.dart';
import 'package:med_just/core/models/subject_model.dart';
import 'package:med_just/core/models/year_model.dart';
import '../../../core/models/lecture_model.dart';
import '../../../core/models/file_model.dart';
import '../../../core/models/video_model.dart';

abstract class ResourcesDataSource {
  Future<List<Lecture>> getLecturesBySubject(String subjectId);
  Future<List<FileModel>> getFilesByLecture(String lectureId);
  Future<List<dynamic>> getVideosByLecture(String lectureId);
  Future<Lecture?> getLectureById(String lectureId);
  Future<FileModel?> getFileById(String fileId);
  Future<Video?> getVideoById(String videoId);
  Future<Quiz?> getQuizById(String quizId);
  Future<List<Quiz>> getQuizzesByLecture(String lectureId);
  Future<List<Subject>> getSubjectResourcesSummary(String subjectId);
  Future<List<Year>> getYears();
}

class ResourcesFirestoreDataSource implements ResourcesDataSource {
  final FirebaseFirestore _firestore;

  // Cache storage (BACKUP - currently disabled)
  final Map<String, List<Lecture>> _lecturesCache = {};
  final Map<String, List<FileModel>> _filesCache = {};
  final Map<String, List<Video>> _videosCache = {};
  final Map<String, List<Quiz>> _quizzesCache = {};
  final Map<String, Lecture> _lectureCache = {};
  final Map<String, FileModel> _fileCache = {};
  final Map<String, Video> _videoCache = {};
  final Map<String, Quiz> _quizCache = {};
  final Map<String, List<Subject>> _subjectsCache = {};
  List<Year>? _yearsCache;
  final Map<String, String> _resolvedUrlCache = {};

  // Cache expiry times (in milliseconds)
  final Map<String, int> _cacheExpiry = {};
  final int _cacheTimeoutMillis;
  Timer? _refreshTimer;

  // Cache control flag - set to false to bypass cache
  final bool _useCaching;

  ResourcesFirestoreDataSource({
    FirebaseFirestore? firestore,
    Duration? cacheTimeout,
    bool enableBackgroundRefresh = false,
    Duration? backgroundRefreshInterval,
    bool useCaching = false, // Default to false (cache disabled)
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cacheTimeoutMillis =
           (cacheTimeout ?? const Duration(hours: 1)).inMilliseconds,
       _useCaching = useCaching {
    if (enableBackgroundRefresh && _useCaching) {
      final interval = backgroundRefreshInterval ?? Duration(minutes: 30);
      _startBackgroundRefresh(interval);
    }
  }

  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _startBackgroundRefresh(Duration interval) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      clearCache();
      debugPrint(
        'ResourcesFirestoreDataSource: periodic cache cleared (interval: $interval)',
      );
    });
  }

  // Helper method to check if cache is valid (BACKUP)
  bool _isCacheValid(String key) {
    if (!_useCaching) return false; // Always return false if caching disabled
    final expiry = _cacheExpiry[key];
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  // Helper method to set cache expiry (BACKUP)
  void _setCacheExpiry(String key) {
    if (!_useCaching) return; // Skip if caching disabled
    _cacheExpiry[key] =
        DateTime.now().millisecondsSinceEpoch + _cacheTimeoutMillis;
  }

  @override
  Future<List<Lecture>> getLecturesBySubject(String subjectId) async {
    final cacheKey = 'lectures_$subjectId';

    // Cache check (will be bypassed if _useCaching is false)
    if (_useCaching &&
        _lecturesCache.containsKey(cacheKey) &&
        _isCacheValid(cacheKey)) {
      debugPrint('Using cached lectures for $subjectId');
      return _lecturesCache[cacheKey]!;
    }

    try {
      final snapshot = await _firestore
          .collection('Subjects')
          .doc(subjectId)
          .collection('lectures')
          .get(const GetOptions(source: Source.server)); // Force server fetch

      final lectures =
          snapshot.docs.map((doc) {
            final data = doc.data();
            try {
              return Lecture.fromJson({'id': doc.id, ...data});
            } catch (_) {
              return Lecture(
                id: doc.id,
                title: data['title'] ?? 'Untitled Lecture',
                description: data['description'] ?? 'No description',
                subjectId: subjectId,
                createdAt: data["createdAt"] ?? Timestamp.now(),
                imageUrl: data['imageUrl'] ?? '',
              );
            }
          }).toList();

      // Store in cache as backup (even if not actively used)
      if (_useCaching) {
        _lecturesCache[cacheKey] = lectures;
        _setCacheExpiry(cacheKey);
      }

      return lectures;
    } catch (e) {
      debugPrint('Error fetching lectures for subject $subjectId: $e');
      return [];
    }
  }

  // add helper inside ResourcesFirestoreDataSource class
  Future<String> _resolveImageUrl(String rawImage) async {
    if (rawImage.isEmpty) return '';
    rawImage = rawImage.trim();

    // URL resolution cache (keep this for performance)
    if (_resolvedUrlCache.containsKey(rawImage)) {
      return _resolvedUrlCache[rawImage]!;
    }

    if (rawImage.startsWith('http')) {
      final driveViewMatch = RegExp(
        r'drive\.google\.com/(file/d/|open\?id=|uc\?id=)([^/?&]+)',
      ).firstMatch(rawImage);
      if (driveViewMatch != null) {
        final id = driveViewMatch.group(2);
        final converted = 'https://drive.google.com/uc?export=view&id=$id';
        _resolvedUrlCache[rawImage] = converted;
        return converted;
      }

      _resolvedUrlCache[rawImage] = rawImage;
      return rawImage;
    }

    final driveIdMatch =
        RegExp(r'/d/([^/]+)').firstMatch(rawImage) ??
        RegExp(r'id=([^&]+)').firstMatch(rawImage) ??
        RegExp(r'drive\.google\.com.*?/d/([^/?&]+)').firstMatch(rawImage);
    if (driveIdMatch != null) {
      final id = driveIdMatch.group(1);
      final driveUrl = 'https://drive.google.com/uc?export=view&id=$id';
      _resolvedUrlCache[rawImage] = driveUrl;
      return driveUrl;
    }

    try {
      final storageUrl =
          await firebase_storage.FirebaseStorage.instance
              .ref(rawImage)
              .getDownloadURL();
      _resolvedUrlCache[rawImage] = storageUrl;
      return storageUrl;
    } catch (e) {
      debugPrint(
        'resolveImageUrl: failed to resolve storage path $rawImage -> $e',
      );
      _resolvedUrlCache[rawImage] = rawImage;
      return rawImage;
    }
  }

  @override
  Future<List<Year>> getYears() async {
    const cacheKey = 'years';

    if (_useCaching && _yearsCache != null && _isCacheValid(cacheKey)) {
      debugPrint('Using cached years');
      return _yearsCache!;
    }

    try {
      final snapshot =
          await _firestore
              .collection('years')
              .orderBy('order')
              .get(); // Force server fetch

      final years = <Year>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawImage =
            (data['imageUrl'] ?? data['image'] ?? data['photo'] ?? '')
                as String;
        debugPrint('year doc ${doc.id} raw image field: $rawImage');

        final imageUrl = await _resolveImageUrl(rawImage);

        final batchName =
            (data['batch_name'] ?? data['batch_name'] ?? '') as String;
        debugPrint('year doc ${doc.id} raw batch name field: $batchName');
        final actor = (data['actor'] ?? '') as String;
        debugPrint('year doc ${doc.id} raw actor field: $actor');

        final acadmicSupervisor =
            (data['acadmic_supervisor'] ?? data['academic_supervisor'] ?? '')
                as String;
        debugPrint(
          'year doc ${doc.id} raw academic supervisor field: $acadmicSupervisor',
        );

        final groupUrl =
            (data['group_url'] ?? data['groupUrl'] ?? '') as String;
        debugPrint('year doc ${doc.id} raw group URL field: $groupUrl');

        years.add(
          Year.fromJson({
            'id': doc.id,
            ...data,

            'imageUrl': imageUrl,
            'batch_name': batchName,
            'actor': actor,
            'acadmic_supervisor': acadmicSupervisor,
            'group_url': groupUrl,
          }),
        );
      }

      // Store in cache as backup
      if (_useCaching) {
        _yearsCache = years;
        _setCacheExpiry(cacheKey);
      }

      return years;
    } catch (e) {
      debugPrint('Error fetching years: $e');
      throw Exception('Failed to load years: $e');
    }
  }

  Future<List<Subject>> getSubjectsByYear(String yearId) async {
    final cacheKey = 'subjects_$yearId';

    if (_useCaching &&
        _subjectsCache.containsKey(cacheKey) &&
        _isCacheValid(cacheKey)) {
      return _subjectsCache[cacheKey]!;
    }

    try {
      final snapshot = await _firestore
          .collection('Subjects')
          .where('yearId', isEqualTo: yearId)
          .get(const GetOptions(source: Source.server));

      List<Subject> subjects =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Subject(
              id: doc.id,
              name: data['name'] ?? '',
              yearId: data['yearId'] ?? '',
              description: data['description'],
              professorName: data['professorName'],
              imageUrl: data['imageUrl'] ?? '',
            );
          }).toList();

      if (_useCaching) {
        _subjectsCache[cacheKey] = subjects;
        _setCacheExpiry(cacheKey);
      }

      return subjects;
    } catch (e) {
      debugPrint('Error in getSubjectsByYear: $e');
      throw Exception('Failed to load subjects: $e');
    }
  }

  @override
  Future<Lecture> getLectureById(String lectureId) async {
    if (_useCaching &&
        _lectureCache.containsKey(lectureId) &&
        _isCacheValid('lecture_$lectureId')) {
      return _lectureCache[lectureId]!;
    }

    try {
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (var subject in subjectsSnapshot.docs) {
        final lectureSnapshot = await _firestore
            .collection('Subjects')
            .doc(subject.id)
            .collection('lectures')
            .doc(lectureId)
            .get(const GetOptions(source: Source.server));

        if (lectureSnapshot.exists) {
          final data = lectureSnapshot.data()!;
          DateTime createdAt;
          if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else if (data['createdAt'] is String) {
            createdAt = DateTime.parse(data['createdAt']);
          } else {
            createdAt = DateTime.now();
          }

          final lecture = Lecture(
            id: lectureId,
            title: data['title'] ?? 'Untitled Lecture',
            description: data['description'] ?? '',
            subjectId: subject.id,
            createdAt: createdAt,
            imageUrl: data['imageUrl'] ?? '',
          );

          if (_useCaching) {
            _lectureCache[lectureId] = lecture;
            _setCacheExpiry('lecture_$lectureId');
          }

          return lecture;
        }
      }

      throw Exception('Lecture not found');
    } catch (e) {
      debugPrint('Error fetching lecture: $e');
      throw Exception('Failed to get lecture: $e');
    }
  }

  @override
  Future<List<FileModel>> getFilesByLecture(String lectureId) async {
    final cacheKey = 'files_$lectureId';

    if (_useCaching &&
        _filesCache.containsKey(cacheKey) &&
        _isCacheValid(cacheKey)) {
      return _filesCache[cacheKey]!;
    }

    try {
      DocumentSnapshot? subjectDoc;
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (final doc in subjectsSnapshot.docs) {
        final lectureDoc = await _firestore
            .collection('Subjects')
            .doc(doc.id)
            .collection('lectures')
            .doc(lectureId)
            .get(const GetOptions(source: Source.server));

        if (lectureDoc.exists) {
          subjectDoc = doc;
          break;
        }
      }

      if (subjectDoc != null) {
        final filesSnapshot = await _firestore
            .collection('Subjects')
            .doc(subjectDoc.id)
            .collection('lectures')
            .doc(lectureId)
            .collection('files')
            .get(const GetOptions(source: Source.server));

        List<FileModel> files =
            filesSnapshot.docs.map((doc) {
              final data = doc.data();
              DateTime uploadedAt;
              if (data['uploadedAt'] is Timestamp) {
                uploadedAt = (data['uploadedAt'] as Timestamp).toDate();
              } else if (data['uploadedAt'] is String) {
                uploadedAt = DateTime.parse(data['uploadedAt']);
              } else {
                uploadedAt = DateTime.now();
              }

              return FileModel(
                id: doc.id,
                name: data['title'] ?? 'Unknown',
                url: data['url'] ?? '',
                type: data['fileType'] ?? 'pdf',
                size: data['fileSize'] is int ? data['fileSize'] : 0,
                description: data['description'] ?? '',
                uploadedAt: uploadedAt,
              );
            }).toList();

        if (_useCaching) {
          _filesCache[cacheKey] = files;
          _setCacheExpiry(cacheKey);
        }

        return files;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching files for lecture $lectureId: $e');
      return [];
    }
  }

  @override
  Future<List<dynamic>> getVideosByLecture(String lectureId) async {
    final cacheKey = 'videos_$lectureId';

    if (_useCaching &&
        _videosCache.containsKey(cacheKey) &&
        _isCacheValid(cacheKey)) {
      return _videosCache[cacheKey]!;
    }

    try {
      DocumentSnapshot? subjectDoc;
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (final doc in subjectsSnapshot.docs) {
        final lectureDoc = await _firestore
            .collection('Subjects')
            .doc(doc.id)
            .collection('lectures')
            .doc(lectureId)
            .get(const GetOptions(source: Source.server));

        if (lectureDoc.exists) {
          subjectDoc = doc;
          break;
        }
      }

      if (subjectDoc != null) {
        final videosSnapshot = await _firestore
            .collection('Subjects')
            .doc(subjectDoc.id)
            .collection('lectures')
            .doc(lectureId)
            .collection('videos')
            .get(const GetOptions(source: Source.server));

        List<Video> videos =
            videosSnapshot.docs.map((doc) {
              final data = doc.data();
              DateTime uploadedAt;
              if (data['uploadedAt'] is Timestamp) {
                uploadedAt = (data['uploadedAt'] as Timestamp).toDate();
              } else if (data['uploadedAt'] is String) {
                uploadedAt = DateTime.parse(data['uploadedAt']);
              } else {
                uploadedAt = DateTime.now();
              }

              return Video(
                id: doc.id,
                title: data['title'] ?? 'Unknown',
                description: data['description'] ?? '',
                url: data['url'] ?? '',
                thumbnailUrl: data['thumbnailUrl'] ?? '',
                duration: const Duration(minutes: 0),
                lectureId: lectureId,
                uploadedAt: uploadedAt,
                platform: data['platform'] ?? '',
                uploadedBy: data['uploadedBy'] ?? '',
              );
            }).toList();

        if (_useCaching) {
          _videosCache[cacheKey] = videos;
          _setCacheExpiry(cacheKey);
        }

        return videos;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching videos for lecture $lectureId: $e');
      return [];
    }
  }

  @override
  Future<FileModel?> getFileById(String fileId) async {
    if (_useCaching &&
        _fileCache.containsKey(fileId) &&
        _isCacheValid('file_$fileId')) {
      return _fileCache[fileId];
    }

    try {
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (var subject in subjectsSnapshot.docs) {
        final lecturesSnapshot = await _firestore
            .collection('Subjects')
            .doc(subject.id)
            .collection('lectures')
            .get(const GetOptions(source: Source.server));

        for (var lecture in lecturesSnapshot.docs) {
          final filesSnapshot = await _firestore
              .collection('Subjects')
              .doc(subject.id)
              .collection('lectures')
              .doc(lecture.id)
              .collection('files')
              .where(FieldPath.documentId, isEqualTo: fileId)
              .get(const GetOptions(source: Source.server));

          if (filesSnapshot.docs.isNotEmpty) {
            final doc = filesSnapshot.docs.first;
            final data = doc.data();
            DateTime uploadedAt;
            if (data['uploadedAt'] is Timestamp) {
              uploadedAt = (data['uploadedAt'] as Timestamp).toDate();
            } else if (data['uploadedAt'] is String) {
              uploadedAt = DateTime.parse(data['uploadedAt']);
            } else {
              uploadedAt = DateTime.now();
            }

            final file = FileModel(
              id: doc.id,
              name: data['title'] ?? 'Unknown',
              url: data['url'] ?? '',
              type: data['fileType'] ?? 'pdf',
              size: data['fileSize'] is int ? data['fileSize'] : 0,
              description: data['description'] ?? '',
              uploadedAt: uploadedAt,
            );

            if (_useCaching) {
              _fileCache[fileId] = file;
              _setCacheExpiry('file_$fileId');
            }

            return file;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching file: $e');
      return null;
    }
  }

  @override
  Future<Quiz?> getQuizById(String quizId) async {
    if (_useCaching &&
        _quizCache.containsKey(quizId) &&
        _isCacheValid('quiz_$quizId')) {
      return _quizCache[quizId];
    }

    try {
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (final subjectDoc in subjectsSnapshot.docs) {
        final lecturesSnapshot = await _firestore
            .collection('Subjects')
            .doc(subjectDoc.id)
            .collection('lectures')
            .get(const GetOptions(source: Source.server));

        for (final lectureDoc in lecturesSnapshot.docs) {
          final quizDoc = await _firestore
              .collection('Subjects')
              .doc(subjectDoc.id)
              .collection('lectures')
              .doc(lectureDoc.id)
              .collection('quizzes')
              .doc(quizId)
              .get(const GetOptions(source: Source.server));

          if (quizDoc.exists) {
            final data = quizDoc.data()!;
            final quiz = Quiz.fromJson({'id': quizId, ...data});

            if (_useCaching) {
              _quizCache[quizId] = quiz;
              _setCacheExpiry('quiz_$quizId');
            }

            return quiz;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching quiz $quizId: $e');
      return null;
    }
  }

  @override
  Future<List<Quiz>> getQuizzesByLecture(String lectureId) async {
    final cacheKey = 'quizzes_$lectureId';

    if (_useCaching &&
        _quizzesCache.containsKey(cacheKey) &&
        _isCacheValid(cacheKey)) {
      return _quizzesCache[cacheKey]!;
    }

    try {
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (final subjectDoc in subjectsSnapshot.docs) {
        final lectureDoc = await _firestore
            .collection('Subjects')
            .doc(subjectDoc.id)
            .collection('lectures')
            .doc(lectureId)
            .get(const GetOptions(source: Source.server));

        if (lectureDoc.exists) {
          final quizzesSnapshot = await _firestore
              .collection('Subjects')
              .doc(subjectDoc.id)
              .collection('lectures')
              .doc(lectureId)
              .collection('quizzes')
              .get(const GetOptions(source: Source.server));

          final quizzes =
              quizzesSnapshot.docs
                  .map((doc) => Quiz.fromJson({'id': doc.id, ...doc.data()}))
                  .toList();

          if (_useCaching) {
            _quizzesCache[cacheKey] = quizzes;
            _setCacheExpiry(cacheKey);
          }

          return quizzes;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching quizzes for lecture $lectureId: $e');
      return [];
    }
  }

  @override
  Future<List<Subject>> getSubjectResourcesSummary(String subjectId) async {
    final cacheKey = 'subject_summary_$subjectId';

    if (_useCaching &&
        _subjectsCache.containsKey(cacheKey) &&
        _isCacheValid(cacheKey)) {
      return _subjectsCache[cacheKey]!;
    }

    try {
      final subjectDoc = await _firestore
          .collection('Subjects')
          .doc(subjectId)
          .get(const GetOptions(source: Source.server));

      if (!subjectDoc.exists) {
        return [];
      }

      final data = subjectDoc.data()!;
      final subject = Subject(
        id: subjectDoc.id,
        name: data['name'] ?? '',
        yearId: data['yearId'] ?? '',
        description: data['description'],
        professorName: data['professorName'],
        imageUrl: data['imageUrl'] ?? '',
      );

      if (_useCaching) {
        _subjectsCache[cacheKey] = [subject];
        _setCacheExpiry(cacheKey);
      }

      return [subject];
    } catch (e) {
      debugPrint('Error fetching subject summary for $subjectId: $e');
      return [];
    }
  }

  @override
  Future<Video?> getVideoById(String videoId) async {
    if (_useCaching &&
        _videoCache.containsKey(videoId) &&
        _isCacheValid('video_$videoId')) {
      return _videoCache[videoId];
    }

    try {
      final subjectsSnapshot = await _firestore
          .collection('Subjects')
          .get(const GetOptions(source: Source.server));

      for (final subjectDoc in subjectsSnapshot.docs) {
        final lecturesSnapshot = await _firestore
            .collection('Subjects')
            .doc(subjectDoc.id)
            .collection('lectures')
            .get(const GetOptions(source: Source.server));

        for (final lectureDoc in lecturesSnapshot.docs) {
          final videoDoc = await _firestore
              .collection('Subjects')
              .doc(subjectDoc.id)
              .collection('lectures')
              .doc(lectureDoc.id)
              .collection('videos')
              .doc(videoId)
              .get(const GetOptions(source: Source.server));

          if (videoDoc.exists) {
            final data = videoDoc.data()!;
            DateTime uploadedAt;
            if (data['uploadedAt'] is Timestamp) {
              uploadedAt = (data['uploadedAt'] as Timestamp).toDate();
            } else if (data['uploadedAt'] is String) {
              uploadedAt = DateTime.parse(data['uploadedAt']);
            } else {
              uploadedAt = DateTime.now();
            }

            final video = Video(
              id: videoId,
              title: data['title'] ?? 'Unknown',
              description: data['description'] ?? '',
              url: data['url'] ?? '',
              thumbnailUrl: data['thumbnailUrl'] ?? '',
              duration: const Duration(minutes: 0),
              lectureId: lectureDoc.id,
              uploadedAt: uploadedAt,
              platform: data['platform'] ?? '',
              uploadedBy: data['uploadedBy'] ?? '',
            );

            if (_useCaching) {
              _videoCache[videoId] = video;
              _setCacheExpiry('video_$videoId');
            }

            return video;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching video $videoId: $e');
      return null;
    }
  }

  // Cache management methods (BACKUP - kept for future use)
  void clearCache() {
    _lecturesCache.clear();
    _filesCache.clear();
    _videosCache.clear();
    _quizzesCache.clear();
    _lectureCache.clear();
    _fileCache.clear();
    _videoCache.clear();
    _quizCache.clear();
    _subjectsCache.clear();
    _yearsCache = null;
    _cacheExpiry.clear();
    debugPrint('All caches cleared (backup mode)');
  }

  void clearCacheForKey(String key) {
    _lecturesCache.remove(key);
    _filesCache.remove(key);
    _videosCache.remove(key);
    _cacheExpiry.remove(key);
    debugPrint('Cache cleared for key: $key (backup mode)');
  }

  // Method to enable caching at runtime if needed
  void enableCaching() {
    // This would require making _useCaching mutable
    debugPrint(
      'Caching is currently disabled by default. To enable, pass useCaching: true to constructor.',
    );
  }
}
