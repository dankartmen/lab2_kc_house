import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../../../core/data/data_model.dart';
import 'population_model.dart';

/// {@template population_data_source}
/// Источник данных для загрузки информации о населении стран.
/// Загружает данные из CSV файла в assets приложения.
/// {@endtemplate}
class PopulationDataSource implements DataSource<PopulationData> {
  /// {@macro population_data_source}
  const PopulationDataSource();

  @override
  Future<List<PopulationData>> loadData() async {
    try {
      // Загрузка CSV из assets
      final csvString = await rootBundle.loadString('assets/world_population.csv');
      
      // Парсинг CSV данных
      final csvData = const CsvToListConverter().convert(csvString, eol: '\n');

      final headers = csvData.first.map((e) => e.toString()).toList();

      return csvData.skip(1).map((row) {
        final map = Map<String, dynamic>.fromIterables(headers, row);
        return PopulationData.fromMap(map);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки данных о населении: $e');
    }
  }

  @override
  String get dataTypeName => 'Данные о населении стран';
}