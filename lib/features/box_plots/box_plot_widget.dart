import 'package:flutter/material.dart';

import '../../../core/data/data_model.dart';
import 'box_plot_config.dart';
import '../../core/analysis/statistics_calculator.dart';

/// Упрощенный и понятный box plot с точками данных
class UniversalBoxPlot<T extends DataModel> extends StatelessWidget {
  final List<T> data;
  final BoxPlotConfig<T> config;
  final String title;

  const UniversalBoxPlot({
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
            _buildBoxPlotsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxPlotsContent() {
    final features = config.features;
    
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildSingleBoxPlot(feature),
        );
      }).toList(),
    );
  }

  Widget _buildSingleBoxPlot(BoxPlotFeature feature) {
    final values = _extractValues(feature.field, feature.divisor);
    if (values.isEmpty) {
      return _buildEmptyBoxPlot('Нет данных для ${feature.title}');
    }

    final stats = StatisticsCalculator.calculateDescriptiveStats(values);

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
          // Заголовок и статистика
          _buildHeader(feature.title, stats, feature),
          const SizedBox(height: 16),
          // Сам график
          SizedBox(
            height: 140, // Увеличили высоту для точек
            child: _buildBoxPlotWithPoints(stats, values, feature),
          ),
          const SizedBox(height: 8),
          // Подпись с выбросами
          _buildOutlierInfo(stats, values),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, DescriptiveStats stats, BoxPlotFeature feature) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildStatItem('Записей:', stats.count.toString()),
            _buildStatItem('Медиана:', config.formatValue(stats.median, feature.field)),
            _buildStatItem('Q1:', config.formatValue(stats.q1, feature.field)),
            _buildStatItem('Q3:', config.formatValue(stats.q3, feature.field)),
            _buildStatItem('Min:', config.formatValue(stats.min, feature.field)),
            _buildStatItem('Max:', config.formatValue(stats.max, feature.field)),
          ],
        ),
      ],
    );
  }

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

  Widget _buildBoxPlotWithPoints(DescriptiveStats stats, List<double> values, BoxPlotFeature feature) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 120),
          painter: _BoxPlotWithPointsPainter(
            stats: stats,
            values: values,
            config: config,
            feature: feature,
          ),
        );
      },
    );
  }

  Widget _buildOutlierInfo(DescriptiveStats stats, List<double> values) {
    final outliers = _findOutliers(stats, values);
    
    if (outliers.isNotEmpty) {
      return Text(
        'Выбросы: ${outliers.length} записей (${(outliers.length / stats.count * 100).toStringAsFixed(1)}%)',
        style: TextStyle(
          fontSize: 11,
          color: Colors.orange[700],
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return const SizedBox();
  }

  List<double> _findOutliers(DescriptiveStats stats, List<double> values) {
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    final upperBound = stats.q3 + 1.5 * iqr;
    
    return values.where((value) => value < lowerBound || value > upperBound).toList();
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

  Widget _buildEmptyBoxPlot(String message) => Container(
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

/// Box plot painter с точками данных
class _BoxPlotWithPointsPainter extends CustomPainter {
  final DescriptiveStats stats;
  final List<double> values;
  final BoxPlotConfig config;
  final BoxPlotFeature feature;

  _BoxPlotWithPointsPainter({
    required this.stats,
    required this.values,
    required this.config,
    required this.feature,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final padding = 20.0;
    final plotWidth = size.width - padding * 2;

    // Основные цвета
    final boxColor = Colors.blue;
    final whiskerColor = Colors.grey;
    final medianColor = Colors.red;
    final pointsColor = Colors.blue.withOpacity(0.3);
    final outliersColor = Colors.orange;

    // Основная кисть для линий
    final linePaint = Paint()
      ..color = whiskerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Кисть для ящика
    final boxPaint = Paint()
      ..color = boxColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final boxBorderPaint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Кисть для медианы
    final medianPaint = Paint()
      ..color = medianColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Кисть для точек
    final pointsPaint = Paint()
      ..color = pointsColor
      ..style = PaintingStyle.fill;

    // Кисть для выбросов
    final outliersPaint = Paint()
      ..color = outliersColor
      ..style = PaintingStyle.fill;

    // Рассчитываем позиции
    final minX = padding;
    final maxX = size.width - padding;

    // Нормализуем значения в диапазон графика
    double normalize(double value) {
      final range = stats.max - stats.min;
      if (range == 0) return plotWidth / 2 + padding;
      return ((value - stats.min) / range) * plotWidth + padding;
    }

    final xMin = normalize(stats.min);
    final xMax = normalize(stats.max);
    final xQ1 = normalize(stats.q1);
    final xQ3 = normalize(stats.q3);
    final xMedian = normalize(stats.median);

    // Находим выбросы
    final outliers = _findOutliers(stats, values);
    final normalPoints = values.where((value) => !outliers.contains(value)).toList();

    // 1. Рисуем точки нормальных данных (jitter plot)
    _drawDataPoints(canvas, normalPoints, normalize, pointsPaint, centerY);

    // 2. Рисуем точки выбросов
    _drawDataPoints(canvas, outliers, normalize, outliersPaint, centerY);

    // 3. Рисуем основную линию от Min до Max
    canvas.drawLine(
      Offset(xMin, centerY),
      Offset(xMax, centerY),
      linePaint,
    );

    // 4. Рисуем вертикальные линии на концах
    canvas.drawLine(
      Offset(xMin, centerY - 15),
      Offset(xMin, centerY + 15),
      linePaint,
    );
    canvas.drawLine(
      Offset(xMax, centerY - 15),
      Offset(xMax, centerY + 15),
      linePaint,
    );

    // 5. Рисуем ящик (Q1 до Q3)
    final boxRect = Rect.fromLTRB(
      xQ1,
      centerY - 25,
      xQ3,
      centerY + 25,
    );
    canvas.drawRect(boxRect, boxPaint);
    canvas.drawRect(boxRect, boxBorderPaint);

    // 6. Рисуем медиану
    canvas.drawLine(
      Offset(xMedian, centerY - 25),
      Offset(xMedian, centerY + 25),
      medianPaint,
    );

    // 7. Добавляем подписи ключевых точек
    _drawLabel(canvas, xMin, centerY + 45, config.formatValue(stats.min, feature.field));
    _drawLabel(canvas, xMax, centerY + 45, config.formatValue(stats.max, feature.field));
    _drawLabel(canvas, xMedian, centerY - 45, config.formatValue(stats.median, feature.field));
  }

  void _drawDataPoints(Canvas canvas, List<double> points, double Function(double) normalize, Paint paint, double centerY) {
    final random = _JitterRandom(); // Для случайного распределения по вертикали
    
    for (final value in points) {
      final x = normalize(value);
      // Добавляем небольшой случайный разброс по Y для лучшей визуализации
      final yJitter = centerY + (random.nextDouble() * 40 - 20); // ±20 пикселей
      
      canvas.drawCircle(
        Offset(x, yJitter),
        2.5, // Размер точки
        paint,
      );
    }
  }

  List<double> _findOutliers(DescriptiveStats stats, List<double> values) {
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    final upperBound = stats.q3 + 1.5 * iqr;
    
    return values.where((value) => value < lowerBound || value > upperBound).toList();
  }

  void _drawLabel(Canvas canvas, double x, double y, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Простой генератор псевдослучайных чисел для jitter эффекта
class _JitterRandom {
  int _seed = 1;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return (_seed >> 16) / 32767.0;
  }
}