import 'package:hive_flutter/hive_flutter.dart';
import 'types.dart';

class DatabaseService {
  static const String notesBoxName = 'notes';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(notesBoxName);
  }

  // Note operations
  static Future<void> saveNote(Note note) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    await box.put(note.date, note);
  }

  static Future<Note?> getNoteByDate(DateTime date) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    final notes = box.values.toList();
    return notes.firstWhere(
      (note) =>
          note.date.year == date.year &&
          note.date.month == date.month &&
          note.date.day == date.day,
      orElse:
          () => Note(
            date: DateTime(1970, 1, 1),
            plainContent: 'Error',
            content: [],
            id: "ERROR",
            isGenerated: false,
          ),
    );
  }

  static Future<List<Note>> getAllNotes() async {
    final box = await Hive.openBox<Note>(notesBoxName);
    return box.values.toList();
  }

  static Future<void> deleteNote(DateTime date) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    await box.delete(date);
  }

  static Future<void> deleteAllNotes() async {
    final box = await Hive.openBox<Note>(notesBoxName);
    await box.clear();
  }
}
