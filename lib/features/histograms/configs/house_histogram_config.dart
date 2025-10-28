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
    final binEnd = binStart + binWidth;
    
    // Для целочисленных данных показываем целые диапазоны
    if (_isIntegerData(values)) {
      final start = binIndex == 0 ? binStart.floor() : binStart.ceil();
      final end = binIndex == totalBins - 1 ? binEnd.ceil() : binEnd.floor();
      return '$start-${end - 1}';
    }
    
    // Для дробных данных показываем с одним знаком после запятой
    return '${binStart.toStringAsFixed(1)}-${binEnd.toStringAsFixed(1)}';
  }
  
  bool _isIntegerData(List<double> values) {
    // Проверяем, являются ли значения целыми числами
    for (final value in values.take(100)) { // Проверяем первые 100 значений
      if (value % 1 != 0) return false;
    }
    return true;
  }
}