# Setup Instructions

## 1. Get Your Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

## 2. Configure the App

1. Create a `.env` file in the root directory of the project
2. Add your API key to the file:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```
   Replace `your_actual_api_key_here` with the API key you copied from step 1.

## 3. Run the App

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app

## 4. Use the App

1. **Upload ZIP File**: Tap "Upload ZIP File" and select a ZIP file containing a WhatsApp chat export (.txt file)
2. **View Parsed Chat**: The app will parse and display the chat messages in a clean format
3. **Rate with AI**: Tap "Rate Chat with AI" to get an AI-powered analysis of the chat
4. **View Results**: The AI will provide a detailed rating covering tone, clarity, friendliness, and engagement

## Troubleshooting

- **"GEMINI_API_KEY not found"**: Make sure you created the `.env` file with the correct API key
- **"Error getting AI rating"**: Check your internet connection and API key validity
- **"No .txt file found"**: Make sure your ZIP file contains a .txt file with WhatsApp chat export

## Privacy Note

- Chat data is processed locally for parsing
- Only the parsed chat text is sent to Gemini for analysis
- No raw files or personal data are stored or uploaded to external servers
