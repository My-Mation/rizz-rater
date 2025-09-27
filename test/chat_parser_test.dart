import 'package:flutter_test/flutter_test.dart';
import 'package:rizz_rater/utils/chat_parser.dart';

void main() {
  group('WhatsApp Chat Parser Tests', () {
    test('should parse single-line messages correctly', () {
      const input = '''05/09/2025, 14:32 - Alice: Hello world!
05/09/2025, 14:33 - Bob: Hi there!''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 2);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'Hello world!');
      expect(result[1].name, 'Bob');
      expect(result[1].text, 'Hi there!');
    });

    test('should parse multi-line messages correctly', () {
      const input = '''05/09/2025, 14:32 - Alice: This is a multi-line message
that continues on the next line
and even has a third line!
05/09/2025, 14:33 - Bob: Single line response''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 2);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'This is a multi-line message\nthat continues on the next line\nand even has a third line!');
      expect(result[1].name, 'Bob');
      expect(result[1].text, 'Single line response');
    });

    test('should ignore system messages', () {
      const input = '''Messages and calls are end-to-end encrypted
05/09/2025, 14:32 - Alice: Real message
05/09/2025, 14:33 - Bob: <Media omitted>
05/09/2025, 14:34 - Alice: Another real message''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 2);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'Real message');
      expect(result[1].name, 'Alice');
      expect(result[1].text, 'Another real message');
    });

    test('should handle different timestamp formats', () {
      const input = '''05/09/2025, 14:32 - Alice: 24h format
5/9/25, 2:32 PM - Bob: 12h format
05-09-2025, 14:32 - Charlie: Dash separator
5/9/2025, 2:32 PM - David: Mixed format''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 4);
      expect(result[0].name, 'Alice');
      expect(result[0].text, '24h format');
      expect(result[1].name, 'Bob');
      expect(result[1].text, '12h format');
      expect(result[2].name, 'Charlie');
      expect(result[2].text, 'Dash separator');
      expect(result[3].name, 'David');
      expect(result[3].text, 'Mixed format');
    });

    test('should handle empty input', () {
      const input = '';

      final result = parseWhatsAppExport(input);

      expect(result.length, 0);
    });

    test('should handle input with only system messages', () {
      const input = '''Messages and calls are end-to-end encrypted
<Media omitted>
You created group "Test Group"''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 0);
    });

    test('should handle malformed lines gracefully', () {
      const input = '''This is not a proper message line
05/09/2025, 14:32 - Alice: Valid message
Another malformed line
05/09/2025, 14:33 - Bob: Another valid message''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 2);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'Valid message');
      expect(result[1].name, 'Bob');
      expect(result[1].text, 'Another valid message');
    });

    test('should handle messages with colons in content', () {
      const input = '''05/09/2025, 14:32 - Alice: This message has : colons in it
05/09/2025, 14:33 - Bob: Time is 14:33:45''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 2);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'This message has : colons in it');
      expect(result[1].name, 'Bob');
      expect(result[1].text, 'Time is 14:33:45');
    });

    test('should handle empty lines between messages', () {
      const input = '''05/09/2025, 14:32 - Alice: First message

05/09/2025, 14:33 - Bob: Second message

05/09/2025, 14:34 - Alice: Third message''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 3);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'First message');
      expect(result[1].name, 'Bob');
      expect(result[1].text, 'Second message');
      expect(result[2].name, 'Alice');
      expect(result[2].text, 'Third message');
    });

    test('should handle various system message patterns', () {
      const input = '''05/09/2025, 14:32 - Alice: Real message
05/09/2025, 14:33 - System: You created group "Test"
05/09/2025, 14:34 - System: John joined
05/09/2025, 14:35 - System: Mary left
05/09/2025, 14:36 - System: <Media omitted>
05/09/2025, 14:37 - System: changed the subject to "New Subject"
05/09/2025, 14:38 - Alice: Another real message''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 4); // System messages with "System:" as sender are not filtered by name
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'Real message');
      expect(result[1].name, 'System');
      expect(result[1].text, 'John joined');
      expect(result[2].name, 'System');
      expect(result[2].text, 'Mary left');
      expect(result[3].name, 'Alice');
      expect(result[3].text, 'Another real message');
    });

    test('should handle Windows and Unix line endings', () {
      const input = '05/09/2025, 14:32 - Alice: Windows line ending\r\n05/09/2025, 14:33 - Bob: Unix line ending\n05/09/2025, 14:34 - Charlie: Mixed line endings\r\n';

      final result = parseWhatsAppExport(input);

      expect(result.length, 3);
      expect(result[0].name, 'Alice');
      expect(result[0].text, 'Windows line ending');
      expect(result[1].name, 'Bob');
      expect(result[1].text, 'Unix line ending');
      expect(result[2].name, 'Charlie');
      expect(result[2].text, 'Mixed line endings');
    });

    test('should preserve names exactly as they appear', () {
      const input = '''05/09/2025, 14:32 - Alice Smith: Full name
05/09/2025, 14:33 - Bob: Short name
05/09/2025, 14:34 - Charlie123: Name with numbers
05/09/2025, 14:35 - David O'Connor: Name with apostrophe''';

      final result = parseWhatsAppExport(input);

      expect(result.length, 4);
      expect(result[0].name, 'Alice Smith');
      expect(result[1].name, 'Bob');
      expect(result[2].name, 'Charlie123');
      expect(result[3].name, 'David O\'Connor');
    });
  });
}
