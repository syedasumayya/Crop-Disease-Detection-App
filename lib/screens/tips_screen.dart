import 'package:flutter/material.dart';
import '../theme.dart';

class TipCategory {
  final String title;
  final IconData icon;
  final List<String> points;
  TipCategory({required this.title, required this.icon, required this.points});
}

// TODO: replace with tips fetched from a backend endpoint if you want these
// to be editable without shipping a new app version.
final List<TipCategory> _tips = [
  TipCategory(
    title: 'Watering',
    icon: Icons.water_drop_outlined,
    points: [
      'Water early morning to reduce evaporation and fungal risk',
      'Avoid wetting the leaves directly — water at the base',
      'Check soil moisture before watering, not on a fixed schedule',
    ],
  ),
  TipCategory(
    title: 'Preventing Disease',
    icon: Icons.shield_outlined,
    points: [
      'Rotate crops each season to break disease cycles',
      'Remove and destroy infected leaves promptly',
      'Space plants to keep good air circulation',
    ],
  ),
  TipCategory(
    title: 'Soil & Nutrition',
    icon: Icons.grass_outlined,
    points: [
      'Test soil pH periodically and amend as needed',
      'Use balanced fertilizer — avoid excess nitrogen',
      'Add compost to improve soil structure over time',
    ],
  ),
  TipCategory(
    title: 'Using CropGuard Well',
    icon: Icons.camera_alt_outlined,
    points: [
      'Take photos in daylight, avoiding harsh shadows',
      'Photograph the affected leaf area up close',
      'Re-scan after treatment to confirm improvement',
    ],
  ),
];

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Crop Care Guide', style: AppText.h2),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _tips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final t = _tips[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(t.icon, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(t.title, style: AppText.h2),
                  ],
                ),
                const SizedBox(height: 10),
                ...t.points.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: AppText.body)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}