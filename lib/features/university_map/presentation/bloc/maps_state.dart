import 'package:equatable/equatable.dart';
import 'package:med_just/features/university_map/data/maps_model.dart';

abstract class MapsState extends Equatable {
  const MapsState();

  @override
  List<Object?> get props => [];
}

class MapsInitial extends MapsState {}

class MapsLoading extends MapsState {}

class LocationsLoaded extends MapsState {
  final List<LocationModel> locations;

  const LocationsLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class SingleLocationLoaded extends MapsState {
  final LocationModel location;

  const SingleLocationLoaded(this.location);

  @override
  List<Object?> get props => [location];
}

class MapsError extends MapsState {
  final String message;

  const MapsError(this.message);

  @override
  List<Object?> get props => [message];
}
