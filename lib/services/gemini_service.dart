import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../consts.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static String? _apiKey;
  static String _currentModel = GeminiConfig.defaultModel;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Initialize the service with API key
  /// In development: loads from .env file
  /// In production: loads from secure storage
  static Future<void> initialize() async {
    try {
      if (kReleaseMode) {
        // Production: Load from secure storage
        _apiKey = await _secureStorage.read(key: 'GEMINI_API_KEY');
        if (_apiKey == null || _apiKey!.isEmpty) {
          // If not in secure storage, try .env as fallback (for first run)
          await dotenv.load();
          _apiKey = dotenv.env['GEMINI_API_KEY'];
          if (_apiKey != null && _apiKey!.isNotEmpty) {
            // Store in secure storage for future use
            await _secureStorage.write(key: 'GEMINI_API_KEY', value: _apiKey);
          }
        }
      } else {
        // Development: Load from .env file
        _apiKey = dotenv.env['GEMINI_API_KEY'];
      }

      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception(GeminiConfig.apiKeyErrorMessage);
      }
    } catch (e) {
      if (e.toString().contains('NotInitializedError')) {
        throw Exception(GeminiConfig.apiKeyErrorMessage);
      }
      rethrow;
    }
  }

  /// Set the model to use (only supported models allowed)
  static void setModel(String model) {
    if (model == GeminiConfig.defaultModel ||
        model == GeminiConfig.fallbackModel) {
      _currentModel = model;
    } else {
      throw Exception(
        'Unsupported model: $model. Only ${GeminiConfig.defaultModel} and ${GeminiConfig.fallbackModel} are supported.',
      );
    }
  }

  /// Get current model
  static String get currentModel => _currentModel;

  /// Rate a WhatsApp chat using Gemini API
  ///
  /// [chatText] - The parsed chat messages as a single string
  /// Returns a detailed rating of the chat focusing on tone, clarity, friendliness, and engagement
  static Future<String> rateChat(String chatText) async {
    // Input validation
    if (chatText.trim().isEmpty) {
      throw Exception('Chat text cannot be empty');
    }

    // Truncate if too long
    String processedText = chatText.length > GeminiConfig.maxChatLength
        ? '${chatText.substring(0, GeminiConfig.maxChatLength)}...[truncated]'
        : chatText;

    // Initialize if needed
    if (_apiKey == null) {
      await initialize();
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception(GeminiConfig.apiKeyErrorMessage);
    }

    // Try primary model first, then fallback
    final modelsToTry = [_currentModel, GeminiConfig.fallbackModel];

    for (final modelName in modelsToTry) {
      try {
        final result = await _makeApiCall(modelName, processedText);
        return result;
      } catch (e) {
        // Log error safely (without sensitive data)
        _safeLog('Model $modelName failed: ${e.toString()}');

        // Continue to next model if this one fails
        if (modelName == modelsToTry.last) {
          // If all models failed, provide safe fallback
          return GeminiConfig.genericErrorMessage;
        }
        continue;
      }
    }

    // This should never be reached, but just in case
    return GeminiConfig.genericErrorMessage;
  }

  /// Make the actual API call with comprehensive error handling
  static Future<String> _makeApiCall(String modelName, String chatText) async {
    final url = Uri.parse(
      '$_baseUrl/models/$modelName:generateContent?key=$_apiKey',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  '''Analyze the conversation without summarizing message content, focus on engagement of each participant, tone, responsiveness, attentiveness, enthusiasm, balance, dominance, and flow of conversation, detect underlying emotions like happiness, irritation, jealousy, regret, affection, anxiety, subtle humor, sarcasm, or playfulness, identify hidden intentions, interpret figurative language, metaphors, and unspoken meanings, detect frustration, boredom, disinterest, or passive-aggressiveness, evaluate clarity, conciseness, and emotional intelligence, rate social cues, humor compatibility, mutual understanding, empathy, trust, loyalty, support, encouragement, persuasion attempts, expressions of competitiveness or jealousy, and subtle criticism, measure how each participant reacts to disagreements, conflict, agreement, or harmony, detect patterns of avoidance, deflection, or vulnerability, evaluate how balanced conversation is, who leads or follows, analyze attentiveness to context and prior messages, identify repeated phrases and what they indicate about priorities, rate overall engagement level of each participant out of 10, rate tone and emotional contribution out of 10, rate responsiveness and attentiveness out of 10, rate clarity and conciseness out of 10, evaluate mutual feelings and perceptions between participants, provide insights into hidden or unspoken emotions, highlight subtle intentions like regret, jealousy, or affection, predict friendship stability and potential future interactions, suggest actionable improvements for conversational style, timing, responsiveness, and matching the vibe of others, indicate areas where one participant is overcommunicating or undercommunicating, suggest what can be improved to strengthen rapport and emotional connection, focus more on the beginning messages for initial engagement patterns and the last few messages for conclusion and overall dynamic, detect anomalies, hidden subtext, or areas of misalignment, provide detailed feedback about how each participant perceives the other, identify strengths and weaknesses in conversation habits, and give clear recommendations for improving communication, engagement, and friendship quality, all output should be descriptive, analytical, and evaluative without summarizing events, with actionable ratings and insights for each participant.

Chat content:
$chatText''',
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(GeminiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return _parseSuccessfulResponse(response.body);
      } else {
        throw Exception(_handleApiError(response));
      }
    } on TimeoutException {
      _safeLog('Request timeout for model $modelName');
      throw Exception(GeminiConfig.networkErrorMessage);
    } on http.ClientException {
      _safeLog('Network error for model $modelName');
      throw Exception(GeminiConfig.networkErrorMessage);
    } on FormatException {
      _safeLog('Invalid JSON response from model $modelName');
      throw Exception(GeminiConfig.invalidResponseMessage);
    } catch (e) {
      _safeLog('Unexpected error with model $modelName: ${e.toString()}');
      throw Exception(GeminiConfig.genericErrorMessage);
    }
  }

  /// Parse successful API response safely
  static String _parseSuccessfulResponse(String responseBody) {
    try {
      final responseData = jsonDecode(responseBody);

      if (responseData['candidates'] != null &&
          responseData['candidates'].isNotEmpty &&
          responseData['candidates'][0]['content'] != null &&
          responseData['candidates'][0]['content']['parts'] != null &&
          responseData['candidates'][0]['content']['parts'].isNotEmpty) {
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        if (text != null && text.toString().trim().isNotEmpty) {
          return text.toString();
        }
      }

      throw Exception('Invalid response structure');
    } catch (e) {
      _safeLog('Failed to parse response: ${e.toString()}');
      throw Exception(GeminiConfig.invalidResponseMessage);
    }
  }

  /// Handle API errors with specific messages
  static String _handleApiError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData['error']?['message'] ?? 'Unknown API error';

      // Log the actual error for debugging
      _safeLog('API Error (${response.statusCode}): $errorMessage');

      // Handle specific error codes
      if (response.statusCode == 403 || response.statusCode == 429) {
        return GeminiConfig.quotaErrorMessage;
      } else if (response.statusCode == 401 ||
          errorMessage.contains('API key')) {
        return GeminiConfig.apiKeyErrorMessage;
      } else if (response.statusCode >= 500) {
        return GeminiConfig.networkErrorMessage;
      } else {
        // For other errors, return the specific message from the API
        return 'Chat analysis failed: $errorMessage';
      }
    } catch (e) {
      _safeLog('Failed to parse error response: ${e.toString()}');
      return GeminiConfig.genericErrorMessage;
    }
  }

  /// Safe logging that doesn't expose sensitive information
  static void _safeLog(String message) {
    // Only log in debug mode and never include API keys or chat content
    assert(() {
      print('GeminiService: $message');
      return true;
    }());
  }

  /// Check if the service is properly initialized
  static bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;
}
