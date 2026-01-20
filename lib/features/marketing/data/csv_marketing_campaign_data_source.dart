import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../../../core/data/data_model.dart';
import 'marketing_campaign_model.dart';

/// {@template csv_marketing_campaign_data_source}
/// Источник данных для загрузки информации о маркетинговой кампании из CSV файла.
/// {@endtemplate}
class CsvMarketingCampaignDataSource implements DataSource<MarketingCampaignDataModel> {
  /// {@macro csv_marketing_campaign_data_source}
  const CsvMarketingCampaignDataSource();

  @override
  Future<List<MarketingCampaignDataModel>> loadData() async {
    try {
      // Загрузка CSV из assets
      final csvString = await rootBundle.loadString('assets/marketing_campaign.csv');
      
      final processedCsvString = _preprocessCsv(csvString);

      // Парсинг CSV данных
      final csvData = const CsvToListConverter(
        fieldDelimiter: '\t',
        shouldParseNumbers: false, 
      ).convert(processedCsvString, eol: '\n');

      final headers = csvData.first.map((e) => e.toString()).toList();

      return csvData.skip(1).map((row) {
        final map = Map<String, dynamic>.fromIterables(headers, row);
        return MarketingCampaignDataModel.fromMap(map);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки данных маркетинговой кампании: $e');
    }
  }

  /// Предварительная обработка CSV строки
  String _preprocessCsv(String csvString) {
    //Замена двойных пробелов на табы
    return csvString.replaceAll('  ', '\t');
  }

  @override
  String get dataTypeName => 'Данные маркетинговой кампании';
}