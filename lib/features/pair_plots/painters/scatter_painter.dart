import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/utils/plot_mapper.dart';
import '../data/scatter_data.dart';

/// Отрисовщик диаграммы рассеяния.
class ScatterPainter extends CustomPainter {
  final ScatterData data;
  final PlotMapper mapper;
  final double dotSize;
  final bool showCorrelation;
  final double alpha;
  final int? hoveredIndex;
  final Set<String> activeCategories;

  ScatterPainter({
    required this.data,
    required this.mapper,
    required this.dotSize,
    required this.showCorrelation,
    required this.alpha,
    this.hoveredIndex,
    this.activeCategories = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in data.points) {
      final isHovered = hoveredIndex == p.rowIndex;
      final isActive = activeCategories.isEmpty ||
          (p.category != null &&
              activeCategories.contains(p.category));

      final a = isHovered
          ? 1.0
          : isActive
              ? alpha
              : 0.1;

      final paint = Paint()
        ..color = p.color.withAlpha((a * 255).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        mapper.map(p.x, p.y),
        dotSize,
        paint,
      );
    }

    if (showCorrelation && data.correlation != null) {
      _drawCorrelation(canvas);
    }
  }

  void _drawCorrelation(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'r = ${data.correlation!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, const Offset(4, 4));
  }

  @override
  bool shouldRepaint(covariant ScatterPainter old) =>
      old.data != data ||
      old.hoveredIndex != hoveredIndex ||
      old.activeCategories != activeCategories;
}
