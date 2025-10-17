import '../../house/data/house_data_model.dart';
import '../histogram_config.dart';

/// {@template house_histogram_config}
/// Конфигурация гистограмм для данных о недвижимости
/// {@endtemplate}
class HouseHistogramConfig implements HistogramConfig<HouseDataModel> {
  @override
  List<HistogramFeature> get features => [
    HistogramFeature('Цена', 'price', 1e3, 'тыс. \$'),
    HistogramFeature('Жилая площадь', 'sqft_living', 1, 'кв.фут'),
    HistogramFeature('Участок', 'sqft_lot', 1e3, 'тыс. кв.фут'),
    HistogramFeature('Спальни', 'bedrooms', 1, ''),
    HistogramFeature('Ванные', 'bathrooms', 1, ''),
    HistogramFeature('Этажи', 'floors', 1, ''),
    HistogramFeature('Оценка', 'grade', 1, ''),
    HistogramFeature('Год постройки', 'yr_built', 1, 'год'),
  ];

  @override
  double? extractValue(HouseDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatBinLabel(int binIndex, int totalBins, List<double> values) {
    if (values.isEmpty) return '';
    
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final binWidth = (maxVal - minVal) / totalBins;
    final binStart = minVal + binIndex * binWidth;
    
    return '${binStart.toInt()}';
  }
}