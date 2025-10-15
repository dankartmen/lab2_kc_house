import 'dart:math';

import '../data/data_model.dart';

/// {@template correlation_calculator}
/// Утилитарный класс для вычисления корреляций между числовыми полями данных.
/// Предоставляет методы для расчета матрицы корреляции Пирсона.
/// {@endtemplate}
class CorrelationCalculator {
  /// {@macro correlation_calculator}
  const CorrelationCalculator._(); // Приватный конструктор - класс статический

  /// Вычисляет матрицу корреляции для указанных полей данных.
  /// 
  /// Принимает:
  /// - [data] - список объектов данных для анализа,
  /// - [fields] - список имен полей для включения в матрицу корреляции.
  /// 
  /// Возвращает:
  /// - [Map<String, Map<String, double>>] матрицу корреляции, где ключи внешнего 
  ///   Map - названия полей, а внутреннего - названия полей для корреляции.
  /// 
  /// Если данные пусты или поля не найдены, возвращает пустую матрицу.
  static Map<String, Map<String, double>> calculateMatrix<T extends DataModel>(
    List<T> data, 
    List<String> fields
  ) {
    if (data.isEmpty || fields.isEmpty) {
      return {};
    }

    final matrix = <String, Map<String, double>>{};

    // Инициализация матрицы
    for (final field1 in fields) {
      matrix[field1] = {};
      for (final field2 in fields) {
        matrix[field1]![field2] = 0.0;
      }
    }

    // Вычисление корреляций для всех пар полей
    for (final field1 in fields) {
      for (final field2 in fields) {
        final correlation = _calculateFieldCorrelation(data, field1, field2);
        matrix[field1]![field2] = correlation;
      }
    }

    return matrix;
  }

  /// Вычисляет корреляцию Пирсона между двумя полями данных.
  /// 
  /// Принимает:
  /// - [data] - данные для анализа,
  /// - [field1] - имя первого поля,
  /// - [field2] - имя второго поля.
  /// 
  /// Возвращает:
  /// - [double] коэффициент корреляции Пирсона в диапазоне от -1.0 до 1.0.
  /// 
  /// Возвращает 0.0 если недостаточно данных для расчета или произошла ошибка.
  static double _calculateFieldCorrelation<T extends DataModel>(
    List<T> data, 
    String field1, 
    String field2
  ) {
    final List<double> values1 = [];
    final List<double> values2 = [];

    // Сбор пар значений для анализа
    for (final item in data) {
      final value1 = item.getNumericValue(field1);
      final value2 = item.getNumericValue(field2);
      
      if (value1 != null && value2 != null && value1.isFinite && value2.isFinite) {
        values1.add(value1);
        values2.add(value2);
      }
    }

    if (values1.length < 2) {
      // Недостаточно данных для расчета корреляции
      return 0.0;
    }

    return _calculatePearsonCorrelation(values1, values2);
  }

  /// Вычисляет коэффициент корреляции Пирсона между двумя наборами значений.
  /// 
  /// Принимает:
  /// - [x] - первый набор значений,
  /// - [y] - второй набор значений.
  /// 
  /// Возвращает:
  /// - [double] коэффициент корреляции Пирсона.
  /// 
  /// Формула: cov(X,Y) / (std(X) * std(Y))
  static double _calculatePearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length) {
      throw ArgumentError('Arrays must have the same length');
    }

    final n = x.length;
    double sumX = 0.0, sumY = 0.0, sumXY = 0.0;
    double sumX2 = 0.0, sumY2 = 0.0;

    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }

    final numerator = n * sumXY - sumX * sumY;
    final denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));

    if (denominator == 0) return 0.0;
    
    return numerator / denominator;
  }
}