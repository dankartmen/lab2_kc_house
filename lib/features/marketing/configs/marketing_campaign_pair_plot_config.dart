import 'package:flutter/material.dart';

import '../../pair_plots/pair_plot_config.dart';
import '../data/marketing_campaign_model.dart';
import 'grouped_marketing_campaign_pair_plot_config.dart';

class MarketingCampaignPairPlotConfig extends GroupedMarketingCampaignPairPlotConfig {
  @override
  List<PairPlotFeature> get features => [
    PairPlotFeature('income', 'Доход', divisor: 1000.0),
    PairPlotFeature('mntWines', 'Вино', divisor: 100.0),
    PairPlotFeature('mntMeatProducts', 'Мясо', divisor: 100.0),
    PairPlotFeature('numWebPurchases', 'Онлайн покупки'),
    PairPlotFeature('numStorePurchases', 'Магазинные покупки'),
    PairPlotFeature('recency', 'Дней с покупки'),
  ];

  @override
  double? extractValue(MarketingCampaignDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    if (field == 'income') return '\$${value.toStringAsFixed(0)}k';
    if (field == 'mntWines' || field == 'mntMeatProducts') return '\$${value.toStringAsFixed(0)}';
    return value.toStringAsFixed(0);
  }
  
  @override
  Color? getPointColor(MarketingCampaignDataModel data, String colorField) {
    // Окрашиваем точки по ответу на кампанию
    if (colorField == 'response') {
      return data.response == 1 ? Colors.green : Colors.orange;
    }
    return null;
  }
}