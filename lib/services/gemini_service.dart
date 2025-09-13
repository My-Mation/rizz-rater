import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static String? _apiKey;

  /// Initialize the service with API key from .env file
  static Future<void> initialize() async {
    try {
      _apiKey = dotenv.env['GEMINI_API_KEY'];
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }
    } catch (e) {
      if (e.toString().contains('NotInitializedError')) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }
      rethrow;
    }
  }

  /// Rate a WhatsApp chat using Gemini API
  /// 
  /// [chatText] - The parsed chat messages as a single string
  /// Returns a detailed rating of the chat focusing on tone, clarity, friendliness, and engagement
  static Future<String> rateChat(String chatText) async {
    if (_apiKey == null) {
      await initialize();
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Gemini API key not available');
    }

    if (chatText.trim().isEmpty) {
      throw Exception('Chat text cannot be empty');
    }

    try {
      final url = Uri.parse('$_baseUrl/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey');
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': '''You are a social intelligence and friendship analyst. Read the chat conversation provided and give a very detailed, human-readable analysis from start to finish. Focus on the quality of interaction, not grammar or spelling. Analyze the conversation thoroughly for engagement, emotional tone, hidden meanings, mutual bond, and relationship dynamics. For each message or group of messages, describe how actively each participant engages, who drives the conversation, who responds thoughtfully, who is passive, and provide examples from the chat. Evaluate the strength of the friendship, noting trust, support, care, teasing, comfort, and closeness. Identify emotions expressed or implied in each message, including subtle ones like hidden regret, jealousy, encouragement, hidden concern, excitement, or frustration. Detect subtext, double meanings, or indirect messages. Note behavior patterns, such as who frequently initiates conversation, who encourages the other, who jokes or teases, and any changes over time. Highlight specific messages that stand out and explain why they are significant in understanding the relationship or engagement quality. Summarize the overall dynamics, strengths, weaknesses, and key insights about the friendship. Mention participants by name when possible. Cover everything in detail from beginning to end. Provide a continuous, thorough narrative. Nothing is too small to include. Analyze phrasing, timing, tone, and responses to reveal the true nature of the relationship. Consider context, implied intentions, and consistency of behavior. Give examples to support each point. Focus on engagement, emotional depth, hidden meanings, relational closeness, and overall quality of communication.

Chat content:
$chatText'''
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          
          return responseData['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Invalid response format from Gemini API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('Gemini API error (${response.statusCode}): $errorMessage');
      }
    } on http.ClientException {
      throw Exception('Network error: Unable to connect to Gemini API');
    } on FormatException {
      throw Exception('Invalid response format from Gemini API');
    } catch (e) {
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// Check if the service is properly initialized
  static bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;
}
