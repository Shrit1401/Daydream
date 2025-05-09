import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/components/home/note_card.dart';
import 'package:daydream/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<Note> notes = [
  Note(
    date: '8th May 2025',
    plainContent: 'going to hrkl class \n Hello shrit how are you?',
    content: {},
    id: '1',
    isGenerated: false,
    note: 'going to class \n Hello shrit how are you?',
  ),
  Note(
    date: '8th May 2025',
    plainContent: 'going to class \n Hello shrit how are you?',
    content: {},

    id: '2',
    isGenerated: false,
    note: 'going to class \n Hello shrit how are you?',
  ),
  Note(
    date: '8th May 2025',
    plainContent: 'going to class \n Hello shrit how are you?',
    content: {},

    id: '3',
    isGenerated: false,
    note: 'going to class \n Hello shrit how are you?',
  ),
  Note(
    date: '8th May 2025',
    plainContent: 'going to class \n Hello shrit how are you?',
    content: {},

    id: '4',
    isGenerated: false,
    note: 'going to class \n Hello shrit how are you?',
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Storyteller';

    Future<void> showPrivacyDialog(BuildContext context) async {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Privacy Policy'),
            content: const Text(
              'Your privacy is important to us. We do not share your data with third parties.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InstrumentText('Welcome $userName', fontSize: 40),
                      Text(
                        "what's up?",
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          size: 20,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: Text('Account'),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Settings'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await showPrivacyDialog(context);
                                },
                                child: const Text('Privacy'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await FirebaseAuth.instance.signOut();
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              isDefaultAction: true,
                              child: const Text('Cancel'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteCard(note: note);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
