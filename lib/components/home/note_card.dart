import 'package:daydream/pages/note/note_page.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:daydream/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/components/instrument_text.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              note.isCustom
                  ? const Color.fromARGB(255, 245, 232, 158)
                  : const Color(0xFFDEDEDE),
          width: note.isCustom ? 2 : 1,
        ),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFF6F6F9)],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.isCustom && note.title != null)
                              InstrumentText(note.title!, fontSize: 24)
                            else
                              InstrumentText(
                                '${note.date.day} ${getMonthName(note.date.month)} ${note.date.year.toString().substring(2)}',
                                fontSize: 24,
                              ),
                            if (note.isCustom && note.title != null)
                              const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      if (note.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: const Color(0xFFFFA000),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Custom Note',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFA000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!note.isCustom &&
                          DateTime.now().year == note.date.year &&
                          DateTime.now().month == note.date.month &&
                          DateTime.now().day == note.date.day)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.today, size: 14, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                'Today',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (note.isGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1B3FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Story Generated',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.plainContent.isEmpty
                        ? 'Tap to create note...'
                        : note.plainContent.length > 70
                        ? '${note.plainContent.substring(0, 70)}...'
                        : note.plainContent,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          note.plainContent.isEmpty
                              ? Colors.grey.shade500
                              : note.isCustom
                              ? Colors.blue.shade900.withOpacity(0.8)
                              : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      note.isCustom
                          ? Colors.blue.shade100
                          : const Color(0xFFD1B3FF),
                  foregroundColor:
                      note.isCustom ? Colors.blue.shade700 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingleNote(note: note),
                    ),
                  );
                },
                child: Text(
                  'View →',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: note.isCustom ? Colors.blue.shade700 : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
