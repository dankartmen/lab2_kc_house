import '../../histograms/histogram_config.dart';
import '../data/marketing_campaign_model.dart';

/// Конфигурация гистограмм для маркетингового датасета.
class MarketingHistogramConfig extends HistogramConfig<MarketingCampaignDataModel> {
  @override
  List<HistogramFeature> get features => [
        HistogramFeature('Доход', 'income', 1.0, '\$', binCount: 30),
        HistogramFeature('Год рождения', 'yearBirth', 1.0, 'год', binCount: 20),
        HistogramFeature('Дети дома', 'kidhome', 1.0, 'чел', binCount: 3),
        HistogramFeature('Подростки дома', 'teenhome', 1.0, 'чел', binCount: 3),
        HistogramFeature('Количество дней, прошедших с момента последней покупки клиента', 'recency', 1.0, 'дней', binCount: 10),
        HistogramFeature('Потрачено на вино за последние 2 года', 'mntWines', 1.0, '\$', binCount: 15),
        HistogramFeature('Потрачено на фрукты за последние 2 года', 'mntFruits', 1.0, '\$', binCount: 10),
        HistogramFeature('Потрачено на мясо за последние 2 года', 'mntMeatProducts', 1.0, '\$', binCount: 15),
        HistogramFeature('Потрачено на рыбу за последние 2 года', 'mntFishProducts', 1.0, '\$', binCount: 10),
        HistogramFeature('Потрачено на сладости за последние 2 года', 'mntSweetProducts', 1.0, '\$', binCount: 10),
        HistogramFeature('Потрачено на золото за последние 2 года', 'mntGoldProds', 1.0, '\$', binCount: 10),
        HistogramFeature('Покупки со скидкой', 'numDealsPurchases', 1.0, 'шт', binCount: 8),
        HistogramFeature('Онлайн покупки', 'numWebPurchases', 1.0, 'шт', binCount: 8),
        HistogramFeature('Покупки по каталогу', 'numCatalogPurchases', 1.0, 'шт', binCount: 8),
        HistogramFeature('Покупки в магазине', 'numStorePurchases', 1.0, 'шт', binCount: 8),
        HistogramFeature('Посещения сайта', 'numWebVisitsMonth', 1.0, 'раз', binCount: 10),
        HistogramFeature('Ответ на офер в ходе последней кампании', 'response', 1.0, '', binCount: 2),
      ];

  @override
  double? extractValue(MarketingCampaignDataModel data, String field) {
    return data.getNumericValue(field);
  }

  String formatValue(double value, String field) {
    // Специальное форматирование для разных типов полей
    switch (field) {
      case 'income':
      case 'mntWines':
      case 'mntMeatProducts':
        return '${(value / 1000).toStringAsFixed(0)}k\$';
      case 'mntFruits':
      case 'mntFishProducts':
      case 'mntSweetProducts':
      case 'mntGoldProds':
        return '\$${value.toInt()}';
      case 'yearBirth':
        return value.toInt().toString();
      case 'recency':
        return '${value.toInt()} дн.';
      case 'kidhome':
      case 'teenhome':
        return '${value.toInt()} чел.';
      default:
        return value.toInt().toString();
    }
  }
}