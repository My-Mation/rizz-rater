import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rizz_rater/pages/home_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");  // Load API key
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
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
