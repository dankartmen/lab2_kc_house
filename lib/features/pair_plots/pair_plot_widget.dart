import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/data/data_model.dart';
import 'pair_plot_config.dart';

/// {@template universal_pair_plots}
/// Универсальный компонент для построения парных диаграмм (bar charts) для любого типа данных.
/// {@endtemplate}
class UniversalPairPlots<T extends DataModel> extends StatelessWidget {
  final List<T> data;
  final PairPlotConfig<T> config;
  final String title;

  const UniversalPairPlots({
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
            _buildPairPlotsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPairPlotsContent() {
    final features = config.features;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildSinglePairPlot(features[index]);
      },
    );
  }

  Widget _buildSinglePairPlot(PairPlotFeature feature) {
    final binInfo = _createBarBins(feature.fieldX, feature.fieldY, feature.divisorX, feature.divisorY);
    final binData = binInfo['data'] as Map<int, double>;
    final minX = binInfo['minX'] as double;
    final binWidth = binInfo['binWidth'] as double;
      
    if (binData.isEmpty) {
      return _buildEmptyPairPlot('Нет данных для ${feature.title}');
    }

    final maxHeight = binData.values.reduce((a, b) => a > b ? a : b).toDouble();

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
            feature.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: binData.keys.map((binIndex) {
                  final height = binData[binIndex]!;
                  return BarChartGroupData(
                    x: binIndex,
                    barRods: [
                      BarChartRodData(
                        toY: height,
                        color: _getBarColor(binIndex, binData.length),
                        width: 16,
                      ),
                    ],
                  );
                }).toList(),
                // titlesData: FlTitlesData(
                //   show: true,
                //   bottomTitles: AxisTitles(
                //     sideTitles: SideTitles(
                //       showTitles: true,
                //       reservedSize: 30,
                //       getTitlesWidget: (value, meta) => Text(_formatBinLabel(value.toInt(), binData.keys.toList(), feature.fieldX)),
                //     ),
                //   ),
                //   leftTitles: AxisTitles(
                //     sideTitles: SideTitles(
                //       showTitles: true,
                //       reservedSize: 40,
                //       getTitlesWidget: (value, meta) => Text(config.formatValue(value.toDouble(), feature.fieldY)),
                //     ),
                //   ),
                // ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final binLabel = _formatBinLabel(group.x, binData, feature.fieldX, minX, binWidth);  // Передаём minX и binWidth
                      return BarTooltipItem(
                        binLabel,
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                maxY: maxHeight * 1.1,
                minY: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Групп по X: ${binData.length}',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Создаёт bins: ключ — b  inIndex (для X), значение — среднее Y по бину.
  Map<String, dynamic> _createBarBins(String fieldX, String fieldY, double divisorX, double divisorY) {
    final points = _extractPoints(fieldX, fieldY, divisorX, divisorY);
    if (points.isEmpty) return {};

    final xValues = points.map((p) => p.dx).toList();
    final minX = xValues.reduce((a, b) => a < b ? a : b);
    final maxX = xValues.reduce((a, b) => a > b ? a : b);
    final binCount = 8;
    final binWidth = (maxX - minX) / binCount;

    final bins = <int, List<double>>{};
    for (final point in points) {
      final binIndex = ((point.dx - minX) / binWidth).floor().clamp(0, binCount - 1);
      bins[binIndex] ??= [];
      bins[binIndex]!.add(point.dy);
    }

    final barData = <int, double>{};
    for (final entry in bins.entries) {
      final meanY = entry.value.reduce((a, b) => a + b) / entry.value.length;
      barData[entry.key] = meanY;
    }

    return {
      'data': barData,
      'minX': minX,
      'binWidth': binWidth,
    };
  }

  List<Offset> _extractPoints(String fieldX, String fieldY, double divisorX, double divisorY) {
    final points = <Offset>[];
    
    for (final item in data) {
      final x = config.extractValue(item, fieldX);
      final y = config.extractValue(item, fieldY);
      if (x != null && y != null) {  // Убрал >0 для Y (если бинарное)
        points.add(Offset(x / divisorX, y / divisorY));
      }
    }
    
    return points;
  }

  String _formatBinLabel(int binIndex, Map<int, double> binData, String fieldX, double minX, double binWidth) {
    final startX = minX + binIndex * binWidth;
    final endX = minX + (binIndex + 1) * binWidth;
    return 'Диапазон ${fieldX}: ${startX.toStringAsFixed(0)}–${endX.toStringAsFixed(0)}\nСреднее ${fieldX}: ${binData[binIndex]!.toStringAsFixed(2)}';
  }

  Color _getBarColor(int binIndex, int totalBins) {
    final hue = (binIndex / totalBins) * 240;  // Градиент от синего к красному
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  Widget _buildEmptyPairPlot(String message) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(message)),
    );
  }
}