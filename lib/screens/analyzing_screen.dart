import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const AnalyzingScreen({super.key, required this.imageBytes});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    try {
      // Point this at your FastAPI server, e.g. http://10.0.2.2:8000/predict
      // (10.0.2.2 is the Android emulator's alias for your host machine;
      // use http://127.0.0.1:8000/predict when running on Chrome/web).
      final uri = Uri.parse('http://127.0.0.1:8000/predict');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          widget.imageBytes,
          filename: 'leaf.jpg',
        ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      String disease = 'Unknown';
      double confidence = 0;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        disease = data['disease'] ?? 'Unknown';
        confidence = (data['confidence'] ?? 0).toDouble();
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageBytes: widget.imageBytes,
            disease: disease,
            confidence: confidence,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageBytes: widget.imageBytes,
            disease: 'Connection error',
            confidence: 0,
            error: 'Could not reach the server. Check your backend URL and try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Analyzing your image...',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}