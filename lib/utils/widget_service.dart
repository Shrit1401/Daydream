import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uuid/uuid.dart';

class WidgetService {
  static const String appGroupID = "group.homeScreenApp";
  static const String iosWidgetName = "HomeWidget";
  static const String dataKey = "text_from_flutter";
  static final _uuid = Uuid();

  static Future<void> updateWidget() async {
    try {
      // Get today's note
      final notes = await HiveLocal.getAllNotes();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayNote = notes.firstWhere(
        (note) {
          final noteDate = DateTime(
            note.date.year,
            note.date.month,
            note.date.day,
          );
          return noteDate == today;
        },
        orElse:
            () => Note(
              date: now,
              content: [],
              plainContent: "",
              id: _uuid.v4(),
              isGenerated: false,
            ),
      );

      // Save the note content to widget
      await HomeWidget.saveWidgetData(dataKey, todayNote.plainContent);
      await HomeWidget.updateWidget(
        iOSName: iosWidgetName,
        androidName: iosWidgetName,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}
