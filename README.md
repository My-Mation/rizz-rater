# WhatsApp Chat Reader

A Flutter app that allows you to upload a ZIP file containing a WhatsApp chat export, parse the chat messages, and get AI-powered analysis of your conversations using Google's Gemini AI.

## Features

- **ZIP File Upload**: Upload ZIPs containing WhatsApp chat `.txt` files  
- **WhatsApp Parsing**: Supports multiple timestamp formats and date styles  
- **Clean Display**: Shows only sender names and messages, filtering system messages  
- **Multi-line Support**: Properly handles multi-line messages  
- **AI Chat Rating**: Rate chats on tone, clarity, friendliness, and engagement  
- **Error Handling**: Robust handling for file operations and parsing  
- **Privacy Focused**: Data processed locally; only AI rating uses external servers  

## Supported WhatsApp Export Formats

- 24-hour format: `05/09/2025, 14:32 - Name: Message`  
- 12-hour format: `5/9/25, 2:32 PM - Name: Message`  
- Various date separators: `/` and `-`  
- Different date formats: `dd/mm/yyyy`, `d/m/yy`, etc.  

## How to Use

1. **Setup**: Create a `.env` file with your Gemini API key  
2. **Export**: Export WhatsApp chat as a `.txt` file  
3. **Compress**: Compress the `.txt` into a ZIP  
4. **Upload**: Tap "Upload ZIP File" in the app  
5. **Parse**: Select your ZIP to parse messages  
6. **Rate**: Tap "Rate Chat with AI" to get analysis  
7. **View**: See parsed messages and AI rating results  

## Privacy Notice

⚠️ **Important**: The app processes your chat data locally. Never upload sensitive data to untrusted services.

## Installation

1. Clone the repository  
2. Run `flutter pub get` to install dependencies  
3. Create a `.env` file in the root with your Gemini API key:
