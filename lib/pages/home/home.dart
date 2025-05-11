import 'package:daydream/components/home/note_card.dart';
import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/pages/note/note_page.dart';
import 'package:daydream/pages/settings/settings_page.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this page
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all notes from Hive
      final notes = await HiveLocal.getAllNotes();

      // Check for notes that need story generation
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (var note in notes) {
        final noteDate = DateTime(
          note.date.year,
          note.date.month,
          note.date.day,
        );
        if (!note.isGenerated && noteDate.isBefore(today)) {
          final updatedNote = await _generateStory(note);
          await HiveLocal.saveNote(updatedNote);
        }
      }

      // Get updated notes after generation
      final updatedNotes = await HiveLocal.getAllNotes();

      // Check if we need to create a note for today
      final hasNoteForToday = updatedNotes.any((note) {
        final noteDate = DateTime(
          note.date.year,
          note.date.month,
          note.date.day,
        );
        return noteDate == today;
      });

      if (!hasNoteForToday) {
        final newNote = Note(
          date: now,
          content: [],
          plainContent: "",
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isGenerated: false,
        );
        await HiveLocal.saveNote(newNote);
        updatedNotes.add(newNote);
      }

      // Sort notes by date (newest first)
      updatedNotes.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _notes = updatedNotes;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = 'Failed to load notes. Please try again.';
        });
      }
    }
  }

  Future<void> _navigateToNote(Note note) async {
    setState(() {
      _isRefreshing = true;
    });

    // Fetch the latest note from Hive before navigating
    final latestNote = await HiveLocal.getNoteById(note.id) ?? note;

    await Navigator.push<Note>(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                SingleNote(note: latestNote),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    if (mounted) {
      await _loadNotes();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Today';
    } else if (noteDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

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

  Future<void> _createTestNote() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final testNote = Note(
      date: yesterday,
      content: [
        {'insert': 'This is a test note from yesterday'},
      ],
      plainContent: 'This is a test note from yesterday',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isGenerated: false,
    );

    await HiveLocal.saveNote(testNote);
    await _loadNotes();
  }

  Future<Note> _generateStory(Note note) async {
    final generatedContent = [
      {
        'insert':
            'Generated story for ${DateFormat('MMM d, yyyy').format(note.date)}:\n\n',
        'attributes': {'header': 1},
      },
      {
        'insert': 'A Tale of Mystery and Discovery\n\n',
        'attributes': {'header': 2},
      },
      {
        'insert':
            'Once upon a time, in a distant land, there lived a curious adventurer who loved to explore the unknown.\n\n',
      },
      {
        'insert': 'The Daily Adventures\n',
        'attributes': {'header': 2},
      },
      {
        'insert':
            'Every day they would venture further into the mysterious forests that surrounded their village, discovering new plants and creatures that no one had ever seen before. The villagers thought they were strange for spending so much time alone in the woods, but our hero didn\'t mind - they knew that true discovery required dedication and patience.\n\n',
      },
      {
        'insert': 'The Mysterious Archway\n',
        'attributes': {'header': 2},
      },
      {
        'insert':
            'One particularly foggy morning, they stumbled upon an ancient stone archway covered in mysterious symbols. The symbols seemed to glow with an otherworldly light, pulsing gently in the mist. As they reached out to touch the weathered stone, they felt a strange tingling sensation course through their body.\n\n',
      },
      {
        'insert': 'The Ethereal Performance\n',
        'attributes': {'header': 2},
      },
      {
        'insert':
            'Suddenly, the fog began to swirl and condense, forming shapes and patterns in the air. The adventurer stood transfixed as the mist transformed into ghostly figures that danced and twirled around them. Each figure seemed to tell a different story - tales of long-lost civilizations, magical creatures, and epic battles between good and evil. Hours passed like minutes as they watched the ethereal performance, completely losing track of time.\n\n',
      },
      {
        'insert': 'A New Beginning\n',
        'attributes': {'header': 2},
      },
      {
        'insert':
            'When the sun finally began to set, the figures slowly faded away, leaving our hero with an incredible story to tell. But would anyone believe them? The villagers had always been skeptical of their tales, but this time was different. This time they had proof - the ancient symbols had left permanent marks on their hands, marks that glowed with the same mysterious light they had witnessed in the forest.\n\nFrom that day forward, the adventurer\'s life was never the same. They had become a bridge between two worlds, keeper of ancient secrets, and guardian of forgotten tales. And this was just the beginning of their incredible journey into the unknown...',
      },
    ];

    return Note(
      date: note.date,
      content: generatedContent,
      plainContent:
          'Generated story for ${DateFormat('MMM d, yyyy').format(note.date)}',
      id: note.id,
      isGenerated: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Storyteller';

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
                            title: const Text('Account'),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SettingsPage(),
                                    ),
                                  );
                                },
                                child: const Text('Settings'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _createTestNote();
                                },
                                child: const Text('Create Test Note'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await showPrivacyDialog(context);
                                },
                                child: const Text('Privacy'),
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
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.dmSans(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _loadNotes,
                        child: Text(
                          'Retry',
                          style: GoogleFonts.dmSans(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _isLoading
                          ? const Center(
                            key: ValueKey('loading'),
                            child: CircularProgressIndicator(),
                          )
                          : _notes.isEmpty
                          ? Center(
                            key: const ValueKey('empty'),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  'Every story starts somewhere.',

                                  style: GoogleFonts.instrumentSerif(
                                    fontSize: 30,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  // center
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.add,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create Today\'s Note',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final newNote = Note(
                                      date: now,
                                      content: [],
                                      plainContent: "",
                                      id:
                                          DateTime.now().millisecondsSinceEpoch
                                              .toString(),
                                      isGenerated: false,
                                    );

                                    await HiveLocal.saveNote(newNote);
                                    await _loadNotes();
                                  },
                                ),
                              ],
                            ),
                          )
                          : Stack(
                            key: const ValueKey('notes'),
                            children: [
                              ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: _notes.length,
                                itemBuilder: (context, index) {
                                  final note = _notes[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Hero(
                                      tag: 'note-${note.id}',
                                      child: GestureDetector(
                                        onTap: () => _navigateToNote(note),
                                        child: NoteCard(note: note),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (_isRefreshing)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: SizedBox(
                                    height: 3,
                                    child: LinearProgressIndicator(
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
