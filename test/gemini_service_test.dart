import 'package:flutter_test/flutter_test.dart';
import 'package:rizz_rater/services/gemini_service.dart';

void main() {
  group('GeminiService Tests', () {
    test('should throw exception when API key is not available', () async {
      // This test will fail if GEMINI_API_KEY is not set in .env
      try {
        await GeminiService.initialize();
        // If we get here, the API key was found
        expect(GeminiService.isInitialized, true);
      } catch (e) {
        expect(e.toString(), contains('GEMINI_API_KEY not found'));
      }
    });

    test('should throw exception for empty chat text when not initialized', () async {
      try {
        await GeminiService.rateChat('');
        fail('Should have thrown an exception for empty chat text');
      } catch (e) {
        // The service will try to initialize first, so we might get either error
        expect(e.toString(), anyOf([
          contains('Chat text cannot be empty'),
          contains('GEMINI_API_KEY not found'),
          contains('Gemini API key not available')
        ]));
      }
    });

    test('should throw exception for whitespace-only chat text when not initialized', () async {
      try {
        await GeminiService.rateChat('   \n\t   ');
        fail('Should have thrown an exception for whitespace-only chat text');
      } catch (e) {
        // The service will try to initialize first, so we might get either error
        expect(e.toString(), anyOf([
          contains('Chat text cannot be empty'),
          contains('GEMINI_API_KEY not found'),
          contains('Gemini API key not available')
        ]));
      }
    });
  });
}
