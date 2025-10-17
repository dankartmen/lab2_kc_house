import '../../population/data/population_model.dart';
import '../histogram_config.dart';

/// {@template population_histogram_config}
/// Конфигурация гистограмм для данных о населении
/// {@endtemplate}
class PopulationHistogramConfig implements HistogramConfig<PopulationData> {
  @override
  List<HistogramFeature> get features => [
    HistogramFeature('Население 2022', 'population2022', 1e6, 'млн'),
    HistogramFeature('Население 2020', 'population2020', 1e6, 'млн'),
    HistogramFeature('Население 2015', 'population2015', 1e6, 'млн'),
    HistogramFeature('Площадь', 'area', 1e3, 'тыс. км²'),
    HistogramFeature('Плотность', 'density', 1, 'чел/км²'),
    HistogramFeature('Темп роста', 'growthRate', 1, ''),
    HistogramFeature('Доля мира', 'worldPopulationPercentage', 1, '%'),
  ];

  @override
  double? extractValue(PopulationData data, String field) {
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
    
    return '${_formatNumber(binStart)}\n${_formatNumber(binEnd)}';
  }
  
  String _formatNumber(double value) {
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}k';
    return value.toStringAsFixed(1);
  }
}