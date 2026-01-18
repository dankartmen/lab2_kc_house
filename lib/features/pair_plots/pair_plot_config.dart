import '../../core/data/data_model.dart';
import '../../core/data/field_descriptor.dart';

/// {@template pair_plot_config}
/// Базовая конфигурация для парных диаграмм (Pair Plot).
///
/// Определяет:
/// - какие поля отображаются
/// - какое поле используется для группировки (hue)
/// - цветовую палитру
/// {@endtemplate}
abstract class PairPlotConfig<T extends DataModel> {
  /// {@macro pair_plot_config}
  const PairPlotConfig();

  /// Поля, используемые для построения матрицы диаграмм.
  List<FieldDescriptor> get fields;

  /// Поле, используемое для цветовой группировки.
  ///
  /// Должно иметь тип [FieldType.categorical].
  FieldDescriptor? get hue;

  /// Цветовая палитра для группировки.
  ColorPalette? get palette;
}

/// Цветовые палитры для визуализации.
enum ColorPalette {
  /// Палитра по умолчанию.
  defaultPalette,

  /// Категориальная палитра.
  categorical,

  /// Последовательная палитра.
  sequential,

  /// Расходящаяся палитра.
  diverging,
}
