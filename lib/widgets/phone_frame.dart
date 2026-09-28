import 'package:flutter/material.dart';

/// On a wide screen (e.g. Chrome on a laptop) this shows the app inside a
/// phone-shaped frame so you can judge the real mobile layout. On an actual
/// phone or a narrow window it does nothing and the app fills the screen.
class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width < 700) return child;

    const phoneWidth = 390.0;
    final phoneHeight = (media.size.height - 64).clamp(560.0, 844.0);

    return Container(
      color: const Color(0xFF0F1A14),
      child: Center(
        child: Container(
          width: phoneWidth + 24,
          height: phoneHeight + 24,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: const Color(0xFF3A3A3A), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: MediaQuery(
              data: media.copyWith(size: Size(phoneWidth, phoneHeight)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
