import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Renders a picked image from raw bytes.
///
/// `Image.file(File(...))` throws on Flutter Web ("Image.file is not
/// supported on Flutter Web"), so every screen that shows a picked photo
/// should go through this widget instead — it works identically on
/// Web, Android, iOS, and Desktop.
class AppImage extends StatelessWidget {
  final Uint8List bytes;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.bytes,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.memory(bytes, height: height, width: width, fit: fit);
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}