import 'dart:ui';

import 'pair_plot_config.dart';
import '../../core/data/data_model.dart';

class GroupedPairPlotConfigWrapper<T extends DataModel> extends PairPlotConfig<T> {
  final PairPlotConfig<T> originalConfig;
  final List<PairPlotFeature> groupFeatures; // Переименовали поле

  GroupedPairPlotConfigWrapper({
    required this.originalConfig,
    required this.groupFeatures, // Используем новое имя
  });

  @override
  List<PairPlotFeature> get features => groupFeatures; // Возвращаем groupFeatures

  @override
  double? extractValue(T data, String field) {
    return originalConfig.extractValue(data, field);
  }

  @override
  String formatValue(double value, String field) {
    return originalConfig.formatValue(value, field);
  }

  @override
  Color? getPointColor(T data, String colorField) {
    return originalConfig.getPointColor(data, colorField);
  }
}