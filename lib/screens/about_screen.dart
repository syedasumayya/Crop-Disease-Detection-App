import 'package:flutter/material.dart';
import '../theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('About CropGuard', style: AppText.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 12),
                Text('CropGuard', style: AppText.h1),
                const SizedBox(height: 4),
                const Text('Version 1.0.0', style: AppText.body),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CropGuard helps farmers spot crop leaf diseases early. Take a photo of a '
            'leaf and an AI model identifies the likely disease, then suggests what to '
            'do next.',
            style: AppText.body,
          ),
          const SizedBox(height: 24),
          Text('How it works', style: AppText.h2),
          const SizedBox(height: 12),
          const _Step(number: '1', text: 'Upload a clear photo of one leaf.'),
          const _Step(number: '2', text: 'The AI model analyzes the image.'),
          const _Step(
            number: '3',
            text: 'Review the result, symptoms, and recommended actions.',
          ),
          const _Step(
            number: '4',
            text: 'Download a PDF report to keep or share.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF3E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Results are AI estimates and not a substitute for advice from a '
              'qualified agronomist.',
              style: AppText.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}
