import '../../population/data/population_model.dart';
import '../box_plot_config.dart';

class PopulationBoxPlotConfig implements BoxPlotConfig<PopulationData> {
  @override
  List<BoxPlotFeature> get features => [
    BoxPlotFeature('Население 2022', 'population2022', divisor: 1e6, groupBy: 'continent'),  // Группировка по континентам
    BoxPlotFeature('Плотность', 'density', divisor: 1, groupBy: 'continent'),
    BoxPlotFeature('Темп роста', 'growthRate', divisor: 1),
  ];

  @override
  double? extractValue(PopulationData data, String field) => data.getNumericValue(field);

  @override
  String formatValue(double value, String field) {
    if (field.contains('population')) return '${value.toInt()} млн';
    if (field == 'density') return '${value.toInt()} чел/км²';
    return value.toStringAsFixed(2);
  }
}