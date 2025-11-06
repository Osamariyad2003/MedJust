import 'dart:convert';
import 'package:med_just/features/pomodoro/data/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pomodoro_session_model.dart';
import '../models/pomodoro_settings_model.dart';

class PomodoroDataSource {
  static const String _sessionKey = 'pomodoro_session';
  static const String _settingsKey = 'pomodoro_settings';
  static const String _tasksKey = 'pomodoro_tasks';
  static const String _durationKey = 'pomodoro_duration';
  Future<void> savePomodoroSession(PomodoroSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<PomodoroSessionModel?> getPomodoroSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null) {
      return PomodoroSessionModel.fromJson(
        jsonDecode(sessionJson) as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> savePomodoroSettings(PomodoroSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<PomodoroSettingsModel?> getPomodoroSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      return PomodoroSettingsModel.fromJson(
        jsonDecode(settingsJson) as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> clearPomodoroData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_tasksKey);
    await prefs.remove(_durationKey);
  }

  Future<List<TaskModel>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tasksKey) ?? '[]';
    return TaskModel.decodeList(jsonStr);
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, TaskModel.encodeList(tasks));
  }

  Future<int> getPomodoroDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_durationKey) ?? 25;
  }

  Future<void> setPomodoroDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_durationKey, minutes);
  }
}
