import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  String selectedMood = "";
  final TextEditingController journalController = TextEditingController();
  String? motivationMessage;

  List<Map<String, String>> userEntries = [];

  final Map<String, String> motivationMessages = {
    "Happy": "Keep shining — your positivity is contagious! 🌞",
    "Sad": "It’s okay to feel sad. Every storm passes and the sun shines again 💛",
    "Angry": "Take a deep breath — peace begins with you 🕊",
    "Lost": "Even when you feel lost, you’re still on your way 🌿",
  };

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadEntries() {
    final userBox = Hive.box('userBox');
    final journalBox = Hive.box('journalBox');
    final currentUser = userBox.get('currentUser');

    if (currentUser != null && journalBox.containsKey(currentUser)) {
      final storedEntries = journalBox.get(currentUser);
      userEntries = List<Map<String, String>>.from(
        (storedEntries as List).map((e) => {
          'mood': e['mood'].toString(),
          'text': e['text'].toString(),
          'date': e['date'].toString(),
        }),
      );
      setState(() {});
    }
  }

  Widget moodEmoji(String emoji, String label) {
    bool isSelected = selectedMood == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = label;
          // Save current mood to Hive
          Hive.box('journalBox').put('currentMood', label);
        });
      },
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 36,
              color: isSelected ? const Color(0xFFA0522D) : Colors.black54,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFA0522D) : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void saveJournal() {
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a mood before saving")));
      return;
    }

    if (journalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Write something before saving")));
      return;
    }

    final userBox = Hive.box('userBox');
    final journalBox = Hive.box('journalBox');
    final currentUser = userBox.get('currentUser');

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error: No logged-in user found. Please log in again.")));
      return;
    }

    final newEntry = {
      'mood': selectedMood,
      'text': journalController.text,
      'date': DateTime.now().toString().substring(0, 16),
    };

    List existingEntries = journalBox.get(currentUser, defaultValue: []);
    existingEntries.add(newEntry);
    journalBox.put(currentUser, existingEntries);

    setState(() {
      userEntries.add(Map<String, String>.from(newEntry));
      motivationMessage = motivationMessages[selectedMood];
      selectedMood = "";
      journalController.clear();
    });

    Timer(const Duration(seconds: 4), () {
      setState(() {
        motivationMessage = null;
      });
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Journal entry saved!")));
  }

  void viewEntries() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalHistory(entries: userEntries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "How are you feeling today?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              moodEmoji("😄", "Happy"),
              moodEmoji("😢", "Sad"),
              moodEmoji("😠", "Angry"),
              moodEmoji("🥺", "Lost"),
            ],
          ),
          const SizedBox(height: 30),

          if (motivationMessage != null)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Card(
                color: const Color(0xFFF5DEB3),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Color(0xFFA0522D), size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          motivationMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFA0522D),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
          const Text(
            "Write about your day:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: journalController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Express your thoughts here...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveJournal,
            child: const Text("Save Entry"),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: viewEntries,
            child: const Text(
              "View Past Entries",
              style: TextStyle(color: Color(0xFFA0522D)),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- JOURNAL HISTORY --------------------
class JournalHistory extends StatefulWidget {
  final List<Map<String, String>> entries;

  const JournalHistory({super.key, required this.entries});

  @override
  State<JournalHistory> createState() => _JournalHistoryState();
}

class _JournalHistoryState extends State<JournalHistory> {
  void deleteEntry(int index) {
    final userBox = Hive.box('userBox');
    final journalBox = Hive.box('journalBox');
    final currentUser = userBox.get('currentUser');

    if (currentUser != null) {
      List existingEntries = List.from(journalBox.get(currentUser, defaultValue: []));
      existingEntries.removeAt(index);
      journalBox.put(currentUser, existingEntries);

      setState(() {
        widget.entries.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entry deleted successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Journal Entries"),
        backgroundColor: const Color(0xFFD2B48C),
      ),
      body: widget.entries.isEmpty
          ? const Center(
              child: Text(
                "No entries yet.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.entries.length,
              itemBuilder: (context, index) {
                final entry = widget.entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      "${entry['mood']} — ${entry['date']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(entry['text'] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Entry"),
                            content: const Text(
                                "Are you sure you want to delete this entry?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.redAccent)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteEntry(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
