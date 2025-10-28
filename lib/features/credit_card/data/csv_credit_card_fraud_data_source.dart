import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

import '../../../core/data/data_model.dart';
import 'credit_card_fraud_data_model.dart';

/// {@template csv_credit_card_fraud_data_source}
/// Источник данных для загрузки информации о мошенничестве с кредитными картами из CSV файла.
/// {@endtemplate}
class CsvCreditCardFraudDataSource implements DataSource<CreditCardFraudDataModel> {
  /// {@macro csv_credit_card_fraud_data_source}
  const CsvCreditCardFraudDataSource();

  @override
  Future<List<CreditCardFraudDataModel>> loadData() async {
    try {
      // Загрузка CSV из assets
      final csvString = await rootBundle.loadString('assets/creditcard.csv');
      
      // Парсинг CSV данных
      final csvData = const CsvToListConverter().convert(csvString, eol: '\n');

      // Пропускаем заголовок и преобразуем строки в CreditCardFraudDataModel
      final fraudData = csvData.skip(1).map((row) => CreditCardFraudDataModel.fromCsv(row)).toList();
      
      return fraudData;
    } catch (e) {
      throw Exception('Ошибка загрузки данных о мошенничестве: $e');
    }
  }

  @override
  String get dataTypeName => 'Данные о мошенничестве с кредитными картами';
}