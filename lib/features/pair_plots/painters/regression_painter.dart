import 'package:flutter/material.dart';
import '../utils/plot_mapper.dart';
import '../data/scatter_data.dart';

/// Отрисовка линейной регрессии y = ax + b
class RegressionPainter extends CustomPainter {
  final ScatterData data;
  final PlotMapper mapper;

  RegressionPainter({
    required this.data,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.points.length < 2) return;

    // Метод наименьших квадратов
    final xs = data.points.map((p) => p.x).toList();
    final ys = data.points.map((p) => p.y).toList();

    final n = xs.length;
    final meanX = xs.reduce((a, b) => a + b) / n;
    final meanY = ys.reduce((a, b) => a + b) / n;

    double num = 0;
    double den = 0;

    for (int i = 0; i < n; i++) {
      num += (xs[i] - meanX) * (ys[i] - meanY);
      den += (xs[i] - meanX) * (xs[i] - meanX);
    }

    if (den == 0) return;

    final a = num / den;
    final b = meanY - a * meanX;

    final x1 = mapper.xMin;
    final x2 = mapper.xMax;

    final p1 = mapper.map(x1, a * x1 + b);
    final p2 = mapper.map(x2, a * x2 + b);

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..strokeWidth = 1.5;

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant RegressionPainter old) => true;
}
