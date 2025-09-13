# APK Installation Guide

## 📱 APK Files Generated

Your WhatsApp Chat Reader app has been successfully built as APK files:

### Main APK (Universal)
- **File**: `build/app/outputs/flutter-apk/app-release.apk`
- **Size**: ~21.6 MB
- **Compatibility**: All Android devices (universal)

### Optimized APKs (Smaller Size)
- **ARM64**: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~8.0 MB)
- **ARM32**: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (~7.4 MB)
- **x86_64**: `build/app/outputs/flutter-apk/app-x86_64-release.apk` (~8.1 MB)

## 🚀 Installation Instructions

### Method 1: Direct Installation (Recommended)
1. **Transfer APK**: Copy the APK file to your Android device
2. **Enable Unknown Sources**: 
   - Go to Settings → Security → Unknown Sources (enable)
   - Or Settings → Apps → Special Access → Install Unknown Apps
3. **Install**: Tap the APK file and follow the installation prompts

### Method 2: ADB Installation
```bash
# Connect device via USB and run:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 3: Google Drive/Dropbox
1. Upload APK to cloud storage
2. Download on Android device
3. Install from Downloads folder

## ⚙️ Setup After Installation

### 1. Create .env File
Since the APK doesn't include the .env file, you need to set up the Gemini API key:

**Option A: Use the app without AI features**
- The app will work for parsing WhatsApp chats
- AI rating will show an error (expected)

**Option B: Set up API key (Advanced)**
- Root your device (not recommended)
- Or use a file manager app to create .env file in app directory
- Add: `GEMINI_API_KEY=your_api_key_here`

### 2. Grant Permissions
- **Storage Permission**: Allow when prompted
- **File Access**: Required for ZIP file selection

## 📋 Usage Instructions

### 1. Prepare Your WhatsApp Chat
1. Open WhatsApp → Select Chat → Menu → More → Export Chat
2. Choose "Without Media" to get a .txt file
3. Compress the .txt file into a ZIP archive

### 2. Use the App
1. **Open App**: Launch "WhatsApp Chat Reader"
2. **Upload**: Tap "Upload ZIP File" and select your ZIP
3. **View Chat**: See parsed messages in clean format
4. **Rate with AI**: Tap "Rate Chat with AI" (requires API key setup)

## 🔧 Troubleshooting

### Installation Issues
- **"App not installed"**: Check if you have enough storage space
- **"Unknown source blocked"**: Enable "Install from Unknown Sources"
- **"Package appears to be corrupt"**: Re-download the APK file

### Runtime Issues
- **"GEMINI_API_KEY not found"**: Expected if you haven't set up the API key
- **"No .txt file found"**: Make sure your ZIP contains a .txt file
- **"Storage permission required"**: 
  - **Android 13+**: Should work automatically (no permission needed)
  - **Android 12 and below**: Grant storage permission when prompted
  - **Permission denied**: Go to Settings → Apps → WhatsApp Chat Reader → Permissions → Storage

### Permission Handling
The app now includes smart permission handling:
- **Android 13+**: Uses scoped storage (no permission needed)
- **Android 12 and below**: Requests storage permission with user-friendly dialogs
- **Permission denied**: Shows helpful dialog to open app settings

### Performance
- **Slow loading**: Large chat files may take time to process
- **Memory issues**: Very large chats might cause performance issues
- **Network errors**: Check internet connection for AI features

## 📱 Device Compatibility

### Minimum Requirements
- **Android Version**: 5.0 (API level 21) or higher
- **RAM**: 2GB recommended
- **Storage**: 50MB free space
- **Architecture**: ARM64, ARM32, or x86_64

### Recommended
- **Android Version**: 8.0 or higher
- **RAM**: 4GB or more
- **Storage**: 100MB free space

## 🔒 Security Notes

- **APK Signature**: The APK is signed with debug key (for development)
- **Permissions**: Only requests necessary permissions (storage, internet)
- **Data Privacy**: All processing happens locally on your device
- **AI Features**: Only parsed chat text is sent to Gemini (no raw files)

## 📞 Support

If you encounter issues:
1. Check this troubleshooting guide
2. Verify your Android version compatibility
3. Ensure you have sufficient storage space
4. Try the universal APK if architecture-specific ones fail

## 🎯 Next Steps

1. **Test the App**: Try with a small WhatsApp chat first
2. **Set up API Key**: For AI features (optional)
3. **Share Feedback**: Let us know how it works for you!

---

**Note**: This APK is built for development/testing purposes. For production distribution, consider building with a release keystore and proper app signing.
