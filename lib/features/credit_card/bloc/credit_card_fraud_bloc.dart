import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../core/data/data_state.dart';
import '../data/csv_credit_card_fraud_data_source.dart';
import '../data/credit_card_fraud_data_model.dart';
import '../data/fraud_analysis_model.dart';  // Импорт модели анализа

import '../../../core/data/data_bloc.dart';
import '../../../core/data/data_event.dart';  // Для LoadFraudAnalysisEvent

/// {@template credit_card_fraud_bloc}
/// BLoC для управления данными о мошенничестве с кредитными картами.
/// {@endtemplate}
class CreditCardFraudBloc extends GenericBloc<CreditCardFraudDataModel> {
  /// {@macro credit_card_fraud_bloc}
  CreditCardFraudBloc() : super(dataSource: const CsvCreditCardFraudDataSource()) {
    // Добавляем обработку события для загрузки fraud-анализа
    on<LoadFraudAnalysisEvent>(_onLoadFraudAnalysis);
  }

  /// Обработчик события загрузки анализа мошенничества с сервера.
  Future<void> _onLoadFraudAnalysis(
    LoadFraudAnalysisEvent event,
    Emitter<DataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DataLoaded<CreditCardFraudDataModel>) {
      emit(DataError('Сначала загрузите основные данные'));
      return;
    }

    try {
      // Задержка для симуляции (как в оригинале)
      await Future.delayed(const Duration(seconds: 2));

      final response = await http.get(Uri.parse('http://195.225.111.85:8000/api/fraud-analysis'));
      if (response.statusCode != 200) {
        throw Exception('Сервер вернул ${response.statusCode}');
      }
      final analysis = FraudAnalysisModel.fromJson(json.decode(response.body));

      // Обновляем состояние с анализом
      emit(currentState.copyWith(fraudAnalysis: analysis));
    } catch (e) {
      emit(DataError('Ошибка загрузки анализа мошенничества: $e'));
    }
  }
}