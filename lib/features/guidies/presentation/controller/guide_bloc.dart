// lib/features/guidies/presentation/bloc/guide_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:med_just/features/guidies/presentation/controller/guide_states.dart';
import '../../data/models/guide_model.dart';
import '../../data/repository/guide_repository.dart';
import 'guide_event.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  final GuideRepository _repository;
  final List<ChatMessage> _chatMessages = [];

  GuideBloc({GuideRepository? repository})
    : _repository = repository ?? GuideRepository(),
      super(GuideInitial()) {
    on<InitializeGuide>(_onInitialize);
    on<LoadCategories>(_onLoadCategories);
    on<LoadContentByCategory>(_onLoadContentByCategory);
    on<SearchGuideContent>(_onSearchGuideContent);
    on<LoadFAQs>(_onLoadFAQs);
    on<SendChatMessage>(_onSendChatMessage);
    on<ClearChat>(_onClearChat);
    on<LoadContentById>(_onLoadContentById);
  }

  Future<void> _onInitialize(
    InitializeGuide event,
    Emitter<GuideState> emit,
  ) async {
    emit(GuideLoading());
    try {
      await _repository.initialize();
      emit(GuideReady());
      debugPrint('✓ GuideBloc initialized successfully');
    } catch (e) {
      debugPrint('✗ GuideBloc initialization failed: $e');
      emit(GuideError('Failed to initialize guide: $e'));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<GuideState> emit,
  ) async {
    emit(GuideLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoriesLoaded(categories));
      debugPrint('✓ Loaded ${categories.length} categories');
    } catch (e) {
      debugPrint('✗ Failed to load categories: $e');
      emit(GuideError('Failed to load categories: $e'));
    }
  }

  Future<void> _onLoadContentByCategory(
    LoadContentByCategory event,
    Emitter<GuideState> emit,
  ) async {
    emit(GuideLoading());
    try {
      final content = await _repository.getContentByCategory(event.categoryId);
      emit(ContentLoaded(content));
      debugPrint(
        '✓ Loaded ${content.length} content items for category ${event.categoryId}',
      );
    } catch (e) {
      debugPrint('✗ Failed to load content: $e');
      emit(GuideError('Failed to load content: $e'));
    }
  }

  Future<void> _onSearchGuideContent(
    SearchGuideContent event,
    Emitter<GuideState> emit,
  ) async {
    emit(GuideLoading());
    try {
      debugPrint('🔍 Searching for: "${event.query}"');
      final results = await _repository.searchContent(event.query);
      emit(SearchResultsLoaded(results, event.query));
      debugPrint('✓ Found ${results.length} search results');
    } catch (e) {
      debugPrint('✗ Search failed: $e');
      emit(GuideError('Search failed: $e'));
    }
  }

  Future<void> _onLoadFAQs(LoadFAQs event, Emitter<GuideState> emit) async {
    emit(GuideLoading());
    try {
      final faqs = await _repository.getFAQs(event.categoryId);
      emit(FAQsLoaded(faqs));
      debugPrint('✓ Loaded ${faqs.length} FAQs');
    } catch (e) {
      debugPrint('✗ Failed to load FAQs: $e');
      emit(GuideError('Failed to load FAQs: $e'));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<GuideState> emit,
  ) async {
    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMessage);
    emit(ChatUpdated(List.from(_chatMessages)));

    debugPrint('💬 User message: "${event.message}"');

    try {
      // Search for relevant content using TFLite
      final results = await _repository.searchContent(event.message);

      String botResponse;
      GuideContent? relatedContent;

      if (results.isNotEmpty) {
        relatedContent = results.first;
        // Create a concise response
        final contentPreview =
            relatedContent.content.length > 300
                ? '${relatedContent.content.substring(0, 300)}...'
                : relatedContent.content;

        botResponse = '📌 ${relatedContent.title}\n\n$contentPreview';

        debugPrint('✓ Bot found answer: "${relatedContent.title}"');
      } else {
        botResponse =
            'عذراً، لم أتمكن من إيجاد معلومات محددة حول سؤالك. 🤔\n\n'
            'يمكنك:\n'
            '• إعادة صياغة السؤال\n'
            '• تصفح الأقسام المختلفة\n'
            '• الاطلاع على الأسئلة الشائعة';

        debugPrint('⚠ No results found for query');
      }

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: botResponse,
        isUser: false,
        timestamp: DateTime.now(),
        relatedContent: relatedContent,
      );

      _chatMessages.add(botMessage);
      emit(ChatUpdated(List.from(_chatMessages)));
    } catch (e) {
      debugPrint('✗ Chat error: $e');
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'حدث خطأ أثناء معالجة طلبك. يرجى المحاولة مرة أخرى. ❌',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatMessages.add(errorMessage);
      emit(ChatUpdated(List.from(_chatMessages)));
    }
  }

  void _onClearChat(ClearChat event, Emitter<GuideState> emit) {
    _chatMessages.clear();
    emit(const ChatUpdated([]));
    debugPrint('🗑️ Chat cleared');
  }

  Future<void> _onLoadContentById(
    LoadContentById event,
    Emitter<GuideState> emit,
  ) async {
    emit(GuideLoading());
    try {
      final content = await _repository.getContentById(event.contentId);
      if (content != null) {
        emit(SingleContentLoaded(content));
        debugPrint('✓ Loaded content: "${content.title}"');
      } else {
        emit(const GuideError('Content not found'));
        debugPrint('⚠ Content not found: ${event.contentId}');
      }
    } catch (e) {
      debugPrint('✗ Failed to load content: $e');
      emit(GuideError('Failed to load content: $e'));
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    debugPrint('🔒 GuideBloc closed');
    return super.close();
  }
}
