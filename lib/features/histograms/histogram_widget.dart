import 'dart:math';

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
    return Column(
      children: config.features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildSingleHistogram(feature),
        );
      }).toList(),
    );
  }

  Widget _buildSingleHistogram(HistogramFeature feature) {
    final values = _extractValues(feature.field, feature.divisor);
    
    if (values.isEmpty) {
      return _buildEmptyHistogram('Нет данных для ${feature.title}');
    }

    final binCount = feature.binCount;
    final bins = _createHistogramBins(values, binCount);
    
    // Получаем реальные границы бинов
    final binBoundaries = _calculateRealBinBoundaries(values, binCount);
    final maxCount = bins.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Распределение ${feature.title}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Статистика
          _buildStatsSummary(values, feature),
          const SizedBox(height: 16),
          
          // График
          SizedBox(
            height: 220, // Немного больше для подписей
            child: Stack(
              children: [
                // Сам график
                Positioned.fill(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      groupsSpace: 2, // Небольшой отступ между барами
                      barGroups: bins.entries.map((entry) {
                        final binIndex = entry.key;
                        return BarChartGroupData(
                          x: binIndex,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Colors.blue.withOpacity(0.8),
                              width: 16,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2),
                                topRight: Radius.circular(2),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        // Убираем стандартные подписи на оси X
                        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: _calculateYAxisInterval(maxCount),
                            getTitlesWidget: (value, meta) {
                              if (value % _calculateYAxisInterval(maxCount) == 0) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateYAxisInterval(maxCount),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 0.5,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final count = rod.toY.toInt();
                            final start = binBoundaries[groupIndex];
                            final end = binBoundaries[groupIndex + 1];
                            
                            return BarTooltipItem(
                              '${start.toStringAsFixed(0)}–${end.toStringAsFixed(0)} ${feature.unit}\n'
                              'Количество: $count\n'
                              '(${(count / values.length * 100).toStringAsFixed(1)}%)',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      maxY: maxCount * 1.15,
                      minY: 0,
                    ),
                  ),
                ),
              
              ],
            ),
          ),
          
          // Подсказка о наклоне подписей
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Наведите на столбец для просмотра диапазона',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Подпись
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Всего: ${values.length} записей, ${feature.binCount} интервалов',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Строит статистическую сводку
  Widget _buildStatsSummary(List<double> values, HistogramFeature feature) {
    if (values.isEmpty) return const SizedBox();
    
    final sortedValues = List<double>.from(values)..sort();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final median = sortedValues[values.length ~/ 2];
    final min = sortedValues.first;
    final max = sortedValues.last;
    
    // Вычисляем стандартное отклонение
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    final stdDev = sqrt(variance);
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildStatItem('Записей:', values.length.toString()),
        _buildStatItem('Среднее:', mean.toStringAsFixed(2)),
        _buildStatItem('Медиана:', median.toStringAsFixed(2)),
        _buildStatItem('Ст.откл.:', stdDev.toStringAsFixed(2)),
        _buildStatItem('Min:', min.toStringAsFixed(2)),
        _buildStatItem('Max:', max.toStringAsFixed(2)),
      ],
    );
  }

  /// Строит элемент статистики
  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<double> _extractValues(String field, double divisor) {
    final values = <double>[];
    
    for (final item in data) {
      final value = config.extractValue(item, field);
      if (value != null && value.isFinite) {
        values.add(value / divisor);
      }
    }
    
    return values;
  }

  /// Создает бины гистограммы с реальными границами
  Map<int, int> _createHistogramBins(List<double> values, int binCount) {
    if (values.isEmpty) return {};
    
    final binBoundaries = _calculateRealBinBoundaries(values, binCount);
    final bins = <int, int>{};
    
    // Инициализируем все бины нулями
    for (int i = 0; i < binCount; i++) {
      bins[i] = 0;
    }
    
    // Распределяем значения по бинам
    for (final value in values) {
      // Находим соответствующий бин
      for (int i = 0; i < binCount; i++) {
        if (value >= binBoundaries[i] && (i == binCount - 1 || value < binBoundaries[i + 1])) {
          bins[i] = bins[i]! + 1;
          break;
        }
      }
    }
    
    return bins;
  }

  /// Вычисляет РЕАЛЬНЫЕ границы бинов без округлений
  List<double> _calculateRealBinBoundaries(List<double> values, int binCount) {
    if (values.isEmpty) return [];
    
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    
    // Если все значения одинаковы, создаем один бин
    if (minVal == maxVal) {
      return [minVal, maxVal + 0.001]; // Маленькая дельта для создания бина
    }
    
    final range = maxVal - minVal;
    final binWidth = range / binCount;
    
    // Создаем границы на основе реальных данных
    final boundaries = <double>[];
    for (int i = 0; i <= binCount; i++) {
      boundaries.add(minVal + i * binWidth);
    }
    
    // Последнюю границу делаем немного больше максимального значения
    // чтобы включить максимальное значение в последний бин
    boundaries[binCount] = maxVal * 1.0001;
    
    return boundaries;
  }

  /// Вычисляет интервал для оси Y
  double _calculateYAxisInterval(double maxCount) {
    if (maxCount <= 5) return 1;
    if (maxCount <= 10) return 2;
    if (maxCount <= 20) return 5;
    if (maxCount <= 50) return 10;
    if (maxCount <= 100) return 20;
    if (maxCount <= 200) return 50;
    return (maxCount / 5).roundToDouble();
  }

  Widget _buildEmptyHistogram(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}