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

    final nums = rows
        .map((r) => r[numField.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();

    if (nums.isEmpty) return;

    final min = nums.reduce((a, b) => a < b ? a : b);
    final max = nums.reduce((a, b) => a > b ? a : b);

    for (var c = 0; c < categories.length; c++) {
      final cat = categories[c];
      final visible = rows.where((r) {
        final v = catField.parseCategory(r[catField.key]);
        final filter = controller.model.categoricalFilters[catField.key];
        return v == cat && (filter == null || filter.contains(cat));
      }).toList();

      for (final r in visible) {
        final v = r[numField.key];
        if (v is! num) continue;

        final norm = (v - min) / (max - min);

        final dx = isVertical
            ? plotRect.left +
                (c + 0.5) * plotRect.width / categories.length
            : plotRect.left + norm * plotRect.width;

        final dy = isVertical
            ? plotRect.bottom - norm * plotRect.height
            : plotRect.top +
                (c + 0.5) * plotRect.height / categories.length;

        paint.color = controller.model.hueField != null
            ? colorScale?.colorOf(
                  r[controller.model.hueField!]?.toString() ?? '',
                ) ??
                Colors.grey
            : Colors.blue;

        canvas.drawCircle(Offset(dx, dy), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StripPlotPainter old) =>
      old.rows != rows ||
      old.categories != categories ||
      old.plotRect != plotRect;
}
