import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

import '../../../core/data/data_model.dart';
import 'heart_attack_data_model.dart';

/// {@template csv_heart_attack_data_source}
/// Источник данных для загрузки информации о рисках сердечных приступов из CSV файла.
/// {@endtemplate}
class CsvHeartAttackDataSource implements DataSource<HeartAttackDataModel> {
  /// {@macro csv_heart_attack_data_source}
  const CsvHeartAttackDataSource();

  @override
  Future<List<HeartAttackDataModel>> loadData() async {
    try {
      // Загрузка CSV из assets
      final csvString = await rootBundle.loadString('assets/heart_attack_prediction_dataset.csv');
      
      // Парсинг CSV данных
      final csvData = const CsvToListConverter().convert(csvString, eol: '\n');

      // Пропускаем заголовок и преобразуем строки в HeartAttackDataModel
      final heartData = csvData.skip(1).map((row) => HeartAttackDataModel.fromCsv(row)).toList();
      
      return heartData;
    } catch (e) {
      throw Exception('Ошибка загрузки данных о рисках сердечных приступов: $e');
    }
  }

  @override
  String get dataTypeName => 'Данные о рисках сердечных приступов';
}