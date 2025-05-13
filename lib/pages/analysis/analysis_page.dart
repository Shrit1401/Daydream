import 'package:daydream/components/instrument_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:fl_chart/fl_chart.dart';
import 'detailed_analysis_page.dart';
import 'package:table_calendar/table_calendar.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  List<Note> _notes = [];
  Map<String, int> _moodFrequency = {};
  Map<String, int> _tagFrequency = {};
  List<String> _commonReflections = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Color> _moodColors = [
    const Color(0xFFE74C3C), // Red
    const Color(0xFF3498DB), // Blue
    const Color(0xFF2ECC71), // Green
    const Color(0xFFF1C40F), // Yellow
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF1ABC9C), // Turquoise
    const Color(0xFFE67E22), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _loadAnalysis();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    setState(() {});

    try {
      final notes = await HiveLocal.getAllNotes();
      _notes = notes.where((note) => note.isGenerated).toList();

      // Analyze moods
      _moodFrequency = {};
      for (var note in _notes) {
        if (note.mood != null) {
          _moodFrequency[note.mood!] = (_moodFrequency[note.mood!] ?? 0) + 1;
        }
      }

      // Analyze tags
      _tagFrequency = {};
      for (var note in _notes) {
        if (note.tags != null) {
          for (var tag in note.tags!) {
            _tagFrequency[tag] = (_tagFrequency[tag] ?? 0) + 1;
          }
        }
      }

      // Get common reflections
      _commonReflections =
          _notes
              .where((note) => note.reflect != null)
              .map((note) => note.reflect!)
              .toList();

      setState(() {});
      _controller.forward();
    } catch (e) {
      setState(() {});
    }
  }

  Widget _buildHeader() {
    final bool hasEnoughNotes = _notes.length >= 5;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Story Analysis',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasEnoughNotes
                          ? 'We\'ve analyzed your journal entries to create a unique story of your emotional journey.'
                          : 'Create at least 3 journal entries to unlock your personalized story analysis.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                color: hasEnoughNotes ? Colors.black : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                onPressed:
                    hasEnoughNotes
                        ? () {
                          // Scroll to the first section
                          Scrollable.ensureVisible(
                            context,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                        : null,
                child: Text(
                  'View Analysis',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasEnoughNotes ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          if (!hasEnoughNotes) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle_fill,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep journaling! You need ${3 - _notes.length} more ${_notes.length == 4 ? 'entry' : 'entries'} for a complete analysis.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalizedAnalysis() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.book_fill,
                        color: Colors.purple.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Story',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Emotional Journey',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generateStorySummary(),
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Colors.purple.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth & Patterns',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generateGrowthInsights(),
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Colors.blue.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _generateStorySummary() {
    if (_notes.isEmpty) return '';

    final mostFrequentMood =
        _moodFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final topTags =
        _tagFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final mainThemes = topTags.take(3).map((e) => e.key).join(', ');

    return 'Your journal entries reveal a journey marked by $mostFrequentMood moments. '
        'You\'ve been exploring themes of $mainThemes, showing a deep engagement with your experiences. '
        'Your writing reflects a thoughtful approach to understanding your emotions and experiences.';
  }

  String _generateGrowthInsights() {
    if (_notes.isEmpty) return '';

    final uniqueMoods = _moodFrequency.length;
    final totalEntries = _notes.length;
    final reflectionCount = _commonReflections.length;

    return 'Over $totalEntries entries, you\'ve expressed $uniqueMoods different emotional states, '
        'showing a rich emotional landscape. Your $reflectionCount reflections demonstrate '
        'a growing self-awareness and ability to process your experiences deeply.';
  }

  Widget _buildMoodChart() {
    if (_moodFrequency.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.heart_fill,
                        color: Colors.red.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Emotional Journey',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sections:
                              _moodFrequency.entries.map((entry) {
                                final index = _moodFrequency.keys
                                    .toList()
                                    .indexOf(entry.key);
                                return PieChartSectionData(
                                  value: entry.value.toDouble(),
                                  title: '',
                                  radius: 80,
                                  color: _moodColors[index % _moodColors.length]
                                      .withOpacity(0.8),
                                );
                              }).toList(),
                          centerSpaceRadius: 50,
                          sectionsSpace: 2,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_notes.length}',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Entries',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _moodFrequency.entries.map((entry) {
                        final index = _moodFrequency.keys.toList().indexOf(
                          entry.key,
                        );
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _moodColors[index % _moodColors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.key} (${entry.value})',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagCloud() {
    if (_tagFrequency.isEmpty) return const SizedBox.shrink();

    final sortedTags =
        _tagFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(8).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.tag_fill,
                        color: Colors.blue.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Common Themes',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      topTags.map((entry) {
                        final size = 12 + (entry.value * 1.5).toDouble();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.key,
                            style: GoogleFonts.dmSans(
                              fontSize: size,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflections() {
    if (_commonReflections.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.lightbulb_fill,
                        color: Colors.amber.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Key Insights',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ..._commonReflections.map(
                  (reflection) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reflection,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
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
      ),
    );
  }

  Widget _buildDetailedAnalysisCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.graph_circle_fill,
                        color: Colors.indigo.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Want More Insights?',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Author\'s crazy obession with his graphs, overdone with every kind  of graph developer could find.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailedAnalysisPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Detailed Analysis',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.arrow_right,
                          color: Colors.indigo.shade700,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Note> get _notesForSelectedDay {
    if (_selectedDay == null) return [];
    return _notes
        .where(
          (note) =>
              note.date.year == _selectedDay!.year &&
              note.date.month == _selectedDay!.month &&
              note.date.day == _selectedDay!.day,
        )
        .toList();
  }

  String _moodToEmoji(String? mood) {
    switch (mood) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return '😄';
      case 'content':
      case 'calm':
        return '😊';
      case 'neutral':
        return '😐';
      case 'tired':
        return '😴';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'anxious':
        return '😰';
      default:
        return '📝';
    }
  }

  Map<DateTime, List<Note>> get _notesByDay {
    final map = <DateTime, List<Note>>{};
    for (var note in _notes) {
      final day = DateTime(note.date.year, note.date.month, note.date.day);
      map.putIfAbsent(day, () => []).add(note);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final hasNotes = _notes.isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: InstrumentText('Your Story Analysis', fontSize: 32),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar section
            if (hasNotes)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: TableCalendar<Note>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) =>
                              _selectedDay != null &&
                              day.year == _selectedDay!.year &&
                              day.month == _selectedDay!.month &&
                              day.day == _selectedDay!.day,
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) {
                        final notes =
                            _notesByDay[DateTime(
                              day.year,
                              day.month,
                              day.day,
                            )] ??
                            [];
                        return notes;
                      },
                      headerStyle: HeaderStyle(
                        titleTextStyle: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        formatButtonTextStyle: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(color: Colors.purple.shade200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leftChevronIcon: Icon(
                          CupertinoIcons.chevron_left,
                          color: Colors.purple.shade400,
                          size: 22,
                        ),
                        rightChevronIcon: Icon(
                          CupertinoIcons.chevron_right,
                          color: Colors.purple.shade400,
                          size: 22,
                        ),
                        titleCentered: true,
                        formatButtonVisible: true,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                        weekendStyle: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.purple.shade300,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.purple.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade200.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        defaultTextStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        weekendTextStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Colors.purple.shade300,
                          fontWeight: FontWeight.w500,
                        ),
                        outsideTextStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Colors.grey.shade300,
                        ),
                        cellMargin: const EdgeInsets.all(4),
                        cellPadding: const EdgeInsets.all(0),
                        markerDecoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, notes) {
                          if (notes.isNotEmpty) {
                            // Show the emoji of the most frequent mood for the day
                            final moods =
                                notes
                                    .map((n) => n.mood)
                                    .whereType<String>()
                                    .toList();
                            String? mood;
                            if (moods.isNotEmpty) {
                              final freq = <String, int>{};
                              for (var m in moods) {
                                freq[m] = (freq[m] ?? 0) + 1;
                              }
                              mood =
                                  freq.entries
                                      .reduce(
                                        (a, b) => a.value > b.value ? a : b,
                                      )
                                      .key;
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _moodToEmoji(mood),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                              ],
                            );
                          }
                          return null;
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.shade400,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.shade200.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 17,
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            if (hasNotes &&
                _selectedDay != null &&
                _notesForSelectedDay.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._notesForSelectedDay.map(
                      (note) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade100.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _moodToEmoji(note.mood),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      note.plainContent.length > 40
                                          ? '${note.plainContent.substring(0, 40)}...'
                                          : note.plainContent,
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (note.tags != null &&
                                  note.tags!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Divider(
                                  color: Colors.purple.shade100,
                                  thickness: 1,
                                  height: 1,
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children:
                                      note.tags!
                                          .map(
                                            (tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.shade100
                                                    .withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                tag,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  color: Colors.purple.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildHeader(),
            if (!hasNotes)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 48.0,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_search,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No journal entries yet',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'After creating your first journal entry, wait until the end of the day to unlock detailed insights and visualizations of your emotional journey.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            if (hasNotes) ...[
              _buildPersonalizedAnalysis(),
              _buildMoodChart(),
              _buildTagCloud(),
              _buildReflections(),
              _buildDetailedAnalysisCard(),
            ],
          ],
        ),
      ),
    );
  }
}
