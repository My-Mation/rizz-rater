import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rizz_rater/pages/home_page.dart';
import 'package:rizz_rater/pages/onboarding_page.dart';
import 'package:rizz_rater/services/gemini_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    await GeminiService.initialize();
    print("Gemini service initialized successfully");
  } catch (e) {
    print("Warning: Failed to initialize Gemini service: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final seenTutorial = prefs.getBool("seenTutorial") ?? false;

  runApp(MyApp(seenTutorial: seenTutorial));
}

class MyApp extends StatelessWidget {
  final bool seenTutorial;
  const MyApp({super.key, required this.seenTutorial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Chat Reader',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2979FF),
          secondary: Color(0xFF90A4AE),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: AnimatedSplashScreen(
        splash: Image.asset('assets/Splash_screen.gif'),
        nextScreen: seenTutorial ? const HomePage() : const OnboardingPage(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: const Color(0xFF0D1117),
        duration: 3000,
        animationDuration: const Duration(milliseconds: 1000),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
