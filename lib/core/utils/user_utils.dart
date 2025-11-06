import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

String? getYearId() {
  final userBox = Hive.box('userBox');
  return userBox.get('yearId');
}

DateTime convertFirebaseTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else {
    return DateTime.now();
  }
}
