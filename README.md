# WhatsApp Chat Reader

A Flutter app that allows you to upload a ZIP file containing a WhatsApp chat export, parse the chat messages, and get AI-powered analysis of your conversations using Google's Gemini AI.

## Features

- **ZIP File Upload**: Upload a ZIP file containing a WhatsApp chat export (.txt file)
- **WhatsApp Parsing**: Automatically parses WhatsApp chat exports with various timestamp formats
- **Clean Display**: Shows only sender names and messages, filtering out system messages and metadata
- **Multi-line Support**: Properly handles multi-line messages and message continuations
- **AI Chat Rating**: Rate your WhatsApp chats using Google's Gemini AI for tone, clarity, friendliness, and engagement analysis
- **Error Handling**: Comprehensive error handling for file operations and parsing
- **Privacy Focused**: All processing is done locally - no data is uploaded to external servers (except for AI rating)

## Supported WhatsApp Export Formats

The app supports common WhatsApp export formats including:
- 24-hour format: `05/09/2025, 14:32 - Name: Message`
- 12-hour format: `5/9/25, 2:32 PM - Name: Message`
- Various date separators: `/` and `-`
- Different date formats: `dd/mm/yyyy`, `d/m/yy`, etc.

## How to Use

1. **Setup**: Create a `.env` file with your Gemini API key (see [SETUP.md](SETUP.md))
2. **Export**: Export your WhatsApp chat as a .txt file
3. **Compress**: Compress the .txt file into a ZIP archive
4. **Upload**: Open the app and tap "Upload ZIP File"
5. **Parse**: Select your ZIP file to parse the chat messages
6. **Rate**: Tap "Rate Chat with AI" to get AI analysis
7. **View**: See both the parsed messages and AI rating results

## Privacy Notice

⚠️ **Important**: This app processes your chat data locally on your device. Never upload sensitive chat data to public servers or untrusted services. The app is designed to keep your data private and secure.

## Technical Details

- Built with Flutter
- Uses `file_picker` for file selection
- Uses `archive` package for ZIP file extraction
- Uses `permission_handler` for storage permissions
- Comprehensive unit tests for the chat parser

## Installation

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Create a `.env` file in the root directory with your Gemini API key:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
   Get your API key from: https://makersuite.google.com/app/apikey
4. Run `flutter run` to start the app

## AI Chat Rating

The app includes AI-powered chat rating using Google's Gemini API. To use this feature:

1. Set up your Gemini API key in the `.env` file
2. Upload and parse a WhatsApp chat
3. Use the `GeminiService.rateChat()` method to get detailed analysis

The AI will analyze your chat for:
- Overall tone and mood
- Communication clarity
- Friendliness and warmth
- Engagement level
- Areas for improvement
- Overall rating (1-10 scale)

## Testing

Run the test suite with:
```bash
flutter test
```

The app includes comprehensive unit tests for the WhatsApp chat parser, covering various edge cases and message formats.