import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _setSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seenTutorial", true);
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      controlsMargin: const EdgeInsets.only(bottom: 15.0),
      pages: [
        PageViewModel(
          title: "Upload Chats",
          body: "Pick your WhatsApp chat and click on the : at top right.",
          image: const Icon(Icons.upload_file, size: 100, color: Colors.blue),
        ),
        PageViewModel(
          title: "Upload Chats",
          body: "Click 'More' (three dots) and select 'Export chat'.",
          image: const Icon(Icons.upload_file, size: 100, color: Colors.pink),
        ),
        PageViewModel(
          title: "Upload Chats",
          body: "Click export without media and upload the zip file here.",
          image: const Icon(Icons.upload_file, size: 100, color: Colors.grey),
        ),
        PageViewModel(
          title: "AI Analysis",
          body: "Let the AI read and rate your chat quality.",
          image: const Icon(Icons.psychology, size: 100, color: Colors.green),
        ),
        PageViewModel(
          title: "Stay Private",
          body: "Your chat data is processed locally, never uploaded.",
          image: const Icon(Icons.lock, size: 100, color: Colors.orange),
        ),
      ],
      onDone: () async {
        await _setSeenTutorial();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      },
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Start", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
