import '../../core/data/data_model.dart';

/// {@template box_plot_config}
/// Конфигурация для box plot (ящик с усами).
/// Определяет параметры для построения диаграмм размаха.
/// {@endtemplate}
abstract class BoxPlotConfig<T extends DataModel> {
  /// Список признаков для box plot.
  List<BoxPlotFeature> get features;

  /// Извлекает значение для поля из объекта данных.
  /// 
  /// Принимает:
  /// - [data] - объект данных,
  /// - [field] - имя поля для извлечения.
  /// 
  /// Возвращает:
  /// - [double?] числовое значение или null если значение недоступно.
  double? extractValue(T data, String field);

  /// Форматирует метку для оси Y.
  /// 
  /// Принимает:
  /// - [value] - числовое значение,
  /// - [field] - имя поля для контекста форматирования.
  /// 
  /// Возвращает:
  /// - [String] отформатированную строку значения.
  String formatValue(double value, String field);
}

/// {@template box_plot_feature}
/// Признак для box plot.
/// Определяет параметры одного признака для диаграммы размаха.
/// {@endtemplate}
class BoxPlotFeature {
  /// Заголовок признака для отображения.
  final String title;

  /// Поле в модели данных.
  final String field;

  /// Поле для группировки (опционально, напр. 'continent' для группировки по континентам).
  final String? groupBy;

  /// Делитель для значений (напр. 1e6 для миллионов).
  final double divisor;

  /// {@macro box_plot_feature}
  const BoxPlotFeature(
    this.title,
    this.field, {
    this.groupBy,
    this.divisor = 1.0,
  });
}