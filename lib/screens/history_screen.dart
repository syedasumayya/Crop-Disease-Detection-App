import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/disease_lookup.dart';

class ScanRecord {
  final String crop;
  final String result; // e.g. "Early Blight" or "Healthy"
  final String date;
  final bool isHealthy;

  ScanRecord({
    required this.crop,
    required this.result,
    required this.date,
    required this.isHealthy,
  });
}

// TODO: replace with scans you actually persist (e.g. sqflite, shared_preferences,
// or a backend endpoint) once a real prediction has been saved with its image.
final List<ScanRecord> _mockScans = [
  ScanRecord(
    crop: 'Tomato Leaf',
    result: 'Early Blight',
    date: 'Apr 25, 2025 · 10:24 AM',
    isHealthy: false,
  ),
  ScanRecord(
    crop: 'Potato Leaf',
    result: 'Late Blight',
    date: 'Apr 20, 2025 · 3:16 PM',
    isHealthy: false,
  ),
  ScanRecord(
    crop: 'Corn Leaf',
    result: 'Healthy',
    date: 'Apr 15, 2025 · 11:02 AM',
    isHealthy: true,
  ),
  ScanRecord(
    crop: 'Wheat Leaf',
    result: 'Rust',
    date: 'Apr 10, 2025 · 5:45 PM',
    isHealthy: false,
  ),
  ScanRecord(
    crop: 'Tomato Leaf',
    result: 'Healthy',
    date: 'Apr 5, 2025 · 9:30 AM',
    isHealthy: true,
  ),
];

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _mockScans.where((s) {
      final matchesFilter =
          _filter == 'All' ||
          (_filter == 'Healthy' && s.isHealthy) ||
          (_filter == 'Diseased' && !s.isHealthy);
      final matchesQuery =
          _query.isEmpty ||
          s.crop.toLowerCase().contains(_query.toLowerCase()) ||
          s.result.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('History', style: AppText.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: appInputDecoration(
                'Search by crop or date...',
                Icons.search,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['All', 'Healthy', 'Diseased'].map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No scans match your search.',
                        style: AppText.body,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final s = filtered[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ScanDetailScreen(scan: s),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: s.isHealthy
                                        ? const Color(0xFFE9F7EF)
                                        : const Color(0xFFFDEDEC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    s.isHealthy
                                        ? Icons.check_circle_outline
                                        : Icons.warning_amber_rounded,
                                    color: s.isHealthy
                                        ? AppColors.primary
                                        : AppColors.danger,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(s.crop, style: AppText.label),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.result,
                                        style: TextStyle(
                                          color: s.isHealthy
                                              ? AppColors.primary
                                              : AppColors.danger,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(s.date, style: AppText.body),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens when a history row is tapped. Mock scans have no stored photo (the
/// real photo only exists once you persist it alongside a live prediction),
/// so this shows a placeholder tile instead of a picked image.
class ScanDetailScreen extends StatelessWidget {
  final ScanRecord scan;
  const ScanDetailScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final info = lookupDiseaseInfo(scan.result);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(scan.crop, style: AppText.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: scan.isHealthy
                    ? const Color(0xFFE9F7EF)
                    : const Color(0xFFFDEDEC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  scan.isHealthy ? Icons.eco : Icons.warning_amber_rounded,
                  size: 56,
                  color: scan.isHealthy ? AppColors.primary : AppColors.danger,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(scan.result, style: AppText.h1),
            const SizedBox(height: 4),
            Text(scan.date, style: AppText.body),
            if (info['cause'] != null) ...[
              const SizedBox(height: 8),
              Text('Likely cause: ${info['cause']}', style: AppText.body),
            ],
            const SizedBox(height: 20),
            Text('Symptoms', style: AppText.h2),
            const SizedBox(height: 8),
            ...List<String>.from(info['symptoms']).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('•  $s', style: AppText.body),
              ),
            ),
            const SizedBox(height: 16),
            Text('Recommended Actions', style: AppText.h2),
            const SizedBox(height: 8),
            ...List<String>.from(info['actions']).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s, style: AppText.body)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
