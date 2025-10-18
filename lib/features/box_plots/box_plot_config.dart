import '../../../core/data/data_model.dart';

/// Конфигурация для box plot (ящик с усами).
abstract class BoxPlotConfig<T extends DataModel> {
  /// Список признаков для box plot.
  List<BoxPlotFeature> get features;

  /// Извлекает значение для поля (аналогично HistogramConfig).
  double? extractValue(T data, String field);

  /// Форматирует метку для оси Y (опционально, для единиц измерения).
  String formatValue(double value, String field);
}

/// Признак для box plot.
class BoxPlotFeature {
  /// Заголовок признака.
  final String title;
  /// Поле в модели данных.
  final String field;
  /// Поле для группировки (опционально, напр. 'continent' для группировки по континентам).
  final String? groupBy;
  /// Делитель для значений (напр. 1e6 для миллионов).
  final double divisor;

  const BoxPlotFeature(
    this.title,
    this.field, {
    this.groupBy,
    this.divisor = 1.0,
  });
}