import 'package:flutter/material.dart';
import '../../../dataset/field_descriptor.dart';
import '../pair_plot_controller.dart';
import '../scales/categorical_color_scale.dart';

class StripPlotPainter extends CustomPainter {
  final List<Map<String, dynamic>> rows;
  final FieldDescriptor catField;
  final FieldDescriptor numField;
  final List<String> categories;
  final Rect plotRect;
  final CategoricalColorScale? colorScale;
  final bool isVertical;
  final PairPlotController controller;

  StripPlotPainter({
    required this.rows,
    required this.catField,
    required this.numField,
    required this.categories,
    required this.plotRect,
    required this.colorScale,
    required this.isVertical,
    required this.controller,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final min = rows
        .map((r) => r[numField.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .reduce(minFunc);

    final max = rows
        .map((r) => r[numField.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .reduce(maxFunc);

    for (var c = 0; c < categories.length; c++) {
      final cat = categories[c];
      final visible = rows.where((r) {
        final catVal = catField.parseCategory(r[catField.key]);
        return catVal == cat &&
            controller.model.isCategoryActive(
              catField.key,
              cat,
            );
      }).toList();

      if (visible.isEmpty) continue;

      final jitters =
          controller.getJitters(visible.length, c * 31);

      for (var i = 0; i < visible.length; i++) {
        final r = visible[i];
        final v = r[numField.key];
        if (v is! num) continue;

        final norm = (v - min) / (max - min);
        final jitter = jitters[i];

        final dx = isVertical
            ? plotRect.left +
                (c + 0.5 + jitter) *
                    plotRect.width /
                    categories.length
            : plotRect.left + norm * plotRect.width;

        final dy = isVertical
            ? plotRect.bottom - norm * plotRect.height
            : plotRect.top +
                (c + 0.5 + jitter) *
                    plotRect.height /
                    categories.length;

        final color = controller.model.hueField != null
            ? colorScale?.colorOf(
                  r[controller.model.hueField!]
                      ?.toString() ??
                      '',
                ) ??
                Colors.grey
            : Colors.blue;

        paint.color = color.withValues(alpha: 0.7);
        canvas.drawCircle(Offset(dx, dy), 3, paint);
      }
    }
  }

  double minFunc(double a, double b) => a < b ? a : b;
  double maxFunc(double a, double b) => a > b ? a : b;

  @override
  bool shouldRepaint(covariant StripPlotPainter old) =>
      old.rows != rows ||
      old.categories != categories ||
      old.plotRect != plotRect;
}
