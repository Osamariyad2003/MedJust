import 'package:equatable/equatable.dart';

abstract class MapsEvent extends Equatable {
  const MapsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllLocations extends MapsEvent {}

class LoadLocationById extends MapsEvent {
  final String locationId;

  const LoadLocationById(this.locationId);

  @override
  List<Object?> get props => [locationId];
}

class LoadLocationsByType extends MapsEvent {
  final String type;

  const LoadLocationsByType(this.type);

  @override
  List<Object?> get props => [type];
}
