import '../../box_plots/box_plot_config.dart';
import '../data/marketing_campaign_model.dart';

/// Конфигурация box plots для датасета маркетинговой кампании.
class MarketingCampaignBoxPlotConfig extends BoxPlotConfig<MarketingCampaignDataModel> {
  @override
  List<BoxPlotFeature> get features => [
        BoxPlotFeature('Доход по образованию', 'income', groupBy: 'education', divisor: 1000.0),
        BoxPlotFeature('Расходы на вино по семейному статусу', 'mntWines', groupBy: 'maritalStatus', divisor: 100.0),
        BoxPlotFeature('Онлайн покупки', 'numWebPurchases', divisor: 1.0),
      ];

  @override
  double? extractValue(MarketingCampaignDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    if (field == 'income') return '\$${value.toStringAsFixed(0)}k';
    if (field == 'mntWines') return '\$${value.toStringAsFixed(0)}';
    return value.toStringAsFixed(0);
  }
}