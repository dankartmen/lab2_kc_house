import 'package:flutter/material.dart';

import '../../../core/data/data_model.dart';
import 'box_plot_config.dart';
import '../../core/analysis/statistics_calculator.dart';

/// Упрощенный и понятный box plot с точками данных
class UniversalBoxPlot<T extends DataModel> extends StatelessWidget {
  /// Данные для построения диаграмм
  final List<T> data;

  /// Конфигурация box plot
  final BoxPlotConfig<T> config;

  /// Заголовок виджета
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

  /// Строит содержимое всех box plot
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

  /// Строит одиночный box plot
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

  /// Строит заголовок и статистику для box plot
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

  /// Строит box plot с точками данных
  Widget _buildBoxPlotWithPoints(DescriptiveStats stats, List<double> values, BoxPlotFeature feature) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 120),
          painter: _BoxPlotPainter(
            stats: stats,
            values: values,
            config: config,
            feature: feature,
          ),
        );
      },
    );
  }

  /// Строит информацию о выбросах
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

  /// Находит выбросы в данных
  List<double> _findOutliers(DescriptiveStats stats, List<double> values) {
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    final upperBound = stats.q3 + 1.5 * iqr;
    
    return values.where((value) => value < lowerBound || value > upperBound).toList();
  }

   /// Извлекает значения для указанного поля
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

  /// Строит пустой box plot
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

/// Box plot 
class _BoxPlotPainter extends CustomPainter {
  /// Статистика данных
  final DescriptiveStats stats;

  /// Значения данных
  final List<double> values;

  /// Конфигурация box plot
  final BoxPlotConfig config;

  /// Признак для отображения
  final BoxPlotFeature feature;

  _BoxPlotPainter({
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
    final outliersColor = Colors.orange;

    // Основная кисть для линий
    final linePaint = Paint()
      ..color = whiskerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Кисть для ящика
    final boxPaint = Paint()
      ..color = boxColor.withValues(alpha: 0.3)
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


    // Находим выбросы и границы усов
    final outliers = _findOutliers(stats, values);
    final whiskerLower = _getWhiskerLower(values, stats);
    final whiskerUpper = _getWhiskerUpper(values, stats);

    // Рассчитываем позиции с учетом усов
    final xWhiskerLower = normalize(whiskerLower);
    final xWhiskerUpper = normalize(whiskerUpper);
    final xMin = normalize(stats.min);
    final xMax = normalize(stats.max);
    final xQ1 = normalize(stats.q1);
    final xQ3 = normalize(stats.q3);
    final xMedian = normalize(stats.median);

    // 1. Рисуем ЛЕВЫЙ ус (от whiskerLower до Q1)
    canvas.drawLine(
      Offset(xWhiskerLower, centerY),
      Offset(xQ1, centerY),
      linePaint,
    );

    // 2. Рисуем ПРАВЫЙ ус (от Q3 до whiskerUpper)
    canvas.drawLine(
      Offset(xQ3, centerY),
      Offset(xWhiskerUpper, centerY),
      linePaint,
    );

    // 3. Рисуем вертикальные линии на концах усов
    canvas.drawLine(
      Offset(xWhiskerLower, centerY - 15),
      Offset(xWhiskerLower, centerY + 15),
      linePaint,
    );
    canvas.drawLine(
      Offset(xWhiskerUpper, centerY - 15),
      Offset(xWhiskerUpper, centerY + 15),
      linePaint,
    );

    // 4. Рисуем ящик (Q1 до Q3)
    final boxRect = Rect.fromLTRB(
      xQ1,
      centerY - 25,
      xQ3,
      centerY + 25,
    );
    canvas.drawRect(boxRect, boxPaint);
    canvas.drawRect(boxRect, boxBorderPaint);

    // 5. Рисуем медиану
    canvas.drawLine(
      Offset(xMedian, centerY - 25),
      Offset(xMedian, centerY + 25),
      medianPaint,
    );

    // 6. Рисуем ВЫБРОСЫ как точки
    _drawOutliers(canvas, outliers, normalize, outliersPaint, centerY);

    // 7. Добавляем подписи
    _drawLabel(canvas, xWhiskerLower, centerY + 45, 
               config.formatValue(whiskerLower, feature.field));
    _drawLabel(canvas, xWhiskerUpper, centerY + 45, 
               config.formatValue(whiskerUpper, feature.field));
    _drawLabel(canvas, xMedian, centerY - 45, 
               config.formatValue(stats.median, feature.field));
  }


  /// Рисует выбросы на canvas
  void _drawOutliers(Canvas canvas, List<double> outliers, 
                    double Function(double) normalize, Paint paint, double centerY) {
    for (final outlier in outliers) {
      final x = normalize(outlier);
      
      canvas.drawCircle(
        Offset(x, centerY),
        4.0, // Размер точки выброса
        paint,
      );
    }
  }

  /// Находит нижнюю границу уса (последняя точка не-выброс слева)
  double _getWhiskerLower(List<double> values, DescriptiveStats stats) {
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    
    final nonOutliers = values.where((v) => v >= lowerBound).toList();
    return nonOutliers.isNotEmpty ? nonOutliers.reduce((a, b) => a < b ? a : b) : stats.min;
  }

  /// Находит верхнюю границу уса (последняя точка не-выброс справа)
  double _getWhiskerUpper(List<double> values, DescriptiveStats stats) {
    final iqr = stats.q3 - stats.q1;
    final upperBound = stats.q3 + 1.5 * iqr;
    
    final nonOutliers = values.where((v) => v <= upperBound).toList();
    return nonOutliers.isNotEmpty ? nonOutliers.reduce((a, b) => a > b ? a : b) : stats.max;
  }

  /// Находит выбросы в данных
  List<double> _findOutliers(DescriptiveStats stats, List<double> values) {
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    final upperBound = stats.q3 + 1.5 * iqr;
    
    return values.where((value) => value < lowerBound || value > upperBound).toList();
  }

  /// Рисует подпись на canvas
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