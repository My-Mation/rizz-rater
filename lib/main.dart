import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rizz_rater/pages/home_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async calls
  try {
    await dotenv.load(fileName: ".env");  // Load API key
  } catch (e) {
    print("Warning: .env file not found, make sure GEMINI_API_KEY is set!");
  }

  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    print("Error: GEMINI_API_KEY not found. Gemini will not work.");
  } else {
    Gemini.init(apiKey: apiKey);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rizz Rater',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
