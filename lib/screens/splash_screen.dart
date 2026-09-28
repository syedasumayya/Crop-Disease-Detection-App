import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Drawn crop-field scene — works immediately, no assets needed.
          // To use a real photo instead: add assets/images/field_bg.jpg,
          // register it in pubspec.yaml (see README), then replace the
          // CustomPaint below with:
          //   Image.asset('assets/images/field_bg.jpg', fit: BoxFit.cover)
          CustomPaint(painter: _FieldScenePainter(), child: Container()),
          // Dark gradient overlay so text stays readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    children: const [
                      Icon(Icons.eco, color: Colors.white, size: 26),
                      SizedBox(width: 6),
                      Text(
                        'CropGuard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Healthy Crops\nfor a Sustainable Future',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Detect crop diseases early with AI and take the right action.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      style: primaryButtonStyle(
                        bg: Colors.white,
                        fg: AppColors.primaryDark,
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a simple stylized crop field: gradient sky + sun + rolling green
/// rows with furrow lines, so the splash screen looks like a field without
/// needing any image asset.
class _FieldScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD9A0), Color(0xFF9CC9A1), Color(0xFF2D6A4F)],
        stops: [0.0, 0.45, 0.7],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Sun
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.16),
      w * 0.09,
      Paint()..color = const Color(0xFFFFF3D6).withOpacity(0.9),
    );

    // Rolling hill (background layer)
    final hillBack = Path()
      ..moveTo(0, h * 0.42)
      ..quadraticBezierTo(w * 0.3, h * 0.32, w * 0.55, h * 0.4)
      ..quadraticBezierTo(w * 0.8, h * 0.48, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hillBack, Paint()..color = const Color(0xFF3A5A40));

    // Field rows (foreground), darker green with lighter furrow lines
    final hillFront = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.25, h * 0.46, w * 0.5, h * 0.53)
      ..quadraticBezierTo(w * 0.75, h * 0.6, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hillFront, Paint()..color = const Color(0xFF1B4332));

    // Furrow lines across the field for a "rows of crops" look
    final rowPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 2;
    for (double y = h * 0.62; y < h; y += 26) {
      final curveOffset = (y - h * 0.55) * 0.25;
      final path = Path()
        ..moveTo(-20, y)
        ..quadraticBezierTo(w * 0.5, y - curveOffset, w + 20, y);
      canvas.drawPath(path, rowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
