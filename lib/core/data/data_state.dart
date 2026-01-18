import '../../features/credit_card/data/fraud_analysis_model.dart';
import 'data_model.dart';
import 'field_descriptor.dart';

/// {@template data_state}
/// Базовое состояние для управления состоянием данных в BLoC.
/// {@endtemplate}
abstract class DataState {
  const DataState();
}

/// {@template data_initial}
/// Начальное состояние данных перед загрузкой.
/// {@endtemplate}
class DataInitial extends DataState {
  const DataInitial();
}

/// {@template data_loading}
/// Состояние загрузки данных.
/// {@endtemplate}
class DataLoading extends DataState {
  const DataLoading();
}

/// {@template data_loaded}
/// Состояние успешно загруженных данных.
/// {@endtemplate}
class DataLoaded<T extends DataModel> extends DataState {
  final List<T> data;

  /// Список числовых полей (FieldDescriptor).
  final List<FieldDescriptor> numericFields;

  final Map<String, Map<String, double>> correlationMatrix;

  final Map<String, dynamic> metadata;

  final FraudAnalysisModel? fraudAnalysis;

  const DataLoaded({
    required this.data,
    required this.numericFields,
    required this.correlationMatrix,
    this.metadata = const {},
    this.fraudAnalysis,
  });

  DataLoaded<T> copyWith({
    List<T>? data,
    List<FieldDescriptor>? numericFields,
    Map<String, Map<String, double>>? correlationMatrix,
    Map<String, dynamic>? metadata,
    FraudAnalysisModel? fraudAnalysis,
  }) {
    return DataLoaded<T>(
      data: data ?? this.data,
      numericFields: numericFields ?? this.numericFields,
      correlationMatrix: correlationMatrix ?? this.correlationMatrix,
      metadata: metadata ?? this.metadata,
      fraudAnalysis: fraudAnalysis ?? this.fraudAnalysis,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataLoaded<T> &&
        other.data == data &&
        other.numericFields == numericFields &&
        other.correlationMatrix == correlationMatrix &&
        other.metadata == metadata &&
        other.fraudAnalysis == fraudAnalysis;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      numericFields.hashCode ^
      correlationMatrix.hashCode ^
      metadata.hashCode ^
      fraudAnalysis.hashCode;
}

/// {@template data_error}
/// Состояние ошибки при работе с данными.
/// {@endtemplate}
class DataError extends DataState {
  final String message;

  const DataError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
