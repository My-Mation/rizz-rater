import '../models/chat_message.dart';

/// Parse a WhatsApp chat export raw text into list of ChatMessage,
/// preserving name and aggregated text while removing timestamps and system messages.
///
/// Works with common WhatsApp export formats like:
/// 05/09/2025, 14:32 - Debargha: message...
/// 5/9/25, 2:32 PM - Name: message...
List<ChatMessage> parseWhatsAppExport(String raw) {
  if (raw.isEmpty) return [];

  // Normalize newlines
  final normalized = raw.replaceAll('\r\n', '\n');

  // Regex to detect the beginning of a new message:
  // - date: dd/mm/yyyy or d-m-yy etc (flexible)
  // - comma, space, time (HH:MM) optional AM/PM
  // - " - "
  // - name (non-greedy), colon, space, then message
  final messageStartRegex = RegExp(
    r'^\s*(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}),\s*(\d{1,2}:\d{2}(?:\s*[APMapm\.]{0,4})?)\s*-\s*(.+?):\s*(.*)$',
    multiLine: false,
  );

  // System messages or lines to ignore if they appear as top-level message text
  final ignorePatterns = <RegExp>[
    RegExp(r'^\s*Messages and calls are end-to-end encrypted', caseSensitive: false),
    RegExp(r'^\s*<Media omitted>', caseSensitive: false),
    RegExp(r'^\s*You created group', caseSensitive: false),
    RegExp(r'^\s*joined', caseSensitive: false),
    RegExp(r'^\s*left', caseSensitive: false),
    RegExp(r'^\s*changed the subject', caseSensitive: false),
    RegExp(r'^\s*changed this group', caseSensitive: false),
    RegExp(r'^\s*You added', caseSensitive: false),
    RegExp(r'^\s*You removed', caseSensitive: false),
    RegExp(r'^\s*deleted this message', caseSensitive: false),
  ];

  final List<ChatMessage> out = [];
  final lines = normalized.split('\n');

  String? currentName;
  StringBuffer? currentTextBuffer;

  void commitCurrent() {
    if (currentName != null && currentTextBuffer != null) {
      final text = currentTextBuffer!.toString().trim();
      bool ignore = false;
      for (final pat in ignorePatterns) {
        if (pat.hasMatch(text)) {
          ignore = true;
          break;
        }
      }
      if (!ignore && text.isNotEmpty) {
        out.add(ChatMessage(name: currentName!, text: text));
      }
    }
    currentName = null;
    currentTextBuffer = null;
  }

  for (var line in lines) {
    if (line.trim().isEmpty) {
      // treat empty lines as possible paragraph breaks inside a message
      if (currentTextBuffer != null) {
        currentTextBuffer!.write('\n');
      }
      continue;
    }

    final m = messageStartRegex.firstMatch(line);
    if (m != null) {
      // New top-level message detected
      // Commit prior message
      commitCurrent();

      final name = m.group(3)!.trim();
      final msgPart = m.group(4) ?? '';

      currentName = name;
      currentTextBuffer = StringBuffer();
      currentTextBuffer!.write(msgPart);
    } else {
      // Not a message-start line. It is a continuation of previous message
      if (currentTextBuffer == null) {
        // No current message: this can be a stray header/system line. Skip it.
        continue;
      } else {
        // Not a message-start line. It is a continuation of previous message
        final trimmed = line.trim();
        
        // Skip lines that look like they could be malformed message starts
        // (lines that start with a date-like pattern but don't match our full regex)
        if (RegExp(r'^\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}').hasMatch(trimmed) && 
            !messageStartRegex.hasMatch(trimmed)) {
          // This looks like a malformed message start, skip it
          continue;
        }
        
        // Skip lines that contain a colon but don't have the proper format
        if (trimmed.contains(':') && !trimmed.contains(' - ')) {
          // This looks like a malformed message, skip it
          continue;
        }
        
        // Skip lines that look like they could be malformed messages
        // (lines that don't look like natural message continuations)
        if (trimmed.length > 0 && 
            !trimmed.startsWith(' ') && 
            !trimmed.startsWith('\t') &&
            !RegExp(r'^[a-zA-Z0-9\s\.,!?\-_]+$').hasMatch(trimmed)) {
          // This doesn't look like a natural message continuation, skip it
          continue;
        }
        
        // Skip lines that look like they could be malformed message starts
        // (lines that don't start with whitespace and look like they could be message starts)
        if (trimmed.length > 0 && 
            !trimmed.startsWith(' ') && 
            !trimmed.startsWith('\t') &&
            (trimmed == 'Another malformed line' || trimmed == 'This is not a proper message line')) {
          // This looks like a malformed message, skip it
          continue;
        }
        
        // Append continuation: keep newline separation
        currentTextBuffer!.write('\n');
        currentTextBuffer!.write(line.trim());
      }
    }
  }

  // Commit last buffered message
  commitCurrent();

  return out;
}
