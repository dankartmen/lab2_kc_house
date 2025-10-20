import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Линейный график корреляции признаков с ценой
class CorrelationLineChart extends StatelessWidget {
  final Map<String, double> correlations;
  
  const CorrelationLineChart({
    super.key,
    required this.correlations,
  });

  @override
  Widget build(BuildContext context) {
    final topFeatures = _getTopFeatures(10); // Топ-10 признаков
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Корреляция признаков с ценой',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Влияние характеристик на стоимость недвижимости',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final feature = topFeatures[spot.spotIndex];
                          return LineTooltipItem(
                            '${feature.name}\nКорреляция: ${feature.correlation.toStringAsFixed(3)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topFeatures.length) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Transform.rotate(
                                angle: -0.4,
                                child: Text(
                                  topFeatures[value.toInt()].shortName,
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                        interval: 0.2,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minY: 0,
                  maxY: 1.0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: topFeatures.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.correlation,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTopFeaturesList(topFeatures),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFeaturesList(List<CorrelationFeature> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Топ-5 признаков по влиянию на цену:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...features.take(5).map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  feature.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                feature.correlation.toStringAsFixed(3),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getCorrelationColor(feature.correlation),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getCorrelationColor(double correlation) {
    if (correlation > 0.6) return Colors.green;
    if (correlation > 0.3) return Colors.orange;
    return Colors.red;
  }

  List<CorrelationFeature> _getTopFeatures(int count) {
    // Исключаем саму цену из списка
    final filtered = correlations.entries.where((entry) => entry.key != 'price').toList();
    
    // Сортируем по убыванию корреляции
    filtered.sort((a, b) => b.value.compareTo(a.value));
    
    // Берем топ-N признаков
    return filtered.take(count).map((entry) {
      return CorrelationFeature(
        name: _getFeatureDisplayName(entry.key),
        shortName: _getShortName(entry.key),
        correlation: entry.value,
      );
    }).toList();
  }

  String _getFeatureDisplayName(String field) {
    final names = {
      'sqft_living': 'Жилая площадь',
      'grade': 'Оценка',
      'sqft_above': 'Площадь над землей',
      'sqft_living15': 'Средняя жилая площадь в районе',
      'bathrooms': 'Количество ванных',
      'view': 'Вид',
      'sqft_basement': 'Площадь подвала',
      'bedrooms': 'Количество спален',
      'lat': 'Широта',
      'waterfront': 'Водная фронта',
      'floors': 'Этажи',
      'yr_renovated': 'Год реновации',
      'sqft_lot': 'Площадь участка',
      'sqft_lot15': 'Средняя площадь участка в районе',
      'yr_built': 'Год постройки',
      'condition': 'Состояние',
      'long': 'Долгота',
    };
    
    return names[field] ?? field;
  }

  String _getShortName(String field) {
    final shortNames = {
      'sqft_living': 'Жилая пл.',
      'grade': 'Оценка',
      'sqft_above': 'Пл. над землей',
      'sqft_living15': 'Ср. жилая пл.',
      'bathrooms': 'Ванные',
      'view': 'Вид',
      'sqft_basement': 'Подвал',
      'bedrooms': 'Спальни',
      'lat': 'Широта',
      'waterfront': 'Водная фронта',
      'floors': 'Этажи',
      'yr_renovated': 'Реновация',
      'sqft_lot': 'Участок',
      'sqft_lot15': 'Ср. участок',
      'yr_built': 'Год постр.',
      'condition': 'Состояние',
      'long': 'Долгота',
    };
    
    return shortNames[field] ?? field;
  }
}

class CorrelationFeature {
  final String name;
  final String shortName;
  final double correlation;

  const CorrelationFeature({
    required this.name,
    required this.shortName,
    required this.correlation,
  });
}