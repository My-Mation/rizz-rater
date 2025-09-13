@echo off
echo WhatsApp Chat Reader - APK Installation Helper
echo ================================================
echo.

echo Available APK files:
echo 1. Universal APK (21.6 MB) - Works on all devices
echo 2. ARM64 APK (8.4 MB) - For modern 64-bit devices
echo 3. ARM32 APK (7.8 MB) - For older 32-bit devices
echo 4. x86_64 APK (8.5 MB) - For emulators and x86 devices
echo.

set /p choice="Select APK to install (1-4): "

if "%choice%"=="1" (
    set apk_file=build\app\outputs\flutter-apk\app-release.apk
    echo Installing Universal APK...
) else if "%choice%"=="2" (
    set apk_file=build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
    echo Installing ARM64 APK...
) else if "%choice%"=="3" (
    set apk_file=build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
    echo Installing ARM32 APK...
) else if "%choice%"=="4" (
    set apk_file=build\app\outputs\flutter-apk\app-x86_64-release.apk
    echo Installing x86_64 APK...
) else (
    echo Invalid choice. Exiting...
    pause
    exit /b 1
)

echo.
echo Checking if device is connected...
adb devices

echo.
echo Installing APK...
adb install "%apk_file%"

if %errorlevel%==0 (
    echo.
    echo ✅ Installation successful!
    echo.
    echo Next steps:
    echo 1. Open the app on your device
    echo 2. Grant storage permission when prompted
    echo 3. Upload a WhatsApp chat ZIP file
    echo 4. Enjoy the AI-powered chat analysis!
) else (
    echo.
    echo ❌ Installation failed!
    echo.
    echo Troubleshooting:
    echo 1. Make sure your device is connected via USB
    echo 2. Enable USB Debugging in Developer Options
    echo 3. Allow USB Debugging when prompted on device
    echo 4. Try installing manually by copying APK to device
)

echo.
pause
