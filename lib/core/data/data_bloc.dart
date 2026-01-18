import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../analysis/correlation_calculator.dart';
import '../analysis/data_analyzer.dart';
import 'data_event.dart';
import 'data_model.dart';
import 'data_state.dart';
import 'field_descriptor.dart';

/// {@template generic_bloc}
/// Базовый BLoC для работы с данными любого типа.
/// Обрабатывает загрузку, анализ и управление состоянием данных.
/// {@endtemplate}
abstract class GenericBloc<T extends DataModel> extends Bloc<DataEvent, DataState> {
  /// Источник данных для загрузки.
  final DataSource<T> dataSource;

  /// {@macro generic_bloc}
  GenericBloc({required this.dataSource}) : super(DataInitial()) {
    on<LoadDataEvent>(_onLoadData);
    on<AnalyzeDataEvent>(_onAnalyzeData);
    on<LoadAnalysisEvent>(_onLoadAnalysis);
  }

  /// Обработчик события загрузки данных.
  Future<void> _onLoadData(LoadDataEvent event, Emitter<DataState> emit) async {
    emit(DataLoading());
    try {
      final data = await dataSource.loadData();
      await _performInitialAnalysis(data, emit);
    } catch (e) {
      emit(DataError('Ошибка загрузки данных: $e'));
    }
  }

  /// Выполняет первичный анализ загруженных данных.
  Future<void> _performInitialAnalysis(List<T> data, Emitter<DataState> emit) async {
    DataAnalyzer.printHead(data);
    DataAnalyzer.countEmptyValues(data);
    DataAnalyzer.describe(data);

    final numericFields = _extractNumericFields(data);
    final correlationMatrix = CorrelationCalculator.calculateMatrix(data, numericFields);

    emit(DataLoaded<T>(
      data: data,
      numericFields: numericFields,
      correlationMatrix: correlationMatrix,
      metadata: {
        'totalRecords': data.length,
        'numericFieldsCount': numericFields.length,
        'analysisTimestamp': DateTime.now(),
        'dataSource': dataSource.dataTypeName,
      },
    ));
  }

  /// Обработчик события дополнительного анализа данных.
  Future<void> _onAnalyzeData(AnalyzeDataEvent event, Emitter<DataState> emit) async {
    final currentState = state;
    if (currentState is DataLoaded<T>) {
      final fieldsToAnalyze = event.fields.isNotEmpty ? event.fields : currentState.numericFields;
      final correlationMatrix = CorrelationCalculator.calculateMatrix(
        currentState.data, 
        fieldsToAnalyze as List<String>,
      );

      emit(currentState.copyWith(
        correlationMatrix: correlationMatrix,
        metadata: {
          ...currentState.metadata,
          'customAnalysisFields': fieldsToAnalyze,
          'analysisTimestamp': DateTime.now(),
        },
      ));
    }
  }

  /// Обработчик события загрузки внешнего анализа.
  Future<void> _onLoadAnalysis(LoadAnalysisEvent event, Emitter<DataState> emit) async {
    final currentState = state;
    if (currentState is DataLoaded<T>) {
      try {
        final analysisData = await loadAnalysisData();
        emit(currentState.copyWith(
          metadata: {
            ...currentState.metadata,
            'externalAnalysis': analysisData,
            'analysisLoadedAt': DateTime.now(),
          },
        ));
      } catch (e) {
        debugPrint('Error loading analysis: $e');
        emit(currentState.copyWith(
          metadata: {
            ...currentState.metadata,
            'analysisError': e.toString(),
          },
        ));
      }
    }
  }

  /// Извлекает числовые поля из данных через FieldDescriptor.
  List<FieldDescriptor> _extractNumericFields(List<T> data) {
    if (data.isEmpty) return [];
    return data.first.getNumericFieldsDescriptors();
  }

  /// Загружает дополнительные аналитические данные.
  Future<Map<String, dynamic>> loadAnalysisData() async {
    return {};
  }
}
