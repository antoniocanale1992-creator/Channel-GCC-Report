import 'package:flutter/material.dart';

/// Sfondo a tema Warm Titanium & TCG Arena Playmat
/// Tonalità ardesia calda, visibile, neutra e rifinita (NO Nero pece, NO Blu notte)
class TcgPlaymatBackground extends StatelessWidget {
  final Widget child;

  const TcgPlaymatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1120), // Slate 950 Deep
            Color(0xFF0F172A), // #0F172A Slate 900
            Color(0xFF131D35), // Slate 850
          ],
        ),
      ),
      child: Stack(
        children: [
          // Trama micro-weave tattile in filigrana ambra calda (opacità 3%)
          Positioned.fill(
            child: CustomPaint(
              painter: _PlaymatTexturePainter(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PlaymatTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double step = 48.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    for (double x = 0; x < size.width + size.height * 2; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
