import '../../core/data/data_model.dart';

abstract class HistogramConfig<T extends DataModel> {
  List<HistogramFeature> get features;
  double? extractValue(T data, String field);
  String formatBinLabel(int binIndex, int totalBins, List<double> values);
}

class HistogramFeature {
  final String title;
  final String field;
  final double divisor;
  final String unit;
  final String? displayFormat;

  const HistogramFeature(
    this.title,
    this.field,
    this.divisor,
    this.unit, {
    this.displayFormat,
  });
}