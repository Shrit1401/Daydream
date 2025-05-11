import 'package:hive_flutter/hive_flutter.dart';
import '../types/types.dart';

class HiveLocal {
  static const String notesBoxName = 'notes';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here if needed
  }

  static Future<Box<Note>> _getBox() async {
    if (Hive.isBoxOpen(notesBoxName)) {
      return Hive.box<Note>(notesBoxName);
    } else {
      return await Hive.openBox<Note>(notesBoxName);
    }
  }

  // Note operations
  static Future<void> saveNote(Note note) async {
    final box = await _getBox();
    await box.put(note.id, note);
  }

  static Future<Note?> getNoteById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  static Future<List<Note>> getAllNotes() async {
    final box = await _getBox();
    return box.values.toList();
  }

  static Future<void> deleteNote(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  static Future<void> deleteAllNotes() async {
    final box = await _getBox();
    await box.clear();
  }
}
