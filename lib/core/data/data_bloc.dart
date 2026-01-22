import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../analysis/correlation_calculator.dart';
import '../analysis/data_analyzer.dart';
import 'data_event.dart';
import 'data_model.dart';
import 'data_state.dart';
import '../../dataset/field_descriptor.dart';

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
  /// 
  /// Принимает:
  /// - [event] - событие загрузки данных,
  /// - [emit] - функция для emitting новых состояний.
  /// 
  /// Выполняет:
  /// - Загрузку данных из источника,
  /// - Первичный анализ данных,
  /// - Вычисление корреляций.
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
  /// 
  /// Принимает:
  /// - [data] - загруженные данные для анализа,
  /// - [emit] - функция для emitting новых состояний.
  /// 
  /// Выполняет:
  /// - Статистический анализ данных,
  /// - Вычисление матрицы корреляции,
  /// - Формирование метаданных.
  Future<void> _performInitialAnalysis(List<T> data, Emitter<DataState> emit) async {
    DataAnalyzer.printHead(data);
    DataAnalyzer.countEmptyValues(data);
    DataAnalyzer.describe(data);

    final numericFields = _extractNumericFields(data);
    // Получаем только ключи числовых полей для вычисления корреляции
    final numericFieldKeys = numericFields.map((fd) => fd.key).toList();
    final correlationMatrix = CorrelationCalculator.calculateMatrix(data, numericFieldKeys);

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
  ///
  /// Принимает:
  /// - [event] - событие анализа с указанием полей,
  /// - [emit] - функция для emitting новых состояний.
  /// 
  /// Выполняет:
  /// - Пересчет корреляций для указанных полей,
  /// - Обновление состояния с новыми результатами анализа.
  Future<void> _onAnalyzeData(AnalyzeDataEvent event, Emitter<DataState> emit) async {
    final currentState = state;
    if (currentState is DataLoaded<T>) {
      // Если переданы поля для анализа, используем их, иначе все числовые поля
      final fieldsToAnalyze = event.fields.isNotEmpty 
          ? event.fields 
          : currentState.numericFields.map((fd) => fd.key).toList();
      
      final correlationMatrix = CorrelationCalculator.calculateMatrix(
        currentState.data, 
        fieldsToAnalyze,
      );

      // Фильтруем FieldDescriptor для оставшихся числовых полей
      final updatedNumericFields = currentState.numericFields
          .where((descriptor) => fieldsToAnalyze.contains(descriptor.key))
          .toList();

      emit(currentState.copyWith(
        numericFields: updatedNumericFields,
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

  /// Извлекает числовые поля из данных.
  /// 
  /// Принимает:
  /// - [data] - данные для анализа.
  /// 
  /// Возвращает:
  /// - [List<FieldDescriptor>] список дескрипторов числовых полей.
  /// 
  /// Если данные пусты, возвращает пустой список.
  List<FieldDescriptor> _extractNumericFields(List<T> data) {
    if (data.isEmpty) return [];
    
    // Получаем дескрипторы полей из первого элемента данных
    final fieldDescriptors = data.first.fieldDescriptors;
    
    // Фильтруем числовые поля (непрерывные и бинарные)
    return fieldDescriptors
        .where((descriptor) => 
            descriptor.type == FieldType.continuous || 
            descriptor.type == FieldType.binary)
        .toList();
  }

  /// Загружает дополнительные аналитические данные.
  Future<Map<String, dynamic>> loadAnalysisData() async {
    return {};
  }
}