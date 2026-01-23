import 'package:flutter/material.dart';

class HistogramPainter extends CustomPainter {
  final List<double> values;
  final String label;

  HistogramPainter({
    required this.values,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final bins = 10;
    final counts = List<int>.filled(bins, 0);

    for (final v in values) {
      if (maxV == minV) continue;
      final i = ((v - minV) / (maxV - minV) * (bins - 1))
          .clamp(0, bins - 1)
          .toInt();
      counts[i]++;
    }

    final maxCount = counts.reduce((a, b) => a > b ? a : b).toDouble();
    final barWidth = size.width / bins;

    final paint = Paint()
      ..color = Colors.blue.withAlpha((0.6 * 255).toInt());

    for (int i = 0; i < bins; i++) {
      if (maxCount == 0) continue;
      final h = counts[i] / maxCount * size.height;
      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - h,
          barWidth * 0.9,
          h,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HistogramPainter old) =>
      values != old.values;
}