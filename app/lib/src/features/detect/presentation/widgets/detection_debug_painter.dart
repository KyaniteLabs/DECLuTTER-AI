import 'package:flutter/material.dart';

import '../../domain/detection.dart';

/// Draws bounding boxes and labels for debug builds.
class DetectionDebugPainter extends CustomPainter {
  DetectionDebugPainter(this.result);

  final DetectionResult result;

  @override
  void paint(Canvas canvas, Size size) {
    if (result.isEmpty) {
      return;
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.deepPurpleAccent.withOpacity(0.9);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.deepPurpleAccent.withOpacity(0.12);

    for (final detection in result.detections) {
      final rect = detection.scaledTo(size);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, strokePaint);

      final label = '${detection.displayLabel} ${(detection.confidence * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1))],
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(maxWidth: size.width);

      final labelPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      final labelBgRect = Rect.fromLTWH(
        rect.left,
        (rect.top - textPainter.height - labelPadding.vertical).clamp(0.0, size.height - textPainter.height),
        textPainter.width + labelPadding.horizontal,
        textPainter.height + labelPadding.vertical,
      );

      final bgRRect = RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4));
      canvas.drawRRect(
        bgRRect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.deepPurple,
      );

      final textOffset = Offset(
        labelBgRect.left + labelPadding.left,
        labelBgRect.top + labelPadding.top,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant DetectionDebugPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
