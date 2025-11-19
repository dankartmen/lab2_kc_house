// pair_plot_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/data/data_model.dart';
import 'pair_plot_config.dart';

class UniversalPairPlots<T extends DataModel> extends StatelessWidget {
  final List<T> data;
  final PairPlotConfig<T> config;
  final String title;
  final String colorField;

  const UniversalPairPlots({
    super.key,
    required this.data,
    required this.config,
    required this.title,
    this.colorField = 'heartAttackRisk',
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
            Container( // Временно упрощаем
              height: 300,
              color: Colors.blue[50],
              child: Center(
                child: Text('UniversalPairPlots: ${data.length} records'),
              ),
            ),
            //_buildPairPlotMatrix(),
          ],
        ),
      ),
    );
  }

  Widget _buildPairPlotMatrix() {
    final features = config.features;
    final size = features.length;

    return Container(
      width: double.infinity,
      height: 400,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          
          return _buildMatrixCell(
            features[row],
            features[col],
            row == col,
          );
        },
      ),
    );
  }

  Widget _buildMatrixCell(PairPlotFeature featureY, PairPlotFeature featureX, bool isDiagonal) {
    if (isDiagonal) {
      return _buildDiagonalPlot(featureY);
    } else {
      return _buildScatterPlot(featureX, featureY);
    }
  }

  Widget _buildDiagonalPlot(PairPlotFeature feature) {
    final values = _extractValues(feature.field, feature.divisor);
    
    if (values.isEmpty) {
      return _buildEmptyCell('Нет данных');
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            feature.displayName,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _buildHistogram(values, feature),
          ),
        ],
      ),
    );
  }

  Widget _buildHistogram(List<double> values, PairPlotFeature feature) {
    if (values.isEmpty) return const SizedBox();

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    
    const binCount = 5;
    final binWidth = range / binCount;
    
    final bins = List<int>.filled(binCount, 0);
    
    for (final value in values) {
      final binIndex = ((value - minVal) / binWidth).floor().clamp(0, binCount - 1);
      bins[binIndex]++;
    }
    
    final maxFreq = bins.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        barGroups: bins.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: maxFreq > 0 ? entry.value / maxFreq * 6 : 0,
                color: Colors.blue[300]!,
                width: 4,
              ),
            ],
          );
        }).toList(),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildScatterPlot(PairPlotFeature featureX, PairPlotFeature featureY) {
    final points = _extractScatterPoints(featureX, featureY);
    
    if (points.isEmpty) {
      return _buildEmptyCell('Нет данных');
    }

    // Вычисляем границы для правильного отображения
    final xValues = points.map((p) => p.x).toList();
    final yValues = points.map((p) => p.y).toList();
    
    final minX = xValues.reduce((a, b) => a < b ? a : b);
    final maxX = xValues.reduce((a, b) => a > b ? a : b);
    final minY = yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.all(4),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: points,
          minX: minX - (maxX - minX) * 0.1,
          maxX: maxX + (maxX - minX) * 0.1,
          minY: minY - (maxY - minY) * 0.1,
          maxY: maxY + (maxY - minY) * 0.1,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          scatterTouchData: ScatterTouchData(
            enabled: true,
            touchTooltipData: ScatterTouchTooltipData(
              getTooltipItems: (ScatterSpot spot) { // ИСПРАВЛЕНО: используем getTooltipItem вместо getTooltipItems
                return ScatterTooltipItem(
                  '${featureX.displayName}: ${config.formatValue(spot.x, featureX.field)}\n'
                  '${featureY.displayName}: ${config.formatValue(spot.y, featureY.field)}',
                  textStyle: TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<ScatterSpot> _extractScatterPoints(PairPlotFeature featureX, PairPlotFeature featureY) {
    final points = <ScatterSpot>[];
    
    for (final item in data) {
      final x = config.extractValue(item, featureX.field);
      final y = config.extractValue(item, featureY.field);
      
      if (x != null && y != null) {
        final color = config.getPointColor(item, colorField) ?? Colors.blue;
        
        points.add(ScatterSpot(
          x / featureX.divisor,
          y / featureY.divisor,
          dotPainter: FlDotCirclePainter(
            color: color,
            radius: 3,
          )
        ));
      }
    }
    
    return points;
  }

  List<double> _extractValues(String field, double divisor) {
    return data
        .map((item) => config.extractValue(item, field))
        .whereType<double>()
        .map((value) => value / divisor)
        .toList();
  }

  Widget _buildEmptyCell(String message) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 8, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}