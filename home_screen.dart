import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_screen.dart';
import 'mood_journal_screen.dart';
import 'meditation_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    MoodJournalScreen(),
    MeditationScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final currentUser = userBox.get('currentUser') ?? "";
    String profileInitial =
        currentUser.isNotEmpty ? currentUser[0].toUpperCase() : "?";

    return Scaffold(
      appBar: AppBar(
        title: const Text("MindEase"),
        centerTitle: true,
        backgroundColor: const Color(0xFFD2B48C),
        elevation: 2,
        actions: [
          // Profile Icon with Popup
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (currentUser.isEmpty) return; // just safety
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.brown,
                          child: Text(
                            profileInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Logged in as",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentUser,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.brown,
                child: Text(
                  profileInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),

          // Drawer Menu Button
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      // END DRAWER 
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFD2B48C),
              ),
              accountName: Text(
                currentUser,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              accountEmail: const Text(
                "Logged in",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            // Home
            ListTile(
              leading: const Icon(Icons.home, color: Colors.brown),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),

            // About Us
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.brown),
              title: const Text("About Us"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("About MindEase"),
                    content: const Text(
                      "MindEase is your personal mental wellness companion 🌿\n\n"
                      "It helps you track your moods, meditate mindfully, and celebrate progress towards a calmer mind.",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      )
                    ],
                  ),
                );
              },
            ),

            // Contact Us
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Colors.brown),
              title: const Text("Contact Us"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Contact Us"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.email, color: Colors.brown),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text("support@mindeaseapp.com"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.phone, color: Colors.brown),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text("+1 (800) 555-1234"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Spacer(),

            // Logout (only if logged in)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () {
                userBox.delete('currentUser');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // NAV BAR 
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFFA0522D),
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "Mood"),
          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement), label: "Meditation"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Progress"),
        ],
      ),
    );
  }
}
