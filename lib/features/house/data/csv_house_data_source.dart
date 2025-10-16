import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

import '../../../core/data/data_model.dart';
import 'house_data_model.dart';

/// {@template csv_house_data_source}
/// Источник данных для загрузки информации о недвижимости из CSV файла.
/// Загружает данные из CSV файла в assets приложения.
/// {@endtemplate}
class CsvHouseDataSource implements DataSource<HouseDataModel> {
  /// {@macro csv_house_data_source}
  const CsvHouseDataSource();

  @override
  Future<List<HouseDataModel>> loadData() async {
    try {
      // Загрузка CSV из assets
      final csvString = await rootBundle.loadString('assets/kc_house_data.csv');
      
      // Парсинг CSV данных
      final csvData = const CsvToListConverter().convert(csvString, eol: '\n');

      // Пропускаем заголовок и преобразуем строки в HouseDataModel
      final houseData = csvData.skip(1).map((row) => HouseDataModel.fromCsv(row)).toList();
      
      return houseData;
    } catch (e) {
      throw Exception('Ошибка загрузки данных о недвижимости: $e');
    }
  }

  @override
  String get dataTypeName => 'Данные о недвижимости';
}