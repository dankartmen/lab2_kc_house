import 'dart:ui';

class PlotMapper {
  final Rect plotRect;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  const PlotMapper({
    required this.plotRect,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  Offset map(double x, double y) {
    final dx = (x - xMin) / (xMax - xMin);
    final dy = (y - yMin) / (yMax - yMin);

    return Offset(
      plotRect.left + dx * plotRect.width,
      plotRect.bottom - dy * plotRect.height, // инверсия Y
    );
  }

  Offset unmap(Offset screen) {
    final dx = (screen.dx - plotRect.left) / plotRect.width;
    final dy = (plotRect.bottom - screen.dy) / plotRect.height;

    return Offset(
      xMin + dx * (xMax - xMin),
      yMin + dy * (yMax - yMin),
    );
  }
}
