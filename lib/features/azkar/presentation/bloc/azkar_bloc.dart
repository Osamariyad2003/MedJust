import 'package:flutter_bloc/flutter_bloc.dart';
import 'azkar_event.dart';
import 'azkar_state.dart';
import '../../data/data_source/azkar_data_source.dart';
import '../../data/model/azkar_model.dart';

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  AzkarBloc() : super(AzkarInitial()) {
    on<LoadAzkar>(_onLoad);
    on<AddAzkar>(_onAdd);
    on<UpdateAzkar>(_onUpdate);
    on<DeleteAzkar>(_onDelete);
    on<ToggleAzkar>(_onToggle);
  }

  Future<void> _onLoad(LoadAzkar event, Emitter<AzkarState> emit) async {
    emit(AzkarLoading());
    try {
      final items = await AzkarStorage.loadAll();
      emit(AzkarLoaded(items));
    } catch (e) {
      emit(AzkarError('Failed to load azkar: $e'));
    }
  }

  Future<void> _onAdd(AddAzkar event, Emitter<AzkarState> emit) async {
    try {
      await AzkarStorage.add(event.item);
      add(LoadAzkar());
    } catch (e) {
      emit(AzkarError('Failed to add azkar: $e'));
    }
  }

  Future<void> _onUpdate(UpdateAzkar event, Emitter<AzkarState> emit) async {
    try {
      await AzkarStorage.update(event.item);
      add(LoadAzkar());
    } catch (e) {
      emit(AzkarError('Failed to update azkar: $e'));
    }
  }

  Future<void> _onDelete(DeleteAzkar event, Emitter<AzkarState> emit) async {
    try {
      await AzkarStorage.delete(event.id);
      add(LoadAzkar());
    } catch (e) {
      emit(AzkarError('Failed to delete azkar: $e'));
    }
  }

  Future<void> _onToggle(ToggleAzkar event, Emitter<AzkarState> emit) async {
    try {
      await AzkarStorage.toggle(event.id);
      add(LoadAzkar());
    } catch (e) {
      emit(AzkarError('Failed to toggle azkar: $e'));
    }
  }
}
