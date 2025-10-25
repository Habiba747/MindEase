import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:confetti/confetti.dart';


class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<String> _quotes = [
    "✨ You are doing better than you think.",
    "🌿 Take a deep breath — you are enough.",
    "💫 One small positive thought can change your whole day.",
    "🌸 Be gentle with yourself, you’re growing.",
    "☁ Every day may not be good, but there’s something good in every day.",
    "🌼 Let your light shine, even on cloudy days.",
    "💖 Progress, not perfection.",
    "🌞 You are stronger than you feel right now.",
  ];

  late String _currentQuote;
  late ConfettiController _confettiController;

  int streakDays = 0;
  Map<String, int> moodCounts = {
    "Happy": 0,
    "Lost": 0,
    "Sad": 0,
    "Angry": 0,
  };

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _loadMotivationQuote(); // load today's quote
    _loadProgressFromHive();
  }

  /// ✅ Loads today's motivation quote from Hive or generates a new one once per day
  Future<void> _loadMotivationQuote() async {
    final box = Hive.box('userBox');
    final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd

    final savedDate = box.get('motivationDate');
    final savedQuote = box.get('motivationQuote');

    if (savedDate == today && savedQuote != null) {
      // Same day → use stored quote
      setState(() {
        _currentQuote = savedQuote;
      });
    } else {
      // New day → pick a new random quote and store it
      final newQuote = _quotes[Random().nextInt(_quotes.length)];
      await box.put('motivationQuote', newQuote);
      await box.put('motivationDate', today);
      setState(() {
        _currentQuote = newQuote;
      });
    }
  }

  Future<void> _loadProgressFromHive() async {
    try {
      final userBox = Hive.box('userBox');
      final journalBox = Hive.box('journalBox');
      final currentUser = userBox.get('currentUser');

      if (currentUser == null) {
        setState(() {
          streakDays = 0;
          moodCounts = {
            "Happy": 0,
            "Lost": 0,
            "Sad": 0,
            "Angry": 0,
          };
        });
        return;
      }

      final List stored =
          journalBox.get(currentUser, defaultValue: <dynamic>[]) as List;

      Map<String, int> counts = {
        "Happy": 0,
        "Lost": 0,
        "Sad": 0,
        "Angry": 0,
      };

      int streak = 0;
      final now = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final d = now.subtract(Duration(days: i));
        final dayKey =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        final entry = stored.firstWhere(
          (e) {
            final raw = e['date']?.toString() ?? '';
            final dt = DateTime.tryParse(raw);
            if (dt == null) return false;
            final key =
                "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
            return key == dayKey;
          },
          orElse: () => null,
        );

        if (entry != null) {
          streak++;
          if (i < 7) {
            String mood = entry['mood'] ?? "Neutral";
            counts[mood] = (counts[mood] ?? 0) + 1;
          }
        } else if (i >= 7) {
          break;
        }
      }

      setState(() {
        streakDays = streak;
        moodCounts = counts;
      });

      if (streakDays % 7 == 0 && streakDays != 0) {
        _confettiController.play();
      }
    } catch (err) {
      print("Error loading progress: $err");
      setState(() {
        streakDays = 0;
        moodCounts = {
          "Happy": 0,
          "Lost": 0,
          "Sad": 0,
          "Angry": 0,
        };
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildBadge(String label, bool achieved) {
    return Chip(
      backgroundColor:
          achieved ? const Color(0xFFF5DEB3) : Colors.grey.shade300,
      label: Text(
        label,
        style: TextStyle(
          color: achieved ? const Color(0xFF5A3B3B) : Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pieSections = <PieChartSectionData>[];
    final colors = {
      "Happy": Colors.yellow,
      "Lost": Colors.blueGrey,
      "Sad": Colors.blue,
      "Angry": Colors.red,
    };

    moodCounts.forEach((mood, count) {
      if (count > 0) {
        pieSections.add(
          PieChartSectionData(
            value: count.toDouble(),
            color: colors[mood],
            title: "$mood\n$count",
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Color(0xFFA0522D),
                Color(0xFFF5DEB3),
                Colors.white
              ],
              numberOfParticles: 25,
            ),
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "✨ Today's Motivation ✨",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3B3B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Text(
                      _currentQuote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF5A3B3B),
                          height: 1.3),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    "Mood Overview 🌤",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A3B3B)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  // Streak Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("🔥 Your Streak",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5A3B3B))),
                        const SizedBox(height: 8),
                        Text(
                          "$streakDays ${streakDays == 1 ? 'day' : 'days'}",
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA0522D)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          streakDays == 0
                              ? "Start journaling to build your streak 🌱"
                              : "Nice! Keep the streak going ✨",
                          style: const TextStyle(color: Color(0xFF6D4C41)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  // Achievements
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.brown.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("🏆 Achievements",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5A3B3B))),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildBadge("🌱 Beginner", streakDays >= 1),
                            _buildBadge("🔥 3-Day Streak", streakDays >= 3),
                            _buildBadge("🌈 7-Day Hero", streakDays >= 7),
                            _buildBadge(
                                "☀ Consistent Logger",
                                moodCounts.values.fold<int>(
                                        0, (a, b) => a + b) >=
                                    6),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}