import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isBreathing = false;
  String breathInstruction = "Press Start to Begin 🌬";
  String userMood = "Neutral"; // Default mood

  final List<String> meditationSteps = [
    "Find a quiet space 🌿",
    "Sit comfortably 🧘",
    "Close your eyes 👁‍🗨",
    "Inhale deeply for 4 sec 🌬",
    "Hold for 4 sec 🤍",
    "Exhale slowly for 4 sec 💨",
    "Relax your shoulders 💆‍♀",
    "Focus on your breath 🫁",
    "Let go of all thoughts ☁",
    "Smile softly to yourself 😊",
  ];

  final Map<String, String> moodVideos = {
    "Happy": "https://youtu.be/m4Ics03xzUQ?si=twnr3nwE2MefMfU_",
    "Sad": "https://youtu.be/ZebSXPUCPFc?si=qv9iDNiFi2nGyRcD",
    "Angry": "https://youtu.be/Yh1-y3TzSO4?si=hXjA8nh1vYWkamz1",
    "Lost": "https://youtu.be/_G7ERJA1mRI?si=URQdEbr6vmagSuBe",
  };

  final List<Map<String, String>> videos = [
    {
      "title": "10-Minute Guided Meditation",
      "url": "https://youtu.be/O-6f5wQXSu8?si=lByZC0isnPX4e9jV"
    },
    {
      "title": "Deep Breathing for Stress Relief",
      "url": "https://youtu.be/odADwWzHR24?si=urUp2WazUBF6Ym7C"
    },
    {
      "title": "Sleep Meditation for Relaxation",
      "url": "https://youtu.be/aEqlQvczMJQ?si=NSge_PT6HpNGe_NH"
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _loadUserMood();
  }

  void _loadUserMood() {
    Box journalBox = Hive.box('journalBox');
    setState(() {
      userMood = journalBox.get('currentMood', defaultValue: "Neutral");
    });
  }

  void startBreathing() {
    if (isBreathing) return;

    setState(() {
      isBreathing = true;
      breathInstruction = "Breathe In... 🌬";
    });

    _controller.repeat(reverse: true);

    int phase = 0;

    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!isBreathing) {
        timer.cancel();
        return;
      }

      setState(() {
        if (phase == 0) {
          breathInstruction = "Hold... 🤍";
        } else if (phase == 1) {
          breathInstruction = "Breathe Out... 💨";
        } else {
          breathInstruction = "Breathe In... 🌬";
        }
      });

      phase = (phase + 1) % 3;
    });

    Timer(const Duration(seconds: 60), () {
      setState(() {
        isBreathing = false;
        breathInstruction = "Session Complete ✅";
      });
      _controller.stop();
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? suggestedVideo = moodVideos[userMood];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "🧘 Guided Meditation Steps",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA0522D),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: meditationSteps
                .map(
                  (step) => Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5DEB3),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        step,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFA0522D),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 40),
          const Text(
            "🌬 Breathing Exercise",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA0522D),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _controller.value,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD2B48C), Color(0xFFF5F5DC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            breathInstruction,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA0522D),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: startBreathing,
            child: Text(isBreathing ? "Just Breathe..." : "Start Breathing"),
          ),
          const SizedBox(height: 40),
          const Text(
            "🎧 Relaxation Videos",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA0522D),
            ),
          ),
          const SizedBox(height: 16),
          if (suggestedVideo != null)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              color: const Color(0xFFF5DEB3),
              child: ListTile(
                leading: const Icon(Icons.lightbulb,
                    color: Color(0xFFA0522D), size: 30),
                title: Text(
                  "Recommended for your mood ($userMood)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA0522D),
                  ),
                ),
                subtitle: const Text("Tap to open YouTube meditation video"),
                trailing: const Icon(Icons.play_circle_fill,
                    color: Color(0xFFA0522D)),
                onTap: () => _launchURL(suggestedVideo),
              ),
            )
          else
            const Text("Select a mood in the Mood Journal to get a video 💡"),
          const SizedBox(height: 20),
          ...videos.map(
            (v) => Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.play_circle_fill,
                    color: Color(0xFFA0522D), size: 30),
                title: Text(
                  v["title"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA0522D),
                  ),
                ),
                trailing: const Icon(Icons.open_in_new, color: Colors.brown),
                onTap: () => _launchURL(v["url"]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
