import '../../house/data/house_data_model.dart';
import '../box_plot_config.dart';

/// {@template house_box_plot_config}
/// Конфигурация box plot для данных о недвижимости.
/// Определяет параметры для построения диаграмм размаха характеристик домов.
/// {@endtemplate}
class HouseBoxPlotConfig implements BoxPlotConfig<HouseDataModel> {
  @override
  List<BoxPlotFeature> get features => [
    BoxPlotFeature('Цена', 'price', divisor: 1e3),  // тыс. $
    BoxPlotFeature('Площадь', 'sqft_living', divisor: 1, groupBy: 'zipcode'),  // Группировка по zipcode (почтовым кодам)
    BoxPlotFeature("Спальни", 'bedrooms'),
    BoxPlotFeature('Вынные', 'bathrooms')
  ];

  @override
  double? extractValue(HouseDataModel data, String field) => data.getNumericValue(field);

  @override
  String formatValue(double value, String field) {
    switch(field){
      case 'price': return '${value.toInt()} тыс.';
      case 'sqft_living': return '${value.toInt()} кв. фут';
      default: return '${value.toInt()}';
    }
  }
}