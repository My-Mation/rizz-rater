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
                'text': '''Analyze the conversation without summarizing message content, focus on engagement of each participant, tone, responsiveness, attentiveness, enthusiasm, balance, dominance, and flow of conversation, detect underlying emotions like happiness, irritation, jealousy, regret, affection, anxiety, subtle humor, sarcasm, or playfulness, identify hidden intentions, interpret figurative language, metaphors, and unspoken meanings, detect frustration, boredom, disinterest, or passive-aggressiveness, evaluate clarity, conciseness, and emotional intelligence, rate social cues, humor compatibility, mutual understanding, empathy, trust, loyalty, support, encouragement, persuasion attempts, expressions of competitiveness or jealousy, and subtle criticism, measure how each participant reacts to disagreements, conflict, agreement, or harmony, detect patterns of avoidance, deflection, or vulnerability, evaluate how balanced conversation is, who leads or follows, analyze attentiveness to context and prior messages, identify repeated phrases and what they indicate about priorities, rate overall engagement level of each participant out of 10, rate tone and emotional contribution out of 10, rate responsiveness and attentiveness out of 10, rate clarity and conciseness out of 10, evaluate mutual feelings and perceptions between participants, provide insights into hidden or unspoken emotions, highlight subtle intentions like regret, jealousy, or affection, predict friendship stability and potential future interactions, suggest actionable improvements for conversational style, timing, responsiveness, and matching the vibe of others, indicate areas where one participant is overcommunicating or undercommunicating, suggest what can be improved to strengthen rapport and emotional connection, focus more on the beginning messages for initial engagement patterns and the last few messages for conclusion and overall dynamic, detect anomalies, hidden subtext, or areas of misalignment, provide detailed feedback about how each participant perceives the other, identify strengths and weaknesses in conversation habits, and give clear recommendations for improving communication, engagement, and friendship quality, all output should be descriptive, analytical, and evaluative without summarizing events, with actionable ratings and insights for each participant.

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
