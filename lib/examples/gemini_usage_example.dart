import '../services/gemini_service.dart';

/// Example usage of the GeminiService
/// 
/// This file demonstrates how to use the GeminiService to rate WhatsApp chats.
/// Make sure to create a .env file with your GEMINI_API_KEY before using this service.
class GeminiUsageExample {
  
  /// Example of rating a simple chat
  static Future<void> rateSimpleChat() async {
    try {
      const chatText = '''
Alice: Hey! How are you doing today?
Bob: I'm doing great, thanks for asking! How about you?
Alice: I'm good too, just working on some projects
Bob: That sounds interesting! What kind of projects?
Alice: Just some coding stuff, nothing too exciting
Bob: Coding is always exciting! What language are you using?
''';

      final rating = await GeminiService.rateChat(chatText);
      print('Chat Rating:');
      print(rating);
    } catch (e) {
      print('Error rating chat: $e');
    }
  }

  /// Example of rating a more complex chat with multiple participants
  static Future<void> rateGroupChat() async {
    try {
      const chatText = '''
Alice: Good morning everyone! 
Bob: Morning Alice! 
Charlie: Hey there! How's everyone doing?
Alice: I'm great! Just finished my morning coffee
Bob: Same here! Ready to tackle the day
Charlie: I'm still waking up 😴
Alice: Haha, take your time Charlie!
Bob: Yeah, no rush! We all have different schedules
Charlie: Thanks guys! You're the best team ever! 🎉
''';

      final rating = await GeminiService.rateChat(chatText);
      print('Group Chat Rating:');
      print(rating);
    } catch (e) {
      print('Error rating group chat: $e');
    }
  }

  /// Example of rating a chat with potential issues
  static Future<void> rateProblematicChat() async {
    try {
      const chatText = '''
Alice: Why didn't you respond to my message?
Bob: I was busy
Alice: That's not a good excuse
Bob: Whatever
Alice: You're being rude
Bob: I don't care
''';

      final rating = await GeminiService.rateChat(chatText);
      print('Problematic Chat Rating:');
      print(rating);
    } catch (e) {
      print('Error rating problematic chat: $e');
    }
  }
}
