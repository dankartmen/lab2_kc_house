import '../../histograms/histogram_config.dart';
import '../data/marketing_campaign_model.dart';

/// Конфигурация гистограмм для датасета маркетинговой кампании.
class MarketingCampaignHistogramConfig extends HistogramConfig<MarketingCampaignDataModel> {
  @override
  List<HistogramFeature> get features => [
        HistogramFeature('Доход', 'income', 1000.0, '\$'),
        HistogramFeature('Расходы на вино', 'mntWines', 100.0, '\$'),
        HistogramFeature('Расходы на мясо', 'mntMeatProducts', 100.0, '\$'),
        HistogramFeature('Онлайн покупки', 'numWebPurchases', 1.0, 'шт'),
        HistogramFeature('Дней с покупки', 'recency', 1.0, 'дней'),
        HistogramFeature('Возраст', 'yearBirth', 1.0, 'год')
      ];

  @override
  double? extractValue(MarketingCampaignDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatBinLabel(int binIndex, int totalBins, List<double> values ,) {
    if (values.isEmpty) return '';
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final binWidth = (max - min) / totalBins;

    final start = (min + binIndex * binWidth).toInt();
    final end = (min + (binIndex + 1) * binWidth).toInt();
    return '$start–$end';
  }
}