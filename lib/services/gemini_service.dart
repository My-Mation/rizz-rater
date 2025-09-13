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
                'text': '''You are given the extracted contents of a WhatsApp chat. 
The format is:
[Name]: [Message]

Ignore any dates, times, media placeholders, or system messages. 
Focus only on the actual conversation between people.

Your task:
1. Rate the overall tone of the chat (positive, neutral, negative, mixed).
2. Analyze clarity and readability of the messages.
3. Evaluate friendliness and emotional warmth.
4. Assess engagement level (are both sides equally active, or one dominates?).
5. Provide a final detailed rating (0–10) with reasoning.

Give a short structured report with sections:
- Tone
- Clarity
- Friendliness
- Engagement
- Final Rating with explanation

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
          'maxOutputTokens': 1024,
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
