import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/utils/database_service.dart';
import 'package:daydream/components/instrument_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete All Notes'),
          content: const Text(
            'Are you sure you want to delete all notes? This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                await DatabaseService.deleteAllNotes();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notes have been deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const InstrumentText('Settings', fontSize: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'Delete All Notes',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Permanently delete all your notes',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () => _showDeleteConfirmationDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
