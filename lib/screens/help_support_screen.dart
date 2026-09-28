import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _feedbackController = TextEditingController();

  static const _faqs = <List<String>>[
    [
      'How do I scan a leaf?',
      'Open the Upload tab, choose a clear photo of one leaf, then tap Analyze Image. '
          'Results appear in a few seconds.',
    ],
    [
      'Why is the result wrong or low confidence?',
      'Blurry, dark, or cluttered photos confuse the model. Photograph a single leaf '
          'in daylight, close up, with the affected area in focus.',
    ],
    [
      'The app says it could not reach the server.',
      'The AI backend must be running (uvicorn main:app --host 0.0.0.0 --port 8000) '
          'and the app must point to its address.',
    ],
    [
      'Can I save a report?',
      'Yes. On the Result screen tap Download PDF to save the diagnosis, symptoms, '
          'and recommended actions.',
    ],
    [
      'Is the diagnosis a substitute for an expert?',
      'No. CropGuard gives an AI estimate. For serious outbreaks, confirm with a '
          'local agronomist before treating.',
    ],
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something first.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('feedback_messages') ?? [];
    saved.add(text);
    await prefs.setStringList('feedback_messages', saved);
    if (!mounted) return;
    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks! Your feedback was saved.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Help & Support', style: AppText.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Frequently asked questions', style: AppText.h2),
          const SizedBox(height: 12),
          ..._faqs.map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(f[0], style: AppText.label),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(f[1], style: AppText.body)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Send feedback', style: AppText.h2),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tell us what went wrong or what to improve...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _sendFeedback,
            style: primaryButtonStyle(),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
