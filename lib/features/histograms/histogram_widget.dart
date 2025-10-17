import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/data/data_model.dart';
import 'histogram_config.dart';

/// {@template universal_histograms}
/// Универсальный компонент для построения гистограмм для любого типа данных
/// {@endtemplate}
class UniversalHistograms<T extends DataModel> extends StatelessWidget {
  final List<T> data;
  final HistogramConfig<T> config;
  final String title;

  const UniversalHistograms({
    super.key,
    required this.data,
    required this.config,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHistogramsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistogramsContent() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: config.features.length,
      itemBuilder: (context, index) {
        return _buildSingleHistogram(config.features[index]);
      },
    );
  }

  Widget _buildSingleHistogram(HistogramFeature feature) {
    final values = _extractValues(feature.field, feature.divisor);
    
    if (values.isEmpty) {
      return _buildEmptyHistogram('Нет данных');
    }

    final bins = _createHistogramBins(values, 10);
    final maxCount = bins.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${feature.title} ${feature.unit.isNotEmpty ? '(${feature.unit})' : ''}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                barGroups: bins.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: _getHistogramColor(entry.key, bins.length),
                        width: 25,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final binIndex = value.toInt();
                        if (binIndex < bins.length) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              config.formatBinLabel(binIndex, bins.length, values),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _calculateHistogramInterval(maxCount),
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final count = rod.toY.toInt();
                      final binLabel = config.formatBinLabel(groupIndex, bins.length, values);
                      return BarTooltipItem(
                        '$binLabel\nКоличество: $count',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                maxY: maxCount * 1.1,
                minY: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Всего: ${values.length} записей',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<double> _extractValues(String field, double divisor) {
    final values = <double>[];
    
    for (final item in data) {
      final value = config.extractValue(item, field);
      if (value != null && value > 0) {
        values.add(value / divisor);
      }
    }
    
    return values;
  }

  Map<int, int> _createHistogramBins(List<double> values, int binCount) {
    if (values.isEmpty) return {};
    
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final binWidth = (maxVal - minVal) / binCount;
    
    final bins = <int, int>{};
    for (int i = 0; i < binCount; i++) {
      bins[i] = 0;
    }
    
    for (final value in values) {
      final binIndex = ((value - minVal) / binWidth).floor();
      final safeIndex = binIndex.clamp(0, binCount - 1);
      bins[safeIndex] = bins[safeIndex]! + 1;
    }
    
    return bins;
  }

  Widget _buildEmptyHistogram(String message) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(message)),
    );
  }

  Color _getHistogramColor(int binIndex, int totalBins) {
    final hue = (binIndex / totalBins) * 240; // От синего к красному
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  double _calculateHistogramInterval(double maxCount) {
    if (maxCount <= 5) return 1;
    if (maxCount <= 20) return 5;
    if (maxCount <= 50) return 10;
    return (maxCount / 5).roundToDouble();
  }
}