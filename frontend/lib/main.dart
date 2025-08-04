import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const VoiceDetectorApp());
}

class VoiceDetectorApp extends StatelessWidget {
  const VoiceDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Detector',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const VoiceDetectorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VoiceDetectorHome extends StatefulWidget {
  const VoiceDetectorHome({super.key});

  @override
  State<VoiceDetectorHome> createState() => _VoiceDetectorHomeState();
}

class _VoiceDetectorHomeState extends State<VoiceDetectorHome> {
  String result = 'No file selected yet.';

  Future<void> pickAndUploadFile() async {
    final resultFile = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (resultFile != null) {
      final file = resultFile.files.single;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/analyze-voice/'),
      );

      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        setState(() {
          result = 'Error: file.bytes is null (only supported on web)';
        });
        return;
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          final res = await http.Response.fromStream(response);
          final data = jsonDecode(res.body);
          setState(() {
            result = 'Detected: ${data["result"]}';
          });
        } else {
          setState(() {
            result = 'Error: Failed with status ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          result = 'Error: $e';
        });
      }
    } else {
      setState(() {
        result = 'No file selected.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Detector'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: pickAndUploadFile,
                icon: const Icon(Icons.mic),
                label: const Text('Pick Audio File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                result,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
