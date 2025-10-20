import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../features/house/data/house_data_model.dart';

/// Линейный график влияния года постройки на цену
class YearPriceLineChart extends StatelessWidget {
  final List<HouseDataModel> data;

  const YearPriceLineChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final yearPriceData = _calculateAveragePriceByYear();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Влияние года постройки на цену',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Средняя стоимость недвижимости по годам постройки',
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
                          final year = yearPriceData[spot.spotIndex].year;
                          final price = yearPriceData[spot.spotIndex].price;
                          return LineTooltipItem(
                            '$year год\n\$${(price / 1000).toStringAsFixed(0)} тыс.',
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
                    horizontalInterval: _calculatePriceInterval(yearPriceData),
                    verticalInterval: 10,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          final year = value.toInt();
                          if (year % 20 == 0 && year >= 1900 && year <= 2020) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                year.toString(),
                                style: const TextStyle(fontSize: 10),
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
                        interval: _calculatePriceInterval(yearPriceData),
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '\$${(value / 1000).toStringAsFixed(0)}к',
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
                  minX: _getMinYear(yearPriceData).toDouble(),
                  maxX: _getMaxYear(yearPriceData).toDouble(),
                  minY: 0,
                  maxY: _getMaxPrice(yearPriceData) * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: yearPriceData.map((data) {
                        return FlSpot(data.year.toDouble(), data.price);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.3),
                            Colors.green.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendInfo(yearPriceData),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendInfo(List<YearPriceData> data) {
    if (data.length < 2) return const SizedBox();
    
    final firstPrice = data.first.price;
    final lastPrice = data.last.price;
    final growth = lastPrice - firstPrice;
    final growthPercent = (growth / firstPrice * 100);
    
    return Row(
      children: [
        Icon(
          growth >= 0 ? Icons.trending_up : Icons.trending_down,
          color: growth >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          'Рост стоимости: ${growthPercent.toStringAsFixed(1)}% '
          '(\$${(growth / 1000).toStringAsFixed(0)} тыс.)',
          style: TextStyle(
            fontSize: 12,
            color: growth >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<YearPriceData> _calculateAveragePriceByYear() {
    final yearGroups = <int, List<double>>{};
    
    // Группируем цены по годам постройки
    for (final house in data) {
      final year = house.yrBuilt;
      if (year > 1900) { // Фильтруем корректные года
        yearGroups.putIfAbsent(year, () => []);
        yearGroups[year]!.add(house.price);
      }
    }
    
    // Рассчитываем среднюю цену для каждого года
    final result = yearGroups.entries.map((entry) {
      final averagePrice = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return YearPriceData(
        year: entry.key,
        price: averagePrice,
        count: entry.value.length,
      );
    }).toList();
    
    // Сортируем по году
    result.sort((a, b) => a.year.compareTo(b.year));
    
    return result;
  }

  int _getMinYear(List<YearPriceData> data) {
    return data.map((e) => e.year).reduce((a, b) => a < b ? a : b);
  }

  int _getMaxYear(List<YearPriceData> data) {
    return data.map((e) => e.year).reduce((a, b) => a > b ? a : b);
  }

  double _getMaxPrice(List<YearPriceData> data) {
    return data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
  }

  double _calculatePriceInterval(List<YearPriceData> data) {
    final maxPrice = _getMaxPrice(data);
    if (maxPrice <= 100000) return 20000;
    if (maxPrice <= 500000) return 50000;
    if (maxPrice <= 1000000) return 100000;
    return 200000;
  }
}

class YearPriceData {
  final int year;
  final double price;
  final int count;

  const YearPriceData({
    required this.year,
    required this.price,
    required this.count,
  });
}