import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/chat_message.dart';
import '../utils/chat_parser.dart';
import '../services/gemini_service.dart';
import 'onboarding_page.dart';

/// Decode bytes with BOM handling for UTF-8
String decodeTextFile(List<int> bytes) {
  String text = utf8.decode(bytes, allowMalformed: true);
  // Remove BOM if present (UTF-8 BOM is \uFEFF)
  if (text.startsWith('\uFEFF')) {
    text = text.substring(1);
  }
  return text;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _zipFileName;
  String? _extractedText;
  List<ChatMessage> _chatMessages = [];
  bool _isLoading = false;
  bool _showSystemMessages = false;
  String? _errorMessage;
  String? _geminiRating;
  bool _isRatingLoading = false;

  Future<void> _pickAndProcessZip() async {
    setState(() {
      _isLoading = true;
      _zipFileName = null;
      _extractedText = null;
      _chatMessages = [];
      _errorMessage = null;
      _geminiRating = null;
    });

    try {
      // For Android 13+, file picker works without explicit storage permission
      // For older versions, we'll try to request permission
      if (Platform.isAndroid) {
        try {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt < 33) {
            // Android 12 and below - request storage permission
            bool hasPermission = await _requestStoragePermission();
            if (!hasPermission) {
              setState(() {
                _errorMessage = 'Storage permission is required to access files. Please grant permission in settings.';
              });
              return;
            }
          }
        } catch (e) {
          // If we can't determine Android version, try requesting permission
          bool hasPermission = await _requestStoragePermission();
          if (!hasPermission) {
            setState(() {
              _errorMessage = 'Storage permission is required to access files. Please grant permission in settings.';
            });
            return;
          }
        }
      }

      // Pick ZIP file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null) {
        setState(() {
          _errorMessage = 'No file selected.';
        });
        return;
      }

        PlatformFile file = result.files.first;
      
      // Check file size (warn if > 10MB)
      if (file.size > 10 * 1024 * 1024) {
        setState(() {
          _errorMessage = 'File is very large (${(file.size / (1024 * 1024)).toStringAsFixed(1)}MB). Processing may take a while.';
        });
      }

      setState(() {
        _zipFileName = file.name;
        });

        final bytes = await File(file.path!).readAsBytes();

        final archive = ZipDecoder().decodeBytes(bytes);

        // Find first .txt file
        ArchiveFile? txtFile;
        for (var fileInArchive in archive) {
          if (fileInArchive.isFile && fileInArchive.name.endsWith('.txt')) {
            txtFile = fileInArchive;
            break;
          }
        }

      if (txtFile == null) {
          setState(() {
          _errorMessage = 'No .txt file found in the ZIP archive.';
        });
        return;
      }

      final content = decodeTextFile(txtFile.content as List<int>);
      
      // Parse WhatsApp chat export
      final parsedMessages = parseWhatsAppExport(content);
      
      setState(() {
        _extractedText = content;
        _chatMessages = parsedMessages;
        _errorMessage = null;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing file: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+ - file picker should work without explicit permission
          return true;
        } else {
          // Android 12 and below - request storage permission
          final permission = await Permission.storage.request();
          if (permission == PermissionStatus.denied) {
            // Show dialog explaining why permission is needed
            await _showPermissionDialog();
            return false;
          } else if (permission == PermissionStatus.permanentlyDenied) {
            // Show dialog to open settings
            await _showSettingsDialog();
            return false;
          }
          return permission == PermissionStatus.granted;
        }
      } catch (e) {
        // Fallback to requesting storage permission
        final permission = await Permission.storage.request();
        return permission == PermissionStatus.granted;
      }
    }
    return true; // For other platforms, assume permission is granted
  }

  Future<void> _showPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs storage permission to access ZIP files containing your WhatsApp chat exports. Please grant permission to continue.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Grant Permission'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.storage.request();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSettingsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Storage permission has been permanently denied. Please enable it in app settings to use this feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _rateChatWithGemini() async {
    if (_chatMessages.isEmpty) {
      setState(() {
        _errorMessage = 'Please upload and parse a chat first.';
      });
      return;
    }

    setState(() {
      _isRatingLoading = true;
      _geminiRating = null;
      _errorMessage = null;
    });

    try {
      // Convert chat messages to the format expected by Gemini
      final chatText = _chatMessages
          .map((message) => '${message.name}: ${message.text}')
          .join('\n');

      final rating = await GeminiService.rateChat(chatText);
      
      setState(() {
        _geminiRating = rating;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting AI rating: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isRatingLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Rizz Rater'),
        backgroundColor: const Color(0xFF1E3A5F), // Subtle dark blue
      ),
      body: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroundofrizz.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Color(0x80000000), BlendMode.multiply),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: const Border.fromBorderSide(BorderSide(color: Color(0xFF00E5FF))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'insert funny text here',
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tutorial Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingPage()),
                  );
                },
                icon: const Icon(Icons.school),
                label: const Text('How to Use (Tutorial)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndProcessZip,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload ZIP File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // File Info
              if (_zipFileName != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.file_present, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'File: $_zipFileName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              
              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              
              // Chat Messages
              if (_chatMessages.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Chat Messages (${_chatMessages.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 10),
                
                // AI Rating Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRatingLoading ? null : _rateChatWithGemini,
                    icon: _isRatingLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(_isRatingLoading ? 'Analyzing...' : 'Rate Chat with AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // AI Rating Display
                if (_geminiRating != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.secondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'AI Chat Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),

                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _geminiRating!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _chatMessages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              
              // Raw Text (if no parsed messages)
              if (_extractedText != null && _chatMessages.isEmpty) ...[
                const Text(
                  'Raw Text (No WhatsApp format detected):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _extractedText!,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20), // Space at bottom
          ],
        ),
      ),
    ),
  );
  }
}
