/// {@template pair_plot_style}
/// Конфигурация визуального стиля для парных диаграмм.
///
/// Определяет параметры отображения точек, прозрачности,
/// диагональных гистограмм и корреляции.
/// {@endtemplate}
class PairPlotStyle {
  /// Размер точки в диаграмме рассеяния.
  final double dotSize;

  /// Прозрачность точек.
  final double alpha;

  /// Показывать гистограммы на диагонали.
  final bool showHistDiagonal;

  /// Показывать коэффициент корреляции.
  final bool showCorrelation;

  /// Максимальное количество точек для отрисовки.
  final int maxPoints;

  /// Упрощённый режим (для больших матриц).
  final bool simplified;

  /// {@macro pair_plot_style}
  const PairPlotStyle({
    this.dotSize = 3.0,
    this.alpha = 0.6,
    this.showHistDiagonal = true,
    this.showCorrelation = true,
    this.maxPoints = 500,
    this.simplified = false,
  });
}
