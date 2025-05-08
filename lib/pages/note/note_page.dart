import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleNote extends StatefulWidget {
  const SingleNote({super.key});

  @override
  State<SingleNote> createState() => _SingleNoteState();
}

class _SingleNoteState extends State<SingleNote> {
  final _dateController = TextEditingController(text: '18 / 11 / 22');
  final _tagController = TextEditingController(text: '#work');
  final _titleController = TextEditingController(text: 'what to discuss');
  final _contentController = TextEditingController(
    text:
        'we have started the analytics phase. we need test access to the app to try out the existing features.\n\nwe need to coordinate a call with management to understand how soon we can start wireframes.\n\nask the client to collect positive and negative references that will help in the work on the concept.',
  );

  @override
  void dispose() {
    _dateController.dispose();
    _tagController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    _dateController.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _titleController,
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
