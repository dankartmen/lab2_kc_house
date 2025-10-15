import 'data_model.dart';

/// {@template data_state}
/// Базовое состояние для управления состоянием данных в BLoC.
/// {@endtemplate}
abstract class DataState {
  /// {@macro data_state}
  const DataState();
}

/// {@template data_initial}
/// Начальное состояние данных перед загрузкой.
/// {@endtemplate}
class DataInitial extends DataState {
  /// {@macro data_initial}
  const DataInitial();
}

/// {@template data_loading}
/// Состояние загрузки данных.
/// Используется для отображения индикатора загрузки.
/// {@endtemplate}
class DataLoading extends DataState {
  /// {@macro data_loading}
  const DataLoading();
}

/// {@template data_loaded}
/// Состояние успешно загруженных данных.
/// Содержит данные и результаты их анализа.
/// {@endtemplate}
class DataLoaded<T extends DataModel> extends DataState {
  /// Загруженные данные.
  final List<T> data;

  /// Список числовых полей в данных.
  final List<String> numericFields;

  /// Матрица корреляции между числовыми полями.
  final Map<String, Map<String, double>> correlationMatrix;

  /// Дополнительные метаданные анализа.
  final Map<String, dynamic> metadata;

  /// {@macro data_loaded}
  const DataLoaded({
    required this.data,
    required this.numericFields,
    required this.correlationMatrix,
    this.metadata = const {},
  });

  /// Создает копию объекта с обновленными полями.
  /// 
  /// Принимает:
  /// - [data] - новые данные (опционально),
  /// - [numericFields] - новые числовые поля (опционально),
  /// - [correlationMatrix] - новая матрица корреляции (опционально),
  /// - [metadata] - новые метаданные (опционально).
  /// 
  /// Возвращает:
  /// - [DataLoaded<T>] новый объект с обновленными полями.
  DataLoaded<T> copyWith({
    List<T>? data,
    List<String>? numericFields,
    Map<String, Map<String, double>>? correlationMatrix,
    Map<String, dynamic>? metadata,
  }) {
    return DataLoaded<T>(
      data: data ?? this.data,
      numericFields: numericFields ?? this.numericFields,
      correlationMatrix: correlationMatrix ?? this.correlationMatrix,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataLoaded<T> &&
        other.data == data &&
        other.numericFields == numericFields &&
        other.correlationMatrix == correlationMatrix &&
        other.metadata == metadata;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      numericFields.hashCode ^
      correlationMatrix.hashCode ^
      metadata.hashCode;
}

/// {@template data_error}
/// Состояние ошибки при работе с данными.
/// Содержит сообщение об ошибке для отображения пользователю.
/// {@endtemplate}
class DataError extends DataState {
  /// Сообщение об ошибке.
  final String message;

  /// {@macro data_error}
  const DataError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}