// lib/features/guidies/presentation/bloc/guide_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/guide_model.dart';

abstract class GuideState extends Equatable {
  const GuideState();
  @override
  List<Object?> get props => [];
}

class GuideInitial extends GuideState {}

class GuideLoading extends GuideState {}

class GuideReady extends GuideState {}

class CategoriesLoaded extends GuideState {
  final List<GuideCategory> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class ContentLoaded extends GuideState {
  final List<GuideContent> content;
  const ContentLoaded(this.content);
  @override
  List<Object?> get props => [content];
}

class SearchResultsLoaded extends GuideState {
  final List<GuideContent> results;
  final String query;
  const SearchResultsLoaded(this.results, this.query);
  @override
  List<Object?> get props => [results, query];
}

class FAQsLoaded extends GuideState {
  final List<FAQItem> faqs;
  const FAQsLoaded(this.faqs);
  @override
  List<Object?> get props => [faqs];
}

class SingleContentLoaded extends GuideState {
  final GuideContent content;
  const SingleContentLoaded(this.content);
  @override
  List<Object?> get props => [content];
}

class ChatUpdated extends GuideState {
  final List<ChatMessage> messages;
  const ChatUpdated(this.messages);
  @override
  List<Object?> get props => [messages];
}

class GuideError extends GuideState {
  final String message;
  const GuideError(this.message);
  @override
  List<Object?> get props => [message];
}
