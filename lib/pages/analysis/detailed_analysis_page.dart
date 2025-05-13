import 'package:daydream/components/instrument_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daydream/components/analysis/sin_cos_chart.dart';
import 'package:daydream/components/dream_bubble_loading.dart';
import 'package:table_calendar/table_calendar.dart';

class DetailedAnalysisPage extends StatefulWidget {
  const DetailedAnalysisPage({super.key});
  @override
  State<DetailedAnalysisPage> createState() => _DetailedAnalysisPageState();
}

class _DetailedAnalysisPageState extends State<DetailedAnalysisPage>
    with SingleTickerProviderStateMixin {
  List<Note> _notes = [];
  bool _isLoading = true;
  Map<String, int> _moodFrequency = {};
  Map<String, int> _tagFrequency = {};
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // New statistics variables
  String _mostFrequentMood = '';
  String _mostFrequentTag = '';
  String _averageMood = '';
  String _writingStreak = '';
  String _totalWords = '';
  String _averageWordsPerEntry = '';
  String _mostProductiveTime = '';
  String _mostReflectiveDay = '';

  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
    setState(() {
      _isLoading = true;
    });

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

      // Calculate additional statistics
      _calculateStatistics();

      setState(() {
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStatistics() {
    if (_notes.isEmpty) return;

    // Most frequent mood
    _mostFrequentMood =
        _moodFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Most frequent tag
    _mostFrequentTag =
        _tagFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Average mood
    double totalMoodValue = 0;
    int moodCount = 0;
    for (var note in _notes) {
      if (note.mood != null) {
        totalMoodValue += _getMoodValue(note.mood!);
        moodCount++;
      }
    }
    _averageMood =
        moodCount > 0
            ? _getMoodFromValue(totalMoodValue / moodCount)
            : 'neutral';

    // Writing streak
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
    _writingStreak = '$maxStreak days';

    // Word count statistics
    int totalWords = 0;
    for (var note in _notes) {
      totalWords += note.plainContent.split(' ').length;
    }
    _totalWords = '$totalWords words';
    _averageWordsPerEntry =
        '${(totalWords / _notes.length).round()} words per entry';

    // Most productive time
    final Map<int, int> entriesByHour = {};
    for (var note in _notes) {
      final hour = note.date.hour;
      entriesByHour[hour] = (entriesByHour[hour] ?? 0) + 1;
    }
    final mostProductiveHour =
        entriesByHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    _mostProductiveTime = '$mostProductiveHour:00';

    // Most reflective day
    final Map<int, int> entriesByDay = {};
    for (var note in _notes) {
      final day = note.date.weekday;
      entriesByDay[day] = (entriesByDay[day] ?? 0) + 1;
    }
    final mostReflectiveDayNum =
        entriesByDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    _mostReflectiveDay = _getDayName(mostReflectiveDayNum);
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

  Widget _buildStatisticsCard() {
    final isWide = MediaQuery.of(context).size.width > 600;
    final statItems = [
      _buildStatItem(
        'Emotional Profile',
        _mostFrequentMood,
        Colors.pink.shade300,
        CupertinoIcons.heart_fill,
        'Your dominant emotional state',
      ),
      _buildStatItem(
        'Primary Theme',
        _mostFrequentTag,
        Colors.blue.shade300,
        CupertinoIcons.tag_fill,
        'Most recurring topic',
      ),
      _buildStatItem(
        'Mood Balance',
        _averageMood,
        Colors.purple.shade300,
        CupertinoIcons.chart_bar_alt_fill,
        'Your emotional equilibrium',
      ),
      _buildStatItem(
        'Consistency',
        _writingStreak,
        Colors.green.shade300,
        CupertinoIcons.flame_fill,
        'Longest writing streak',
      ),
      _buildStatItem(
        'Total Journey',
        _totalWords,
        Colors.orange.shade300,
        CupertinoIcons.doc_text_fill,
        'Words of self-reflection',
      ),
      _buildStatItem(
        'Depth',
        _averageWordsPerEntry,
        Colors.teal.shade300,
        CupertinoIcons.text_quote,
        'Average entry length',
      ),
      _buildStatItem(
        'Peak Hours',
        _mostProductiveTime,
        Colors.indigo.shade300,
        CupertinoIcons.clock_fill,
        'Most productive time',
      ),
      _buildStatItem(
        'Reflection Day',
        _mostReflectiveDay,
        Colors.amber.shade300,
        CupertinoIcons.calendar,
        'Most thoughtful day',
      ),
    ];

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
                                  width:
                                      (MediaQuery.of(context).size.width - 88) /
                                      2,
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb_fill,
                        color: Colors.pink.shade300,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your journal shows a ${_getMoodInsight()} pattern. Consider exploring this theme further in your next entry.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
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

  String _getMoodInsight() {
    if (_moodFrequency.isEmpty) return 'neutral';

    final sortedMoods =
        _moodFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedMoods.length >= 2) {
      final topMood = sortedMoods[0].key;
      final secondMood = sortedMoods[1].key;
      final topCount = sortedMoods[0].value;
      final secondCount = sortedMoods[1].value;

      if (topCount > secondCount * 1.5) {
        return 'strongly $topMood';
      } else if (topCount > secondCount) {
        return 'moderately $topMood with some $secondMood';
      } else {
        return 'balanced between $topMood and $secondMood';
      }
    }

    return sortedMoods[0].key;
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
    String subtitle,
  ) {
    return Container(
      // Full width on mobile, half on wide screens
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

  Widget _buildMoodTrendChart() {
    if (_notes.isEmpty) return const SizedBox.shrink();

    final sortedNotes = List<Note>.from(_notes)
      ..sort((a, b) => a.date.compareTo(b.date));

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
                        CupertinoIcons.graph_circle_fill,
                        color: Colors.purple.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mood Trends',
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
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _getMoodFromValue(value),
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                            reservedSize: 42,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= sortedNotes.length) {
                                return const SizedBox.shrink();
                              }
                              final date = sortedNotes[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(sortedNotes.length, (index) {
                            final mood = sortedNotes[index].mood;
                            final moodValue = _getMoodValue(mood ?? '');
                            return FlSpot(index.toDouble(), moodValue);
                          }),
                          isCurved: true,
                          color: Colors.purple.shade300,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.purple.shade300,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.purple.shade50,
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.purple.shade100,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final note = sortedNotes[barSpot.x.toInt()];
                              return LineTooltipItem(
                                '${note.date.day}/${note.date.month}\n',
                                GoogleFonts.dmSans(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Mood: ${note.mood ?? "neutral"}\n',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (note.reflect != null)
                                    TextSpan(
                                      text: 'Reflection: ${note.reflect}',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                        getTouchedSpotIndicator: (
                          LineChartBarData barData,
                          List<int> spotIndexes,
                        ) {
                          return spotIndexes.map((spotIndex) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: Colors.purple.shade300,
                                strokeWidth: 2,
                                dashArray: [5, 5],
                              ),
                              FlDotData(
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 8,
                                    color: Colors.purple.shade300,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your emotional journey over time',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  Widget _buildMoodPieChart() {
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
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.chart_pie_fill,
                        color: Colors.indigo.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mood Distribution',
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
                  child: PieChart(
                    PieChartData(
                      sections:
                          _moodFrequency.entries.map((entry) {
                            final index = _moodFrequency.keys.toList().indexOf(
                              entry.key,
                            );
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              title: '${entry.key}\n${entry.value}',
                              radius: 80,
                              titleStyle: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              color:
                                  [
                                    Colors.indigo.shade300,
                                    Colors.purple.shade300,
                                    Colors.blue.shade300,
                                    Colors.teal.shade300,
                                    Colors.green.shade300,
                                  ][index % 5],
                            );
                          }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      startDegreeOffset: -90,
                      centerSpaceColor: Colors.white,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (event is FlTapUpEvent) {
                            final section = pieTouchResponse?.touchedSection;
                            if (section != null) {
                              final mood =
                                  _moodFrequency.keys.toList()[section
                                      .touchedSectionIndex];
                              final count = _moodFrequency[mood]!;
                              final percentage =
                                  (count / _notes.length * 100).round();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$mood: $count entries ($percentage%)',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: Colors.indigo.shade300,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Distribution of your emotional states',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  Widget _buildTagDistributionChart() {
    if (_tagFrequency.isEmpty) return const SizedBox.shrink();

    final sortedTags =
        _tagFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).toList();

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
                      'Tag Distribution',
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
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topTags.first.value.toDouble() * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blue.shade100,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final tag = topTags[groupIndex].key;
                            final count = topTags[groupIndex].value;
                            final percentage =
                                (count / _notes.length * 100).round();
                            return BarTooltipItem(
                              '$tag\n',
                              GoogleFonts.dmSans(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '$count entries ($percentage%)',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topTags.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  topTags[value.toInt()].key,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: List.generate(
                        topTags.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: topTags[index].value.toDouble(),
                              color: Colors.blue.shade300,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: topTags.first.value.toDouble(),
                                color: Colors.blue.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Most common themes in your journal',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  Widget _buildTagCandlestickChart() {
    if (_tagFrequency.isEmpty) return const SizedBox.shrink();

    final sortedTags =
        _tagFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).toList();

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
                        color: Colors.cyan.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.chart_bar_fill,
                        color: Colors.cyan.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Theme Intensity',
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
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topTags.first.value.toDouble() * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.cyan.shade100,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${topTags[groupIndex].key}\n',
                              GoogleFonts.dmSans(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '${rod.toY.toInt()}',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topTags.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  topTags[value.toInt()].key,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      barGroups: List.generate(
                        topTags.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: topTags[index].value.toDouble(),
                              color: Colors.cyan.shade300,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: topTags.first.value.toDouble(),
                                color: Colors.cyan.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildWritingPatternsChart() {
    if (_notes.isEmpty) return const SizedBox.shrink();

    final Map<int, int> entriesByHour = {};
    for (var note in _notes) {
      final hour = note.date.hour;
      entriesByHour[hour] = (entriesByHour[hour] ?? 0) + 1;
    }

    // Find the maximum value for scaling
    final maxValue = entriesByHour.values.fold(
      0,
      (max, value) => value > max ? value : max,
    );

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
                        CupertinoIcons.clock_fill,
                        color: Colors.amber.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Writing Patterns',
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
                  height: 400,
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          dataEntries: List.generate(
                            24,
                            (index) => RadarEntry(
                              value:
                                  (entriesByHour[index]?.toDouble() ?? 0) /
                                  maxValue *
                                  5,
                            ),
                          ),
                          fillColor: Colors.amber.shade300.withOpacity(0.3),
                          borderColor: Colors.amber.shade300,
                          borderWidth: 2,
                        ),
                      ],
                      titleTextStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                      tickCount: 5,
                      ticksTextStyle: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      getTitle: (index, angle) {
                        final hour = index;
                        final period = hour < 12 ? 'AM' : 'PM';
                        final displayHour =
                            hour == 0
                                ? 12
                                : hour > 12
                                ? hour - 12
                                : hour;
                        return RadarChartTitle(
                          text: '$displayHour$period',
                          angle: angle,
                        );
                      },
                      titlePositionPercentageOffset: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your writing activity throughout the day',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  Widget _buildSinCosChart() {
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
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.graph_circle,
                        color: Colors.green.shade300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sin Cos Graph',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SinCosChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generatedNotes = _notes.where((note) => note.isGenerated).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: InstrumentText('Detailed Analysis', fontSize: 32),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: DreamBubbleLoading(
                  title: 'Analyzing your patterns...',
                  subtitle: 'Weaving insights from your journal entries',
                ),
              )
              : generatedNotes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_search,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Generated Entries Yet',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Create a journal entry and let AI generate insights to see your detailed analysis.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create Entry',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatisticsCard(),
                    _buildMoodTrendChart(),
                    _buildMoodPieChart(),
                    _buildTagDistributionChart(),
                    _buildTagCandlestickChart(),
                    _buildWritingPatternsChart(),
                    _buildSinCosChart(),
                  ],
                ),
              ),
    );
  }
}
