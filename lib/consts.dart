import 'package:flutter/material.dart';

// Color Scheme Constants
class AppColors {
  // Background / Black
  static const Color background = Color(0xFF121212); // Very dark grey
  static const Color backgroundAlt = Color(0xFF1E1E1E); // Slightly lighter

  // Primary Accent / Blue
  static const Color primaryBlue = Color(0xFF2979FF); // Vivid but not overpowering
  static const Color primaryBlueAlt = Color(0xFF448AFF); // Softer, modern material blue
  static const Color primaryBlueDeep = Color(0xFF1E88E5); // Deep, professional blue

  // Secondary / Grey
  static const Color secondaryGreyLight = Color(0xFFB0BEC5); // Light grey for subtle text
  static const Color secondaryGrey = Color(0xFF90A4AE); // Slightly darker grey for inactive elements
  static const Color secondaryGreyDark = Color(0xFF37474F); // Dark grey for surfaces, cards, or panels

  // Optional Accent / Highlights
  static const Color highlightCyan = Color(0xFF00E5FF); // Neon cyan for small attention areas
  }
  
  // Gemini API Configuration
  class GeminiConfig {
    // Supported models (only these are allowed)
    static const String defaultModel = 'gemini-1.5-pro-latest';
    static const String fallbackModel = 'gemini-1.5-flash-latest';
  
    // API limits
    static const int maxChatLength = 100000; // ~100k characters (well under token limits)
    static const Duration requestTimeout = Duration(seconds: 60);
  
    // Safe fallback messages
    static const String networkErrorMessage = 'Couldn\'t analyze chat right now. Please check your internet or try again later.';
    static const String apiKeyErrorMessage = 'API key configuration error. Please check your .env file.';
    static const String quotaErrorMessage = 'Free quota exhausted or billing not set up. Please enable billing in Google AI Studio.';
    static const String invalidResponseMessage = 'No valid analysis was returned from the model.';
    static const String genericErrorMessage = 'Chat analysis could not be completed. Please try again later.';
  }