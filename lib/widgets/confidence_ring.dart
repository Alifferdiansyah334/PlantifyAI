import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../theme/app_theme.dart';

class ConfidenceRing extends StatelessWidget {
  final double confidence;
  final Color color;
  final double size;

  const ConfidenceRing({
    super.key,
    required this.confidence,
    this.color = AppTheme.accentGreen,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: Size(size, size),
              painter: ConfidenceRingPainter(
                percentage: confidence,
                color: color,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(confidence * 100).toInt()}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.225,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Match',
                  style: GoogleFonts.notoSans(
                    fontSize: size * 0.125,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConfidenceRingPainter extends CustomPainter {
  final double percentage;
  final Color color;

  ConfidenceRingPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;

    // Background Circle
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Foreground Arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Rotate -90 degrees to start from top
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 2);
    
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius - strokeWidth / 2);
    canvas.drawArc(rect, 0, 2 * pi * percentage, false, fgPaint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ConfidenceRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
