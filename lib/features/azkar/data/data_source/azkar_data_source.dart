import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/azkar_model.dart';

class AzkarStorage {
  static const _key = 'azkar_items_v2';

  static Future<List<AzkarItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) =>
            AzkarItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveAll(List<AzkarItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  static Future<void> add(AzkarItem item) async {
    final items = await loadAll();
    items.insert(0, item);
    await saveAll(items);
  }

  static Future<void> update(AzkarItem item) async {
    final items = await loadAll();
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      items[idx] = item;
      await saveAll(items);
    }
  }

  static Future<void> delete(String id) async {
    final items = await loadAll();
    items.removeWhere((i) => i.id == id);
    await saveAll(items);
  }

  // legacy toggle full-completed (keeps compatibility)
  static Future<void> toggle(String id) async {
    final items = await loadAll();
    final idx = items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final updated = items[idx].copyWith(completed: !items[idx].completed);
      items[idx] = updated;
      await saveAll(items);
    }
  }

  // toggle a specific day (0 = Sunday .. 6 = Saturday)
  static Future<void> toggleDay(String id, int dayIndex) async {
    if (dayIndex < 0 || dayIndex > 6) return;
    final items = await loadAll();
    final idx = items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final current = List<bool>.from(items[idx].weekChecks);
    current[dayIndex] = !current[dayIndex];
    // optional: set completed if all days are checked
    final allChecked = current.every((v) => v);
    items[idx] = items[idx].copyWith(weekChecks: current, completed: allChecked);
    await saveAll(items);
  }
}
