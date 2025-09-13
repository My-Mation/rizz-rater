import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _zipFileName;
  String? _extractedText;
  bool _isLoading = false;

  Future<void> _pickAndProcessZip() async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _zipFileName = null;
      _extractedText = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          _zipFileName = file.name;
        });

        final bytes = await File(file.path!).readAsBytes();

        final archive = ZipDecoder().decodeBytes(bytes);

        ArchiveFile? txtFile;
        for (var fileInArchive in archive) {
          if (fileInArchive.isFile && fileInArchive.name.endsWith('.txt')) {
            txtFile = fileInArchive;
            break;
          }
        }

        if (txtFile != null) {
          final content = String.fromCharCodes(txtFile.content as List<int>);
          setState(() {
            _extractedText = content;
          });
        } else {
          setState(() {
            _extractedText = 'No .txt file found in the ZIP.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _extractedText = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ZIP File Reader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickAndProcessZip,
              child: const Text('Upload ZIP'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (_zipFileName != null)
                Text(
                  'Selected File: $_zipFileName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              if (_extractedText != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '''Extracted Text:

$_extractedText''',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
