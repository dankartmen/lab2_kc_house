import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

import '../../../core/data/data_model.dart';
import 'diabetes_risk_prediction_data_model.dart';

/// {@template csv_diabetes_data_source}
/// Источник данных для загрузки информации о рисках диабета из CSV файла.
/// {@endtemplate}
class CsvDiabetesDataSource implements DataSource<DiabetesRiskPredictionDataModel> {
  /// {@macro csv_diabetes_data_source}
  const CsvDiabetesDataSource();

  @override
  Future<List<DiabetesRiskPredictionDataModel>> loadData() async {
    try {
      // Загрузка CSV из assets
      final csvString = await rootBundle.loadString('assets/diabetes_data_upload.csv');
      
      // Парсинг CSV данных с запятой как разделителем
      final csvData = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
      ).convert(csvString);

      final headers = csvData.first.map((e) => e.toString()).toList();

      return csvData.skip(1).map((row) {
        final map = Map<String, dynamic>.fromIterables(headers, row);
        return DiabetesRiskPredictionDataModel.fromMap(map);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки данных о рисках диабета: $e');
    }
  }

  @override
  String get dataTypeName => 'Данные о рисках диабета';
}

