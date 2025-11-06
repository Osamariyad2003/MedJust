// lib/features/guidies/presentation/bloc/guide_event.dart
import 'package:equatable/equatable.dart';

abstract class GuideEvent extends Equatable {
  const GuideEvent();
  @override
  List<Object?> get props => [];
}

class InitializeGuide extends GuideEvent {}

class LoadCategories extends GuideEvent {}

class LoadContentByCategory extends GuideEvent {
  final String categoryId;
  const LoadContentByCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchGuideContent extends GuideEvent {
  final String query;
  const SearchGuideContent(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadFAQs extends GuideEvent {
  final String? categoryId;
  const LoadFAQs([this.categoryId]);
  @override
  List<Object?> get props => [categoryId];
}

class SendChatMessage extends GuideEvent {
  final String message;
  const SendChatMessage(this.message);
  @override
  List<Object?> get props => [message];
}

class ClearChat extends GuideEvent {}

class LoadContentById extends GuideEvent {
  final String contentId;
  const LoadContentById(this.contentId);
  @override
  List<Object?> get props => [contentId];
}
