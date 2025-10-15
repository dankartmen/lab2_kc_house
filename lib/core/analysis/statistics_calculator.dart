import 'dart:math';

/// {@template descriptive_stats}
/// Контейнер для хранения описательной статистики данных.
/// Содержит основные статистические показатели для набора числовых значений.
/// {@endtemplate}
class DescriptiveStats {
  /// Количество значений в выборке.
  final int count;

  /// Среднее арифметическое значение.
  final double mean;

  /// Стандартное отклонение.
  final double std;

  /// Минимальное значение в выборке.
  final double min;

  /// Первый квартиль (25-й процентиль).
  final double q1;

  /// Медиана (50-й процентиль).
  final double median;

  /// Третий квартиль (75-й процентиль).
  final double q3;

  /// Максимальное значение в выборке.
  final double max;

  /// {@macro descriptive_stats}
  const DescriptiveStats({
    required this.count,
    required this.mean,
    required this.std,
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
  });

  @override
  String toString() {
    return 'DescriptiveStats(count: $count, mean: $mean, std: $std, '
           'min: $min, q1: $q1, median: $median, q3: $q3, max: $max)';
  }
}

/// {@template statistics_calculator}
/// Утилитарный класс для вычисления статистических показателей.
/// Предоставляет методы для расчета описательной статистики числовых данных.
/// {@endtemplate}
class StatisticsCalculator {
  /// {@macro statistics_calculator}
  const StatisticsCalculator._(); // Приватный конструктор - класс статический

  /// Вычисляет описательную статистику для набора числовых значений.
  /// 
  /// Принимает:
  /// - [values] - список числовых значений для анализа.
  /// 
  /// Возвращает:
  /// - [DescriptiveStats] объект с рассчитанной статистикой.
  /// 
  /// Выбрасывает исключение если [values] пуст.
  static DescriptiveStats calculateDescriptiveStats(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError('Values list cannot be empty');
    }
    
    values.sort();
    
    final count = values.length;
    final mean = values.reduce((a, b) => a + b) / count;
    final std = _calculateStd(values, mean);
    final min = values.first;
    final max = values.last;
    final q1 = _calculateQuantile(values, 0.25);
    final median = _calculateQuantile(values, 0.50);
    final q3 = _calculateQuantile(values, 0.75);
    
    return DescriptiveStats(
      count: count,
      mean: mean,
      std: std,
      min: min,
      q1: q1,
      median: median,
      q3: q3,
      max: max,
    );
  }

  /// Вычисляет стандартное отклонение для набора значений.
  /// 
  /// Принимает:
  /// - [values] - список значений,
  /// - [mean] - среднее значение выборки.
  /// 
  /// Возвращает:
  /// - [double] значение стандартного отклонения.
  static double _calculateStd(List<double> values, double mean) {
    final variance = values.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  /// Вычисляет квантиль для упорядоченного набора значений.
  /// 
  /// Принимает:
  /// - [values] - упорядоченный по возрастанию список значений,
  /// - [quantile] - значение квантиля от 0.0 до 1.0.
  /// 
  /// Возвращает:
  /// - [double] значение указанного квантиля.
  /// 
  /// Использует линейную интерполяцию между ближайшими значениями.
  static double _calculateQuantile(List<double> values, double quantile) {
    if (quantile <= 0) return values.first;
    if (quantile >= 1) return values.last;
    
    final position = (values.length - 1) * quantile;
    final lowerIndex = position.floor();
    final upperIndex = position.ceil();
    
    if (lowerIndex == upperIndex) {
      return values[lowerIndex];
    }
    
    // Линейная интерполяция между ближайшими значениями
    final weight = position - lowerIndex;
    return values[lowerIndex] * (1 - weight) + values[upperIndex] * weight;
  }
}