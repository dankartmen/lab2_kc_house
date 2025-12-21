import '../../core/data/data_model.dart';

abstract class PairPlotConfig<T extends DataModel> {
  List<String> get numericFields;
  String? get hueField; // Для цветовой группировки
  ColorPalette? get palette; // Цветовая палитра для групп
}

class PairPlotFeature {
  final String field;
  final String title;
  final String? displayFormat;

  const PairPlotFeature({
    required this.field,
    required this.title,
    this.displayFormat,
  });
}

// Цветовые палитры для группировки
enum ColorPalette {
  defaultPalette, // синяя шкала
  categorical, // для категориальных данных
  sequential, // для последовательных данных
  diverging, // для расходящихся данных
}

// Конфигурация стилей для парных диаграмм
class PairPlotStyle {
  final double dotSize;
  final double alpha;
  final bool showHistDiagonal;
  final bool showKdeDiagonal;
  final bool showCorrelation;
  final int maxPoints;
  final bool simplified;

  const PairPlotStyle({
    this.dotSize = 2.0,
    this.alpha = 0.6,
    this.showHistDiagonal = true,
    this.showKdeDiagonal = false,
    this.showCorrelation = true,
    this.maxPoints = 500,
    this.simplified = false,
  });

  PairPlotStyle copyWith({
    double? dotSize,
    double? alpha,
    bool? showHistDiagonal,
    bool? showKdeDiagonal,
    bool? showCorrelation,
    int? maxPoints,
    bool? simplified,
  }) {
    return PairPlotStyle(
      dotSize: dotSize ?? this.dotSize,
      alpha: alpha ?? this.alpha,
      showHistDiagonal: showHistDiagonal ?? this.showHistDiagonal,
      showKdeDiagonal: showKdeDiagonal ?? this.showKdeDiagonal,
      showCorrelation: showCorrelation ?? this.showCorrelation,
      maxPoints: maxPoints ?? this.maxPoints,
      simplified: simplified ?? this.simplified,
    );
  }
}