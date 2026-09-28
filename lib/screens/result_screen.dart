import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme.dart';
import '../widgets/app_image.dart';
import '../utils/disease_lookup.dart';

class ResultScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final String
  disease; // raw label from the model, e.g. "Strawberry___Leaf_scorch"
  final double confidence;
  final String? error;

  const ResultScreen({
    super.key,
    required this.imageBytes,
    required this.disease,
    required this.confidence,
    this.error,
  });

  Future<void> _downloadPdf(
    DiseaseDisplay display,
    Map<String, dynamic> info,
  ) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CropGuard Disease Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(image, height: 220, fit: pw.BoxFit.cover),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Crop: ${display.crop}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                display.isHealthy
                    ? 'Status: Healthy'
                    : 'Condition: ${display.condition}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Confidence: ${confidence.toStringAsFixed(1)}%',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Symptoms',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              ...List<String>.from(info['symptoms']).map(
                (s) =>
                    pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Recommended Actions',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              ...List<String>.from(info['actions']).map(
                (s) =>
                    pw.Bullet(text: s, style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'cropguard_report.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final display = parseDiseaseLabel(disease);
    final info = lookupDiseaseInfo(display.condition);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Result', style: AppText.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppImage(
              bytes: imageBytes,
              height: 220,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!, style: const TextStyle(color: AppColors.danger))
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: display.isHealthy
                      ? const Color(0xFFE9F7EF)
                      : const Color(0xFFFDEDEC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      display.isHealthy
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: display.isHealthy
                          ? AppColors.primary
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            display.isHealthy ? 'Healthy' : 'Disease Detected',
                            style: AppText.label,
                          ),
                          Text(
                            '${display.crop} — ${display.condition}',
                            style: AppText.h2,
                          ),
                          if (info['cause'] != null)
                            Text(
                              'Likely cause: ${info['cause']}',
                              style: AppText.body,
                            ),
                          Text(
                            'Confidence: ${confidence.toStringAsFixed(1)}%',
                            style: AppText.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('Symptoms', style: AppText.h2),
              const SizedBox(height: 8),
              ...List<String>.from(
                info['symptoms'],
              ).map((s) => _BulletLine(text: s)),
              const SizedBox(height: 16),
              Text('Recommended Actions', style: AppText.h2),
              const SizedBox(height: 8),
              ...List<String>.from(info['actions']).map(
                (s) => _BulletLine(
                  text: s,
                  icon: Icons.check_circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _downloadPdf(display, info),
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                style: primaryButtonStyle(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _BulletLine({
    required this.text,
    this.icon = Icons.fiber_manual_record,
    this.color = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              icon,
              size: icon == Icons.fiber_manual_record ? 8 : 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}
