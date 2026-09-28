import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../widgets/app_image.dart';
import 'analyzing_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _pickedBytes;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes(); // works on Web + mobile + desktop
      setState(() => _pickedBytes = bytes);
    }
  }

  void _analyze() {
    if (_pickedBytes == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(imageBytes: _pickedBytes!),
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
        title: Text('Upload Image', style: AppText.h2),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DottedFrame(
                child: _pickedBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 44,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 12),
                          Text('Tap to upload a photo', style: AppText.label),
                          Text('or choose from gallery', style: AppText.body),
                        ],
                      )
                    : AppImage(
                        bytes: _pickedBytes!,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(14),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // On desktop web there's usually no camera to open, so
            // "Take Photo" just opens the same file browser as "Gallery" —
            // confusing to show as two separate buttons. Collapse to one
            // clear "Upload Image" action on web; keep both on mobile where
            // the camera actually opens.
            if (kIsWeb)
              ElevatedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Image'),
                style: primaryButtonStyle(),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: primaryButtonStyle(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Tips for better results:', style: AppText.label),
            const SizedBox(height: 8),
            const _Tip(text: 'Use clear and well-lit images'),
            const _Tip(text: 'Focus on the affected part of the plant'),
            const _Tip(text: 'Avoid blurry or dark photos'),
            const SizedBox(height: 16),
            if (_pickedBytes != null)
              ElevatedButton(
                onPressed: _analyze,
                style: primaryButtonStyle(),
                child: const Text('Analyze Image'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(text, style: AppText.body),
        ],
      ),
    );
  }
}

/// Simple dashed-border container standing in for the mockup's dotted upload frame.
class DottedFrame extends StatelessWidget {
  final Widget child;
  const DottedFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
