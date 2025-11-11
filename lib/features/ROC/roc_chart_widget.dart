import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../credit_card/data/fraud_analysis_model.dart';

class RocChartWidget extends StatelessWidget {
  final RocCurve rocCurve;
  final double? aucValue;

  const RocChartWidget({
    super.key,
    required this.rocCurve,
    this.aucValue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ROC-кривая',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (aucValue != null) ...[
              const SizedBox(height: 4),
              Text(
                'AUC = ${aucValue!.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildRocChart(),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildRocChart() {
    // Создаем точки для ROC-кривой
    final spots = List.generate(
      rocCurve.fpr.length,
      (index) => FlSpot(rocCurve.fpr[index], rocCurve.tpr[index]),
    );

    // Линия случайного классификатора (диагональ)
    final diagonalSpots = [
      const FlSpot(0, 0),
      const FlSpot(1, 1),
    ];

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final threshold = rocCurve.thresholds.isNotEmpty && 
                    spot.spotIndex < rocCurve.thresholds.length
                    ? rocCurve.thresholds[spot.spotIndex]
                    : 0.0;
                
                return LineTooltipItem(
                  'FPR: ${spot.x.toStringAsFixed(3)}\n'
                  'TPR: ${spot.y.toStringAsFixed(3)}\n'
                  'Threshold: ${threshold.toStringAsFixed(3)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(1));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(1));
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
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          // ROC-кривая модели
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          // Диагональ случайного классификатора
          LineChartBarData(
            spots: diagonalSpots,
            isCurved: false,
            color: Colors.grey,
            barWidth: 1,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Линия для TPR = 0.5
            HorizontalLine(
              y: 0.5,
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            // Линия для FPR = 0.5
            HorizontalLine(
              y: 0.5,
              color: Colors.transparent, // Невидимая, но создает отступ
              strokeWidth: 0,
            ),
          ],
          verticalLines: [
            // Линия для FPR = 0.5
            VerticalLine(
              x: 0.5,
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('ROC-кривая модели', Colors.blue),
        const SizedBox(width: 20),
        _buildLegendItem('Случайный классификатор', Colors.grey),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}