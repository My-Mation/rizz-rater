import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  final ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  final ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://upload.wikimedia.org/wikipedia/commons/2/2e/Google_G_Logo.svg",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Chat Rater")),
      body: DashChat(
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    // Add the user's message first
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;

      // Start streaming AI response
      gemini.streamGenerateContent(question).listen((event) {
        String newText = event.content?.parts
                ?.whereType<TextPart>()
                .map((p) => p.text)
                .join() ?? "";

        setState(() {
          if (messages.isNotEmpty && messages.first.user == geminiUser) {
            // Append new text to the AI message for a typing effect
            ChatMessage last = messages.first;
            messages[0] = ChatMessage(
              user: last.user,
              createdAt: last.createdAt,
              text: last.text + newText,
            );
          } else {
            // Create a new AI message
            ChatMessage aiMessage = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: newText,
            );
            messages = [aiMessage, ...messages];
          }
        });
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }
}
