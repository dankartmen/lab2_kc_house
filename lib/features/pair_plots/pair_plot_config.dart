import '../../core/data/data_model.dart';

/// {@template pair_plot_config}
/// Конфигурация для парных диаграмм (scatter plots).
/// Определяет пары полей для визуализации корреляций.
/// {@endtemplate}
abstract class PairPlotConfig<T extends DataModel> {
  /// Список пар признаков для scatter plots.
  List<PairPlotFeature> get features;

  /// Извлекает значение для поля из объекта данных.
  /// 
  /// Принимает:
  /// - [data] - объект данных,
  /// - [field] - имя поля для извлечения.
  /// 
  /// Возвращает:
  /// - [double?] числовое значение или null если значение недоступно.
  double? extractValue(T data, String field);

  /// Форматирует метку для осей.
  /// 
  /// Принимает:
  /// - [value] - числовое значение,
  /// - [field] - имя поля для контекста форматирования.
  /// 
  /// Возвращает:
  /// - [String] отформатированную строку значения.
  String formatValue(double value, String field);
}

/// {@template pair_plot_feature}
/// Пара признаков для scatter plot.
/// Определяет параметры одной пары для диаграммы рассеяния.
/// {@endtemplate}
class PairPlotFeature {
  /// Заголовок пары для отображения.
  final String title;

  /// Поле для оси X.
  final String fieldX;

  /// Поле для оси Y.
  final String fieldY;

  /// Делитель для значений X (напр. 1e6 для миллионов).
  final double divisorX;

  /// Делитель для значений Y.
  final double divisorY;

  /// {@macro pair_plot_feature}
  const PairPlotFeature(
    this.title,
    this.fieldX,
    this.fieldY, {
    this.divisorX = 1.0,
    this.divisorY = 1.0,
  });
}