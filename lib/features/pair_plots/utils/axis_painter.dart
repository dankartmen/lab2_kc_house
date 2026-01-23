import 'package:flutter/material.dart';

import 'plot_mapper.dart';

enum AxisOrientation { horizontal, vertical }

class AxisPainter extends CustomPainter {
  final PlotMapper mapper;
  final Rect axisRect;
  final AxisOrientation orientation;
  final String label;
  final int ticks;

  AxisPainter({
    required this.mapper,
    required this.axisRect,
    required this.orientation,
    required this.label,
    this.ticks = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1;

    final textStyle = const TextStyle(
      fontSize: 9,
      color: Colors.black,
    );

    if (orientation == AxisOrientation.horizontal) {
      _drawXAxis(canvas, paint, textStyle);
    } else {
      _drawYAxis(canvas, paint, textStyle);
    }
  }

  void _drawXAxis(Canvas canvas, Paint paint, TextStyle style) {
    final min = mapper.xMin;
    final max = mapper.xMax;
    final step = (max - min) / (ticks - 1);

    for (int i = 0; i < ticks; i++) {
      final value = min + step * i;
      final x = mapper.map(value, mapper.yMin).dx;

      canvas.drawLine(
        Offset(x, axisRect.top),
        Offset(x, axisRect.top + 4),
        paint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: style,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(x - tp.width / 2, axisRect.top + 4),
      );
    }
  }

  void _drawYAxis(Canvas canvas, Paint paint, TextStyle style) {
    final min = mapper.yMin;
    final max = mapper.yMax;
    final step = (max - min) / (ticks - 1);

    for (int i = 0; i < ticks; i++) {
      final value = min + step * i;
      final y = mapper.map(mapper.xMin, value).dy;

      canvas.drawLine(
        Offset(axisRect.right - 4, y),
        Offset(axisRect.right, y),
        paint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: style,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(axisRect.right - tp.width - 6, y - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AxisPainter old) =>
      mapper != old.mapper;
}
