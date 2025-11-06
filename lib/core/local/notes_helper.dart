import 'dart:convert';

import 'package:med_just/core/models/notes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoNotesHelper {
  static Future<void> addNote(String videoId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notes_$videoId';
    final notesJson = prefs.getStringList(key) ?? [];
    final note = VideoNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
    );
    notesJson.add(jsonEncode(note.toJson()));
    await prefs.setStringList(key, notesJson);
  }

  static Future<List<VideoNote>> getNotes(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notes_$videoId';
    final notesJson = prefs.getStringList(key) ?? [];
    return notesJson
        .map((noteStr) => VideoNote.fromJson(jsonDecode(noteStr)))
        .toList();
  }

  static Future<void> deleteNote(String videoId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notes_$videoId';
    final notesJson = prefs.getStringList(key) ?? [];
    if (index >= 0 && index < notesJson.length) {
      notesJson.removeAt(index);
      await prefs.setStringList(key, notesJson);
    }
  }

  static Future<void> updateNote(
    String videoId,
    int index,
    String newContent,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notes_$videoId';
    final notesJson = prefs.getStringList(key) ?? [];
    if (index >= 0 && index < notesJson.length) {
      final noteMap = jsonDecode(notesJson[index]);
      noteMap['content'] = newContent;
      notesJson[index] = jsonEncode(noteMap);
      await prefs.setStringList(key, notesJson);
    }
  }
}
