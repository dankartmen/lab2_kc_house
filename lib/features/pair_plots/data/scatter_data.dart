import 'dart:ui';

class ScatterPoint {
  final double x;
  final double y;
  final int rowIndex;
  final String? category;
  final Color color;

  const ScatterPoint({
    required this.x,
    required this.y,
    required this.rowIndex,
    this.category,
    required this.color,
  });
}

class ScatterData {
  final List<ScatterPoint> points;
  final double? correlation;

  const ScatterData({
    required this.points,
    this.correlation,
  });
}

