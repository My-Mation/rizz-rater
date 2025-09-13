/// Model class representing a single chat message
class ChatMessage {
  final String name;
  final String text;

  ChatMessage({
    required this.name,
    required this.text,
  });

  @override
  String toString() {
    return 'ChatMessage(name: $name, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.name == name && other.text == text;
  }

  @override
  int get hashCode => name.hashCode ^ text.hashCode;
}
