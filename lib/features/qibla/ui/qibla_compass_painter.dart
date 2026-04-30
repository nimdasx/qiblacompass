import 'dart:math' as math;
import 'package:flutter/material.dart';

class QiblaCompassPainter extends CustomPainter {
  final double heading;
  final double qiblaBearing;

  QiblaCompassPainter({
    required this.heading,
    required this.qiblaBearing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Border circle
    final borderPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw ticks
    final tickPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final thickTickPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (int i = 0; i < 360; i += 15) {
      final isCardinal = i % 90 == 0;
      final tickLength = isCardinal ? 15.0 : 8.0;
      final angle = (i - heading) * math.pi / 180;
      
      final p1 = Offset(
        center.dx + (radius - tickLength) * math.cos(angle - math.pi / 2),
        center.dy + (radius - tickLength) * math.sin(angle - math.pi / 2),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(angle - math.pi / 2),
        center.dy + radius * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(p1, p2, isCardinal ? thickTickPaint : tickPaint);
      
      // Draw cardinal text (N, E, S, W)
      if (isCardinal) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getCardinalDirection(i),
            style: TextStyle(
              color: i == 0 ? Colors.red : Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + (radius - 30) * math.cos(angle - math.pi / 2) - textPainter.width / 2,
          center.dy + (radius - 30) * math.sin(angle - math.pi / 2) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw Qibla Arrow
    // The Qibla arrow rotates based on bearing - heading
    final qiblaAngle = (qiblaBearing - heading) * math.pi / 180;
    
    final arrowPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(
      center.dx + radius * 0.8 * math.cos(qiblaAngle - math.pi / 2),
      center.dy + radius * 0.8 * math.sin(qiblaAngle - math.pi / 2),
    );
    path.lineTo(
      center.dx + 15 * math.cos(qiblaAngle),
      center.dy + 15 * math.sin(qiblaAngle),
    );
    path.lineTo(
      center.dx + 15 * math.cos(qiblaAngle + math.pi),
      center.dy + 15 * math.sin(qiblaAngle + math.pi),
    );
    path.close();

    // Draw shadow for arrow
    canvas.drawShadow(path, Colors.black, 4.0, true);
    canvas.drawPath(path, arrowPaint);

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerDotPaint);
  }

  String _getCardinalDirection(int degrees) {
    if (degrees == 0) return 'N';
    if (degrees == 90) return 'E';
    if (degrees == 180) return 'S';
    if (degrees == 270) return 'W';
    return '';
  }

  @override
  bool shouldRepaint(QiblaCompassPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.qiblaBearing != qiblaBearing;
  }
}
