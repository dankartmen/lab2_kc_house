import '../../core/data/data_model.dart';

abstract class HistogramConfig<T extends DataModel> {
  List<HistogramFeature> get features;
  double? extractValue(T data, String field);
}

class HistogramFeature {
  final String title;
  final String field;
  final double divisor;
  final String unit;
  final int binCount; // Добавили количество бинов
  final String? displayFormat;

  const HistogramFeature(
    this.title,
    this.field,
    this.divisor,
    this.unit, {
    this.binCount = 10, // Значение по умолчанию
    this.displayFormat,
  });
}