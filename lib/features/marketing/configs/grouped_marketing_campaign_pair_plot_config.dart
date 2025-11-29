import 'package:flutter/material.dart';

import '../../pair_plots/pair_plot_config.dart';
import '../../pair_plots/pair_plot_group.dart';
import '../data/marketing_campaign_model.dart';

class GroupedMarketingCampaignPairPlotConfig extends PairPlotConfig<MarketingCampaignDataModel> {
  final List<PairPlotFeature> _features = [
    PairPlotFeature('income', 'Доход', divisor: 1000.0),
    PairPlotFeature('mntWines', 'Расходы на вино', divisor: 100.0),
    PairPlotFeature('mntMeatProducts', 'Расходы на мясо', divisor: 100.0),
    PairPlotFeature('mntFruits', 'Расходы на фрукты', divisor: 10.0),
    PairPlotFeature('mntFishProducts', 'Расходы на рыбу', divisor: 10.0),
    PairPlotFeature('mntSweetProducts', 'Расходы на сладости', divisor: 10.0),
    PairPlotFeature('mntGoldProds', 'Расходы на золото', divisor: 10.0),
    PairPlotFeature('numWebPurchases', 'Онлайн покупки'),
    PairPlotFeature('numStorePurchases', 'Магазинные покупки'),
    PairPlotFeature('numCatalogPurchases', 'Покупки по каталогу'),
    PairPlotFeature('numDealsPurchases', 'Покупки со скидкой'),
    PairPlotFeature('numWebVisitsMonth', 'Посещения сайта'),
    PairPlotFeature('recency', 'Дней с покупки'),
    PairPlotFeature('yearBirth', 'Год рождения'),
  ];

  @override
  List<PairPlotFeature> get features => _features;

  // Группы для табов
  List<PairPlotGroup> get groups => [
    PairPlotGroup(
      title: 'Финансовые показатели',
      features: [
        PairPlotFeature('income', 'Доход', divisor: 1000.0),
        PairPlotFeature('mntWines', 'Расходы на вино', divisor: 100.0),
        PairPlotFeature('mntMeatProducts', 'Расходы на мясо', divisor: 100.0),
        PairPlotFeature('mntGoldProds', 'Расходы на золото', divisor: 10.0),
      ],
    ),
    PairPlotGroup(
      title: 'Поведенческие метрики',
      features: [
        PairPlotFeature('numWebPurchases', 'Онлайн покупки'),
        PairPlotFeature('numStorePurchases', 'Магазинные покупки'),
        PairPlotFeature('numCatalogPurchases', 'Покупки по каталогу'),
        PairPlotFeature('numDealsPurchases', 'Покупки со скидкой'),
        PairPlotFeature('numWebVisitsMonth', 'Посещения сайта'),
      ],
    ),
    PairPlotGroup(
      title: 'Потребительские привычки',
      features: [
        PairPlotFeature('mntFruits', 'Расходы на фрукты', divisor: 10.0),
        PairPlotFeature('mntFishProducts', 'Расходы на рыбу', divisor: 10.0),
        PairPlotFeature('mntSweetProducts', 'Расходы на сладости', divisor: 10.0),
        PairPlotFeature('recency', 'Дней с покупки'),
      ],
    ),
    PairPlotGroup(
      title: 'Демографические данные',
      features: [
        PairPlotFeature('yearBirth', 'Год рождения'),
        PairPlotFeature('income', 'Доход', divisor: 1000.0),
        PairPlotFeature('kidhome', 'Дети дома'),
        PairPlotFeature('teenhome', 'Подростки дома'),
      ],
    ),
  ];

  @override
  double? extractValue(MarketingCampaignDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    if (field == 'income') return '\$${value.toStringAsFixed(0)}k';
    if (field == 'mntWines' || field == 'mntMeatProducts') return '\$${(value * 100).toStringAsFixed(0)}';
    if (field == 'mntFruits' || field == 'mntFishProducts' || 
        field == 'mntSweetProducts' || field == 'mntGoldProds') {
      return '\$${(value * 10).toStringAsFixed(0)}';
    }
    if (field == 'yearBirth') return value.toStringAsFixed(0);
    return value.toStringAsFixed(0);
  }
  
  @override
  Color? getPointColor(MarketingCampaignDataModel data, String colorField) {
    // Окрашиваем точки по отклику на кампанию
    if (colorField == 'response') {
      return data.response == 1 ? Colors.green : Colors.orange;
    }
    // Окрашиваем по образованию
    if (colorField == 'education') {
      switch (data.education.toLowerCase()) {
        case 'graduation':
          return Colors.blue;
        case 'phd':
          return Colors.purple;
        case 'master':
          return Colors.green;
        case 'basic':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }
    // Окрашиваем по семейному положению
    if (colorField == 'maritalStatus') {
      switch (data.maritalStatus.toLowerCase()) {
        case 'married':
          return Colors.blue;
        case 'single':
          return Colors.green;
        case 'together':
          return Colors.orange;
        case 'divorced':
          return Colors.red;
        case 'widow':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }
    return Colors.blue; // Цвет по умолчанию
  }
}
