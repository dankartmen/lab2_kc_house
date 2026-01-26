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

  /// Создает копию точки с обновленными полями
  ScatterPoint copyWith({
    double? x,
    double? y,
    int? rowIndex,
    String? category,
    Color? color,
  }) {
    return ScatterPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      rowIndex: rowIndex ?? this.rowIndex,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}

class ScatterData {
  final List<ScatterPoint> points;
  final double? correlation;

  const ScatterData({
    required this.points,
    this.correlation,
  });

  ScatterData copyMapped(double Function(double) f) {
    return ScatterData(
      points: points
          .map(
            (p) => p.copyWith(
              x: f(p.x),
              y: f(p.y),
            ),
          )
          .toList(),
      correlation: correlation,
    );
  }
}


