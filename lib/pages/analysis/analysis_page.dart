import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/components/premium_drawer.dart';
import 'package:daydream/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:fl_chart/fl_chart.dart';
import 'detailed_analysis_page.dart';

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
  DateTime? _selectedDay;

  // Add dummy premium status
  final bool _isPremium =
      true; // This would normally come from a subscription service

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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 2, color: Colors.transparent),
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
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
                        'We\'ve analyzed your journal entries to create a unique story of your emotional journey.',
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
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      DreamRoutes.storyAnalysisRoute,
                    );
                  },
                  child: Text(
                    'View Analysis',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                if (_isPremium) ...[
                  const SizedBox(height: 24),
                  _buildStatisticsCard(),
                  const SizedBox(height: 24),
                  _buildDetailedInsightPanel(),
                ] else ...[
                  const SizedBox(height: 24),
                  _buildPremiumPromptCard(),
                  const SizedBox(height: 24),
                  _buildBasicStatsCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final isWide = MediaQuery.of(context).size.width > 600;
    final statItems = [
      _buildStatItem(
        'Emotional Profile',
        _getMostFrequentMood(),
        Colors.pink.shade300,
        CupertinoIcons.heart_fill,
        'Your dominant emotional state',
      ),
      _buildStatItem(
        'Primary Theme',
        _getMostFrequentTag(),
        Colors.blue.shade300,
        CupertinoIcons.tag_fill,
        'Most recurring topic',
      ),
      _buildStatItem(
        'Mood Balance',
        _getAverageMood(),
        Colors.purple.shade300,
        CupertinoIcons.chart_bar_alt_fill,
        'Your emotional equilibrium',
      ),
      _buildStatItem(
        'Consistency',
        _getWritingStreak(),
        Colors.green.shade300,
        CupertinoIcons.flame_fill,
        'Longest writing streak',
      ),
      _buildStatItem(
        'Total Journey',
        _getTotalWords(),
        Colors.orange.shade300,
        CupertinoIcons.doc_text_fill,
        'Words of self-reflection',
      ),
      _buildStatItem(
        'Depth',
        _getAverageWordsPerEntry(),
        Colors.teal.shade300,
        CupertinoIcons.text_quote,
        'Average entry length',
      ),
      _buildStatItem(
        'Peak Hours',
        _getMostProductiveTime(),
        Colors.indigo.shade300,
        CupertinoIcons.clock_fill,
        'Most productive time',
      ),
      _buildStatItem(
        'Reflection Day',
        _getMostReflectiveDay(),
        Colors.amber.shade300,
        CupertinoIcons.calendar,
        'Most thoughtful day',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: Colors.pink.shade300,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI-Powered Insights',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        isWide
            ? Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  statItems
                      .map(
                        (item) => SizedBox(
                          width: (MediaQuery.of(context).size.width - 88) / 2,
                          child: item,
                        ),
                      )
                      .toList(),
            )
            : Column(
              children:
                  statItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: item,
                        ),
                      )
                      .toList(),
            ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInsightPanel() {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Why You Feel This Way',
        style: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      leading: Icon(
        CupertinoIcons.lightbulb_fill,
        color: Colors.pink.shade300,
        size: 26,
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInsightSection(
          'Emotional Patterns',
          _getEmotionalPatternInsight(),
          CupertinoIcons.heart,
          Colors.pink.shade300,
        ),
        const SizedBox(height: 24),
        _buildInsightSection(
          'Writing Behavior',
          _getWritingBehaviorInsight(),
          CupertinoIcons.pencil,
          Colors.blue.shade300,
        ),
        const SizedBox(height: 24),
        _buildInsightSection(
          'Topic Analysis',
          _getTopicAnalysisInsight(),
          CupertinoIcons.tag,
          Colors.purple.shade300,
        ),
        const SizedBox(height: 24),
        _buildInsightSection(
          'Self-Reflection Patterns',
          _getSelfReflectionInsight(),
          CupertinoIcons.person,
          Colors.teal.shade300,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            'These insights are generated based on AI analysis of your journal entries and may evolve as you continue journaling.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              height: 1.6,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for statistics
  String _getMostFrequentMood() {
    if (_moodFrequency.isEmpty) return 'N/A';
    return _moodFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String _getMostFrequentTag() {
    if (_tagFrequency.isEmpty) return 'N/A';
    return _tagFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String _getAverageMood() {
    if (_moodFrequency.isEmpty) return 'N/A';
    double totalMoodValue = 0;
    int moodCount = 0;
    for (var note in _notes) {
      if (note.mood != null) {
        totalMoodValue += _getMoodValue(note.mood!);
        moodCount++;
      }
    }
    return moodCount > 0
        ? _getMoodFromValue(totalMoodValue / moodCount)
        : 'N/A';
  }

  String _getWritingStreak() {
    if (_notes.isEmpty) return 'N/A';
    final sortedDates = _notes.map((n) => n.date).toList()..sort();
    int currentStreak = 1;
    int maxStreak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final difference = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (difference == 1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else {
        currentStreak = 1;
      }
    }
    return '$maxStreak days';
  }

  String _getTotalWords() {
    if (_notes.isEmpty) return 'N/A';
    int totalWords = 0;
    for (var note in _notes) {
      totalWords += note.plainContent.split(' ').length;
    }
    return '$totalWords words';
  }

  String _getAverageWordsPerEntry() {
    if (_notes.isEmpty) return 'N/A';
    int totalWords = 0;
    for (var note in _notes) {
      totalWords += note.plainContent.split(' ').length;
    }
    return '${(totalWords / _notes.length).round()} words per entry';
  }

  String _getMostProductiveTime() {
    if (_notes.isEmpty) return 'N/A';
    final Map<int, int> entriesByHour = {};
    for (var note in _notes) {
      final hour = note.date.hour;
      entriesByHour[hour] = (entriesByHour[hour] ?? 0) + 1;
    }
    final mostProductiveHour =
        entriesByHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return '$mostProductiveHour:00';
  }

  String _getMostReflectiveDay() {
    if (_notes.isEmpty) return 'N/A';
    final Map<int, int> entriesByDay = {};
    for (var note in _notes) {
      final day = note.date.weekday;
      entriesByDay[day] = (entriesByDay[day] ?? 0) + 1;
    }
    final mostReflectiveDayNum =
        entriesByDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return _getDayName(mostReflectiveDayNum);
  }

  double _getMoodValue(String mood) {
    final moodValues = {
      'happy': 5.0,
      'excited': 5.0,
      'joyful': 5.0,
      'content': 4.0,
      'calm': 4.0,
      'neutral': 3.0,
      'tired': 2.0,
      'sad': 1.0,
      'angry': 1.0,
      'anxious': 1.0,
    };
    return moodValues[mood.toLowerCase()] ?? 3.0;
  }

  String _getMoodFromValue(double value) {
    if (value >= 4.5) return 'happy';
    if (value >= 3.5) return 'content';
    if (value >= 2.5) return 'neutral';
    if (value >= 1.5) return 'tired';
    return 'sad';
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String _getEmotionalPatternInsight() {
    if (_moodFrequency.isEmpty) return 'Not enough data to generate insights.';

    final sortedMoods =
        _moodFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topMood = sortedMoods.first.key;
    int positiveCount = 0;
    int negativeCount = 0;

    for (var entry in _moodFrequency.entries) {
      if ([
        'happy',
        'excited',
        'joyful',
        'content',
        'calm',
      ].contains(entry.key.toLowerCase())) {
        positiveCount += entry.value;
      } else if ([
        'sad',
        'angry',
        'anxious',
        'tired',
      ].contains(entry.key.toLowerCase())) {
        negativeCount += entry.value;
      }
    }

    final totalMoods = positiveCount + negativeCount;
    final positiveRatio = totalMoods > 0 ? positiveCount / totalMoods : 0;

    if (positiveRatio > 0.7) {
      return 'Your journal entries reveal a predominantly positive emotional state. You express $topMood feelings frequently, which suggests you\'re experiencing a period of well-being. Your emotional resilience appears strong, helping you navigate life\'s challenges while maintaining an optimistic outlook.';
    } else if (positiveRatio > 0.4) {
      return 'Your emotional pattern shows a balance between positive and negative states, with a slight preference for $topMood moments. This indicates healthy emotional processing - you acknowledge both joys and challenges in your life without suppressing difficult feelings.';
    } else {
      return 'Your entries reflect a pattern where challenging emotions like $topMood appear frequently. This period of introspection may indicate you\'re processing important life events. Remember that acknowledging these feelings is a sign of emotional awareness and the first step toward growth.';
    }
  }

  String _getWritingBehaviorInsight() {
    if (_notes.isEmpty) return 'Not enough data to generate insights.';

    final Map<int, int> entriesByHour = {};
    final Map<int, int> entriesByDay = {};
    final List<int> wordCounts = [];

    for (var note in _notes) {
      final hour = note.date.hour;
      final day = note.date.weekday;
      final wordCount = note.plainContent.split(' ').length;

      entriesByHour[hour] = (entriesByHour[hour] ?? 0) + 1;
      entriesByDay[day] = (entriesByDay[day] ?? 0) + 1;
      wordCounts.add(wordCount);
    }

    final mostActiveHour =
        entriesByHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final mostActiveDay =
        entriesByDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final avgWordCount =
        wordCounts.isNotEmpty
            ? wordCounts.reduce((a, b) => a + b) / wordCounts.length
            : 0;

    final timeOfDay =
        mostActiveHour < 12
            ? 'morning'
            : mostActiveHour < 18
            ? 'afternoon'
            : 'evening';
    final dayName = _getDayName(mostActiveDay);

    if (avgWordCount > 200) {
      return 'You tend to journal most frequently in the $timeOfDay on $dayName. Your entries are quite detailed (averaging ${avgWordCount.round()} words), suggesting you use journaling as a deep reflective practice. This thorough approach indicates you process experiences fully, which research shows promotes emotional clarity and personal growth.';
    } else if (avgWordCount > 100) {
      return 'Your journaling pattern shows a preference for the $timeOfDay, especially on $dayName. With moderate-length entries (around ${avgWordCount.round()} words), you balance reflection with efficiency. This consistent, focused practice suggests you value regular self-check-ins as part of your routine.';
    } else {
      return 'You typically journal in the $timeOfDay on $dayName with concise entries (about ${avgWordCount.round()} words). This suggests you prefer capturing quick thoughts or key moments rather than extensive reflection. This approach works well for busy schedules and for documenting life\'s highlights without requiring extensive time investment.';
    }
  }

  String _getTopicAnalysisInsight() {
    if (_tagFrequency.isEmpty) return 'Not enough data to generate insights.';

    final sortedTags =
        _tagFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topTags = sortedTags.take(3).map((e) => e.key).toList();
    final personalTags = [
      'family',
      'friends',
      'relationship',
      'love',
      'connection',
    ];
    final workTags = ['work', 'career', 'job', 'project', 'productivity'];
    final wellnessTags = [
      'health',
      'fitness',
      'meditation',
      'exercise',
      'wellness',
      'self-care',
    ];

    int personalCount = 0;
    int workCount = 0;
    int wellnessCount = 0;

    for (var entry in _tagFrequency.entries) {
      if (personalTags.contains(entry.key.toLowerCase())) {
        personalCount += entry.value;
      } else if (workTags.contains(entry.key.toLowerCase())) {
        workCount += entry.value;
      } else if (wellnessTags.contains(entry.key.toLowerCase())) {
        wellnessCount += entry.value;
      }
    }

    final categories = [
      CategoryInsight(personalCount, 'relationships and social connections'),
      CategoryInsight(workCount, 'career and productivity'),
      CategoryInsight(wellnessCount, 'health and self-care'),
    ];

    categories.sort((a, b) => b.count.compareTo(a.count));

    return 'Your journal focuses primarily on ${topTags.join(', ')}, with a particular emphasis on ${categories.first.name}. This suggests these areas are central to your current life experience and personal identity. Your frequent reflection on these topics indicates they hold significant meaning for you and may be areas where you\'re experiencing growth, challenges, or important developments.';
  }

  String _getSelfReflectionInsight() {
    if (_notes.isEmpty) return 'Not enough data to generate insights.';

    final hasConsistentEntries = _notes.length > 5;
    final hasVariedMoods = _moodFrequency.length > 3;
    final hasDetailedEntries = _notes.any(
      (note) => note.plainContent.split(' ').length > 150,
    );

    final sortedDates = _notes.map((n) => n.date).toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final difference = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (difference == 1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else {
        currentStreak = 1;
      }
    }

    final hasLongStreak = maxStreak >= 3;

    if (hasConsistentEntries && hasVariedMoods && hasDetailedEntries) {
      return 'Your journaling practice shows a strong commitment to self-awareness. You consistently document a range of emotional experiences with depth and nuance. This comprehensive approach to self-reflection suggests you value personal growth and emotional intelligence. Research shows this style of reflective practice correlates with enhanced psychological resilience and greater life satisfaction.';
    } else if (hasLongStreak || hasConsistentEntries) {
      return 'Your journaling shows a commendable consistency, with a $maxStreak-day streak at your best. This regular practice indicates you\'ve integrated self-reflection into your routine. While your entries vary in emotional depth, this consistent checking-in process helps you maintain awareness of your experiences and emotional states over time.';
    } else {
      return 'Your journaling pattern appears to be more spontaneous, capturing significant moments rather than following a strict schedule. This approach allows you to document meaningful experiences when they occur. Consider that even this selective journaling provides valuable insights into the moments you find most impactful in your life journey.';
    }
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.teal, Colors.indigo, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange, Colors.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CupertinoIcons.graph_circle_fill,
                          color: Colors.amber.shade700,
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
                ),
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
                    color: Colors.amber.shade50,
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
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.arrow_right,
                        color: Colors.amber.shade700,
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
    );
  }

  Widget _buildPremiumPromptCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.indigo, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16),
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
                        CupertinoIcons.sparkles,
                        color: Colors.purple.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Unlock Premium Features',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Get AI-powered insights and advanced analytics to better understand your journaling patterns.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showPremiumDrawer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Upgrade to Premium',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_fill,
                  color: Colors.blue.shade300,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Basic Statistics',
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
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatItem(
                'Total Entries',
                _notes.length.toString(),
                Colors.blue.shade300,
                CupertinoIcons.doc_text_fill,
                'Your journal entries',
              ),
              _buildStatItem(
                'Total Words',
                _getTotalWords(),
                Colors.orange.shade300,
                CupertinoIcons.text_quote,
                'Words written',
              ),
              _buildStatItem(
                'Writing Streak',
                _getWritingStreak(),
                Colors.green.shade300,
                CupertinoIcons.flame_fill,
                'Longest streak',
              ),
            ],
          ),
        ],
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
      body:
          _notes.isEmpty
              ? Center(
                child: Padding(
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
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
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
                                      'We\'ve analyzed your journal entries to create a unique story of your emotional journey.',
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
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    DreamRoutes.storyAnalysisRoute,
                                  );
                                },
                                child: Text(
                                  'View Analysis',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildPersonalizedAnalysis(),
                    _buildMoodChart(),
                    _buildTagCloud(),
                    _buildReflections(),
                    _buildDetailedAnalysisCard(),
                  ],
                ),
              ),
    );
  }
}
