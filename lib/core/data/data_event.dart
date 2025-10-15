/// {@template data_event}
/// Базовое событие для управления данными в BLoC.
/// {@endtemplate}
abstract class DataEvent {
  /// {@macro data_event}
  const DataEvent();
}

/// {@template load_data_event}
/// Событие загрузки данных из источника.
/// {@endtemplate}
class LoadDataEvent extends DataEvent {
  /// Источник данных. Если null, используется источник по умолчанию.
  final String? source;

  /// {@macro load_data_event}
  const LoadDataEvent({this.source});
}

/// {@template analyze_data_event}
/// Событие анализа данных по указанным полям.
/// Используется для выполнения дополнительного анализа поверх загруженных данных.
/// {@endtemplate}
class AnalyzeDataEvent extends DataEvent {
  /// Список полей для анализа.
  /// Если пустой, анализируются все доступные числовые поля.
  final List<String> fields;

  /// {@macro analyze_data_event}
  const AnalyzeDataEvent({required this.fields});
}