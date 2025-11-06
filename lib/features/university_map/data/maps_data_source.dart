import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_just/features/university_map/data/maps_model.dart';

abstract class MapsDataSource {
  Future<List<LocationModel>> getAllLocations();
  Future<LocationModel?> getLocationById(String id);
  Future<List<LocationModel>> getLocationsByType(String type);
}

class MapsFirestoreDataSource implements MapsDataSource {
  final FirebaseFirestore _firestore;

  MapsFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LocationModel>> getAllLocations() async {
    try {
      final snapshot = await _firestore.collection('maps').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LocationModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching map locations: $e');
      return [];
    }
  }

  @override
  Future<LocationModel?> getLocationById(String id) async {
    try {
      final doc = await _firestore.collection('maps').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return LocationModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching location by ID: $e');
      return null;
    }
  }

  @override
  Future<List<LocationModel>> getLocationsByType(String type) async {
    try {
      final snapshot =
          await _firestore
              .collection('maps')
              .where('type', isEqualTo: type)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LocationModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching locations by type: $e');
      return [];
    }
  }
}
