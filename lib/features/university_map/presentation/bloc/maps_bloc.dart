import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/maps_repo.dart';
import 'maps_event.dart';
import 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final MapsRepository _repository;

  MapsBloc({required MapsRepository repository})
    : _repository = repository,
      super(MapsInitial()) {
    on<LoadAllLocations>(_onLoadAllLocations);
    on<LoadLocationById>(_onLoadLocationById);
    on<LoadLocationsByType>(_onLoadLocationsByType);
  }

  Future<void> _onLoadAllLocations(
    LoadAllLocations event,
    Emitter<MapsState> emit,
  ) async {
    emit(MapsLoading());
    try {
      final locations = await _repository.getAllLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(MapsError('Failed to load locations: $e'));
    }
  }

  Future<void> _onLoadLocationById(
    LoadLocationById event,
    Emitter<MapsState> emit,
  ) async {
    emit(MapsLoading());
    try {
      final location = await _repository.getLocationById(event.locationId);
      if (location != null) {
        emit(SingleLocationLoaded(location));
      } else {
        emit(const MapsError('Location not found'));
      }
    } catch (e) {
      emit(MapsError('Failed to load location: $e'));
    }
  }

  Future<void> _onLoadLocationsByType(
    LoadLocationsByType event,
    Emitter<MapsState> emit,
  ) async {
    emit(MapsLoading());
    try {
      final locations = await _repository.getLocationsByType(event.type);
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(MapsError('Failed to load locations: $e'));
    }
  }
}
