import 'package:hive/hive.dart';

// This file will contain the Hive configuration and initialization logic.
class HiveConfig {
  static Future<void> initializeHive() async {
    // Initialize Hive
    Hive.init('hive_data');

    // Register adapters here
    // Example: Hive.registerAdapter(UserAdapter());
  }
}
