import 'package:equatable/equatable.dart';
import '../../data/model/azkar_model.dart';

abstract class AzkarState extends Equatable {
  const AzkarState();
  @override
  List<Object?> get props => [];
}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final List<AzkarItem> items;
  const AzkarLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class AzkarError extends AzkarState {
  final String message;
  const AzkarError(this.message);
  @override
  List<Object?> get props => [message];
}
