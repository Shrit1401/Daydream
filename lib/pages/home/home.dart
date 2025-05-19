import 'package:daydream/components/home/note_card.dart';
import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/pages/note/note_page.dart';
import 'package:daydream/pages/settings/settings_page.dart';
import 'package:daydream/pages/analysis/analysis_page.dart';
import 'package:daydream/utils/ai/ai_story.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:daydream/utils/widget_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/components/dream_bubble_loading.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daydream/components/premium_drawer.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
// Create a single instance of Uuid to use throughout the file
final _uuid = Uuid();

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

  final bool isPremium = true;

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
          final updatedNote = await generateStory(note);
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
          id: _uuid.v4(),
          isGenerated: false,
        );
        await HiveLocal.saveNote(newNote);
        updatedNotes.add(newNote);

        // Update widget when creating a new note
        await WidgetService.updateWidget();
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

    if (!mounted) return;
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

  void _showPremiumDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => const PremiumDrawer(key: ValueKey('premium_drawer')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Storyteller';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F3),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
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
                          InstrumentText('Yo $userName', fontSize: 40),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_down,
                                size: 16,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
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
                                      if (!isPremium) {
                                        _showPremiumDrawer();
                                        return;
                                      }
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String title = '';
                                          return CupertinoAlertDialog(
                                            title: const Text(
                                              'Create Custom Note',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CupertinoTextField(
                                                  placeholder:
                                                      'Enter note title',
                                                  onChanged: (value) {
                                                    title = value;
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              CupertinoDialogAction(
                                                child: const Text('Create'),
                                                onPressed: () async {
                                                  if (title.isNotEmpty) {
                                                    final now = DateTime.now();
                                                    final newNote = Note(
                                                      date: now,
                                                      content: [],
                                                      plainContent: "",
                                                      id: _uuid.v4(),
                                                      isGenerated: false,
                                                      title: title,
                                                      isCustom: true,
                                                    );
                                                    await HiveLocal.saveNote(
                                                      newNote,
                                                    );
                                                    if (!mounted) return;
                                                    Navigator.pop(context);
                                                    await _loadNotes();
                                                    _navigateToNote(newNote);
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Create Custom Note'),
                                        const SizedBox(width: 6),
                                        Icon(
                                          CupertinoIcons.star_fill,
                                          size: 14,
                                          color: Colors.amber.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final url = Uri.parse(
                                        'https://daydream.shrit.in/data',
                                      );
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
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
                  const SizedBox(height: 24),
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
                                child: DreamBubbleLoading(),
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
                                          id: _uuid.v4(),
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
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
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
          Positioned(
            bottom: 32,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalysisPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.chart_bar_alt_fill,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Journal Analysis',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
    );
  }
}
