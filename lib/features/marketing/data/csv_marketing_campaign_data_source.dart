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
      final csvString = await rootBundle.loadString('assets/marketing_campaign_dataset.csv');
      
      // Парсинг CSV данных
      final csvData = const CsvToListConverter().convert(csvString, eol: '\n');

      // Пропускаем заголовок и преобразуем строки в MarketingCampaignDataModel
      final campaignData = csvData.skip(1).map((row) => MarketingCampaignDataModel.fromCsv(row)).toList();
      
      return campaignData;
    } catch (e) {
      throw Exception('Ошибка загрузки данных маркетинговой кампании: $e');
    }
  }

  @override
  String get dataTypeName => 'Данные маркетинговой кампании';
}