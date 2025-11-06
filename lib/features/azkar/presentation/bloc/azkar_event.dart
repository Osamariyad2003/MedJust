import 'package:equatable/equatable.dart';
import '../../data/model/azkar_model.dart';

abstract class AzkarEvent extends Equatable {
  const AzkarEvent();
  @override
  List<Object?> get props => [];
}

class LoadAzkar extends AzkarEvent {}

class AddAzkar extends AzkarEvent {
  final AzkarItem item;
  const AddAzkar(this.item);
  @override
  List<Object?> get props => [item];
}

class UpdateAzkar extends AzkarEvent {
  final AzkarItem item;
  const UpdateAzkar(this.item);
  @override
  List<Object?> get props => [item];
}

class DeleteAzkar extends AzkarEvent {
  final String id;
  const DeleteAzkar(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleAzkar extends AzkarEvent {
  final String id;
  const ToggleAzkar(this.id);
  @override
  List<Object?> get props => [id];
}
