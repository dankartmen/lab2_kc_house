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
    if (data.isEmpty) {
      return _buildEmptyBoxPlot('Нет данных для ${feature.title}');
    }

    // Если есть группировка, строим несколько box plot
    if (feature.groupBy != null) {
      return _buildGroupedBoxPlot(feature);
    }

    // Обычный box plot без группировки
    return _buildSingleBoxPlotContent(feature, data);
  }

  /// Строит box plot с группировкой
  Widget _buildGroupedBoxPlot(BoxPlotFeature feature) {
    final groups = _groupDataByFeature(feature.groupBy!);
    
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
            feature.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Box plot для каждой группы
          ...groups.entries.map((entry) {
            final groupName = entry.key;
            final groupData = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${feature.groupBy} = $groupName',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSingleBoxPlotContent(feature, groupData),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Строит содержимое одного box plot
  Widget _buildSingleBoxPlotContent(BoxPlotFeature feature, List<T> plotData) {
    final values = _extractValues(plotData, feature.field, feature.divisor);
    if (values.isEmpty) {
      return _buildEmptyBoxPlot('Нет данных');
    }

    final stats = StatisticsCalculator.calculateDescriptiveStats(values);
    final outliers = _findOutliers(stats, values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Статистика (только для негруппированных или как подпись)
        if (feature.groupBy == null) ...[
          _buildStatsSummary(stats, feature, outliers),
          const SizedBox(height: 16),
        ],
        
        // Сам график
        SizedBox(
          height: 120,
          child: _buildBoxPlotWithPoints(stats, values, feature, outliers),
        ),
        
        // Подпись с выбросами (только для негруппированных)
        if (feature.groupBy == null) ...[
          const SizedBox(height: 8),
          _buildOutlierInfo(outliers, stats.count),
        ],
      ],
    );
  }

  /// Строит статистическую сводку
  Widget _buildStatsSummary(DescriptiveStats stats, BoxPlotFeature feature, List<double> outliers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildStatItem('Записей:', stats.count.toString()),
            _buildStatItem('Медиана:', config.formatValue(stats.median, feature.field)),
            _buildStatItem('Q1:', config.formatValue(stats.q1, feature.field)),
            _buildStatItem('Q3:', config.formatValue(stats.q3, feature.field)),
            _buildStatItem('IQR:', config.formatValue(stats.q3 - stats.q1, feature.field)),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildStatItem('Min:', config.formatValue(stats.min, feature.field)),
            _buildStatItem('Max:', config.formatValue(stats.max, feature.field)),
            _buildStatItem(
              'Выбросы:', 
              '${outliers.length} (${(outliers.length / stats.count * 100).toStringAsFixed(1)}%)'
            ),
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
  Widget _buildBoxPlotWithPoints(
    DescriptiveStats stats, 
    List<double> values, 
    BoxPlotFeature feature,
    List<double> outliers,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 100),
          painter: _BoxPlotPainter(
            stats: stats,
            values: values,
            outliers: outliers,
            config: config,
            feature: feature,
          ),
        );
      },
    );
  }

  /// Строит информацию о выбросах
  Widget _buildOutlierInfo(List<double> outliers, int totalCount) {
    if (outliers.isNotEmpty) {
      return Text(
        'Выбросы: ${outliers.length} записей (${(outliers.length / totalCount * 100).toStringAsFixed(1)}%)',
        style: TextStyle(
          fontSize: 11,
          color: Colors.orange[700],
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return const SizedBox();
  }

  /// Группирует данные по указанному полю
  Map<String, List<T>> _groupDataByFeature(String field) {
    final groups = <String, List<T>>{};
    
    for (final item in data) {
      final value = config.extractValue(item, field);
      if (value != null) {
        final groupKey = value.toString();
        groups.putIfAbsent(groupKey, () => []);
        groups[groupKey]!.add(item);
      }
    }
    
    return groups;
  }

  /// Извлекает значения для указанного поля
  List<double> _extractValues(List<T> dataList, String field, double divisor) {
    final values = <double>[];
    for (final item in dataList) {
      final value = config.extractValue(item, field);
      if (value != null && value.isFinite) {
        values.add(value / divisor);
      }
    }
    return values;
  }

  /// Находит выбросы в данных
  List<double> _findOutliers(DescriptiveStats stats, List<double> values) {
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    final upperBound = stats.q3 + 1.5 * iqr;
    
    return values.where((value) => value < lowerBound || value > upperBound).toList();
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

/// Box plot painter
class _BoxPlotPainter extends CustomPainter {
  /// Статистика данных
  final DescriptiveStats stats;

  /// Значения данных
  final List<double> values;

  /// Выбросы
  final List<double> outliers;

  /// Конфигурация box plot
  final BoxPlotConfig config;

  /// Признак для отображения
  final BoxPlotFeature feature;

  _BoxPlotPainter({
    required this.stats,
    required this.values,
    required this.outliers,
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

    // Нормализуем значения в диапазон графика
    double normalize(double value) {
      final range = stats.max - stats.min;
      if (range == 0) return plotWidth / 2 + padding;
      return ((value - stats.min) / range) * plotWidth + padding;
    }

    // Рассчитываем границы для определения выбросов
    final iqr = stats.q3 - stats.q1;
    final lowerBound = stats.q1 - 1.5 * iqr;
    final upperBound = stats.q3 + 1.5 * iqr;

    // Находим границы усов (самые крайние точки, не являющиеся выбросами)
    final whiskerLower = _getWhiskerLower(values, lowerBound);
    final whiskerUpper = _getWhiskerUpper(values, upperBound);

    // Рассчитываем позиции для рисования
    final xWhiskerLower = normalize(whiskerLower);
    final xWhiskerUpper = normalize(whiskerUpper);
    final xQ1 = normalize(stats.q1);
    final xQ3 = normalize(stats.q3);
    final xMedian = normalize(stats.median);
    final xLowerBound = normalize(lowerBound);
    final xUpperBound = normalize(upperBound);

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
      Offset(xWhiskerLower, centerY - 10),
      Offset(xWhiskerLower, centerY + 10),
      linePaint,
    );
    canvas.drawLine(
      Offset(xWhiskerUpper, centerY - 10),
      Offset(xWhiskerUpper, centerY + 10),
      linePaint,
    );

    // 4. Рисуем ящик (Q1 до Q3)
    final boxRect = Rect.fromLTRB(
      xQ1,
      centerY - 20,
      xQ3,
      centerY + 20,
    );
    canvas.drawRect(boxRect, boxPaint);
    canvas.drawRect(boxRect, boxBorderPaint);

    // 5. Рисуем медиану
    canvas.drawLine(
      Offset(xMedian, centerY - 20),
      Offset(xMedian, centerY + 20),
      medianPaint,
    );

    // 6. Рисуем только ВЫБРОСЫ
    _drawOutliers(canvas, outliers, normalize, outliersPaint, centerY);

    // 7. Добавляем подписи
    _drawLabel(canvas, xWhiskerLower, centerY + 35, 
               config.formatValue(whiskerLower, feature.field));
    _drawLabel(canvas, xWhiskerUpper, centerY + 35, 
               config.formatValue(whiskerUpper, feature.field));
    _drawLabel(canvas, xMedian, centerY - 35, 
               config.formatValue(stats.median, feature.field));

    // 8. Рисуем границы выбросов пунктирной линией (опционально)
    _drawOutlierBounds(canvas, xLowerBound, xUpperBound, centerY, size.height);
  }

  /// Рисует только выбросы (обычные точки не рисуются)
  void _drawOutliers(
    Canvas canvas, 
    List<double> outliers, 
    double Function(double) normalize, 
    Paint outliersPaint,
    double centerY,
  ) {
    final jitter = _JitterRandom();
    
    for (final outlier in outliers) {
      final x = normalize(outlier);
      
      // Добавляем небольшой вертикальный jitter для лучшей видимости перекрывающихся точек
      final jitterY = centerY + (jitter.nextDouble() * 8 - 4);
      
      canvas.drawCircle(
        Offset(x, jitterY),
        4.0,
        outliersPaint,
      );
    }
  }

  /// Рисует границы выбросов пунктирной линией
  void _drawOutlierBounds(
    Canvas canvas, 
    double xLowerBound, 
    double xUpperBound, 
    double centerY,
    double height,
  ) {
    final dashPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    
    // Пунктирный паттерн
    final dashPattern = [4.0, 4.0];
    
    // Рисуем левую границу выбросов
    _drawDashedLine(canvas, Offset(xLowerBound, 10), Offset(xLowerBound, height - 10), dashPaint, dashPattern);
    
    // Рисуем правую границу выбросов
    _drawDashedLine(canvas, Offset(xUpperBound, 10), Offset(xUpperBound, height - 10), dashPaint, dashPattern);
  }

  /// Рисует пунктирную линию
  void _drawDashedLine(
    Canvas canvas, 
    Offset start, 
    Offset end, 
    Paint paint, 
    List<double> dashPattern,
  ) {
    final distance = (end - start).distance; // Длина линии
    final dir = (end - start) / distance;
    
    double drawn = 0.0;
    bool draw = true; // Флаг: рисовать отрезок или пропускать
    int patternIndex = 0;  // Индекс в паттерне [длина_штриха, длина_пропуска]
    
    while (drawn < distance) {
      final patternLength = dashPattern[patternIndex % dashPattern.length];
      final endPoint = drawn + patternLength;
      
      if (draw) {
        final segmentEnd = start + dir * (endPoint < distance ? endPoint : distance);
        canvas.drawLine(start + dir * drawn, segmentEnd, paint);
      }
      
      drawn += patternLength; // Перемещаем позицию рисования
      draw = !draw; // Переключаем режим: штрих/пропуск
      patternIndex++; // Переходим к следующему элементу
    }
  }

  /// Находит нижнюю границу уса (минимальное значение, не являющееся выбросом)
  double _getWhiskerLower(List<double> values, double lowerBound) {
    // Фильтруем значения, которые больше или равны границе выбросов
    final nonOutliers = values.where((v) => v >= lowerBound).toList();
    return nonOutliers.isNotEmpty ? nonOutliers.reduce((a, b) => a < b ? a : b) : 
           values.reduce((a, b) => a < b ? a : b); // Если все значения - выбросы, берем абсолютный минимум
  }

  /// Находит верхнюю границу уса (максимальное значение, не являющееся выбросом)
  double _getWhiskerUpper(List<double> values, double upperBound) {
    final nonOutliers = values.where((v) => v <= upperBound).toList();
    return nonOutliers.isNotEmpty ? nonOutliers.reduce((a, b) => a > b ? a : b) : 
           values.reduce((a, b) => a > b ? a : b); // Если все значения - выбросы, берем абсолютный максимум
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