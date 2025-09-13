// This is a basic Flutter widget test for the WhatsApp Chat Reader app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rizz_rater/main.dart';

void main() {
  testWidgets('WhatsApp Chat Reader app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed.
    expect(find.text('WhatsApp Chat Reader'), findsOneWidget);

    // Verify that the upload button is present.
    expect(find.text('Upload ZIP File'), findsOneWidget);

    // Verify that the privacy warning is displayed.
    expect(find.text('Privacy Notice: Chat data is processed locally only. Never upload sensitive chats to public servers.'), findsOneWidget);
  });
}
