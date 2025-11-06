import 'package:med_just/features/university_map/data/maps_data_source.dart';
import 'package:med_just/features/university_map/data/maps_model.dart';

class MapsRepository {
  final MapsDataSource _dataSource;

  MapsRepository({MapsDataSource? dataSource})
    : _dataSource = dataSource ?? MapsFirestoreDataSource();

  Future<List<LocationModel>> getAllLocations() async {
    try {
      return await _dataSource.getAllLocations();
    } catch (e) {
      print('Repository error getting all locations: $e');
      return [];
    }
  }

  Future<LocationModel?> getLocationById(String locationId) async {
    try {
      return await _dataSource.getLocationById(locationId);
    } catch (e) {
      print('Repository error getting location by id: $e');
      return null;
    }
  }

  Future<List<LocationModel>> getLocationsByType(String type) async {
    try {
      return await _dataSource.getLocationsByType(type);
    } catch (e) {
      print('Repository error getting locations by type: $e');
      return [];
    }
  }
}
