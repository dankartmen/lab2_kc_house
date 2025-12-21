import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/data/data_model.dart';
import 'pair_plot_config.dart';

/// Виджет для создания парных диаграмм (аналог seaborn.pairplot)
class PairPlot<T extends DataModel> extends StatelessWidget {
  final List<T> data;
  final PairPlotConfig<T> config;
  final String title;
  final PairPlotStyle style;
  final Size plotSize;

  const PairPlot({
    super.key,
    required this.data,
    required this.config,
    required this.title,
    this.style = const PairPlotStyle(),
    this.plotSize = const Size(200, 200),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            style.simplified 
                ? _buildSimplifiedMatrix()
                : _buildMatrix(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrix() {
    final fields = config.numericFields;
    final n = fields.length;

    return Column(
      children: List.generate(n, (row) {
        return Row(
          children: List.generate(n, (col) {
            return _buildPlotCell(
              fields[row],
              fields[col],
              row == col,
              row,
              col,
            );
          }),
        );
      }),
    );
  }

  Widget _buildSimplifiedMatrix() {
    final fields = config.numericFields;
    final displayFields = fields.length > 6 ? fields.sublist(0, 6) : fields;
    final displayN = displayFields.length;

    final dataCache = <String, List<double>>{};
    for (final field in displayFields) {
      dataCache[field] = _extractValues(field);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовки столбцов
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 8),
              child: Row(
                children: displayFields.map((field) {
                  return SizedBox(
                    width: plotSize.width,
                    child: Text(
                      _getShortFieldName(field),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Матрица графиков
            for (int row = 0; row < displayN; row++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: plotSize.height,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          _getShortFieldName(displayFields[row]),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  for (int col = 0; col < displayN; col++)
                    _buildPlotCell(
                      displayFields[col],
                      displayFields[row],
                      col == row,
                      col,
                      row,
                      dataCache: dataCache,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlotCell(
    String xField,
    String yField,
    bool isDiagonal,
    int row,
    int col, {
    Map<String, List<double>>? dataCache,
  }) {
    final xValues = dataCache?[xField] ?? _extractValues(xField);
    final yValues = dataCache?[yField] ?? _extractValues(yField);
    
    if (style.simplified && !isDiagonal) {
      final limitedXValues = _limitPoints(xValues);
      final limitedYValues = _limitPoints(yValues);
      
      return Container(
        width: plotSize.width,
        height: plotSize.height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: isDiagonal 
            ? _buildDiagonalPlot(xField, xValues)
            : _buildScatterPlot(xField, yField, limitedXValues, limitedYValues),
      );
    }
    
    return Container(
      width: plotSize.width,
      height: plotSize.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: isDiagonal 
          ? _buildDiagonalPlot(xField, xValues)
          : _buildScatterPlot(xField, yField, xValues, yValues),
    );
  }

  Widget _buildDiagonalPlot(String field, List<double> values) {
    if (values.isEmpty) {
      return _buildEmptyPlot('Нет данных');
    }

    if (style.simplified) {
      return Stack(
        children: [
          _buildHistogram(values, field),
          _buildFieldLabel(field),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: HistogramPainter(
            values: values,
            style: style,
            fieldName: field,
          ),
        );
      },
    );
  }

  Widget _buildScatterPlot(
    String xField,
    String yField,
    List<double> xValues,
    List<double> yValues,
  ) {
    if (xValues.isEmpty || yValues.isEmpty) {
      return _buildEmptyPlot('Нет данных');
    }

    if (style.simplified) {
      return Stack(
        children: [
          _buildScatterChart(xValues, yValues, xField, yField),
          if (style.showCorrelation)
            Positioned(
              top: 2,
              right: 2,
              child: _buildCorrelationBadge(xValues, yValues),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: ScatterPlotPainter(
            xValues: xValues,
            yValues: yValues,
            xField: xField,
            yField: yField,
            style: style,
            hueValues: config.hueField != null 
                ? _extractHueValues(config.hueField!)
                : null,
            palette: config.palette,
          ),
        );
      },
    );
  }

  Widget _buildHistogram(List<double> values, String field) {
    return CustomPaint(
      size: plotSize,
      painter: _HistogramPainter(
        values: values,
        fieldName: field,
        color: _getFieldColor(field),
      ),
    );
  }

  Widget _buildScatterChart(
    List<double> xValues,
    List<double> yValues,
    String xField,
    String yField,
  ) {
    return CustomPaint(
      size: plotSize,
      painter: _ScatterPainter(
        xValues: xValues,
        yValues: yValues,
        color: Colors.blue.withOpacity(style.alpha),
      ),
    );
  }

  Widget _buildCorrelationBadge(List<double> xValues, List<double> yValues) {
    final correlation = _calculateCorrelation(xValues, yValues);
    final absCorrelation = correlation.abs();
    
    Color color;
    if (absCorrelation > 0.7) {
      color = Colors.red;
    } else if (absCorrelation > 0.5) {
      color = Colors.orange;
    } else if (absCorrelation > 0.3) {
      color = Colors.yellow[700]!;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        'r=${correlation.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 7,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String field) {
    return Positioned(
      bottom: 2,
      left: 2,
      right: 2,
      child: Text(
        _getShortFieldName(field),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 8,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEmptyPlot(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: style.simplified ? 9 : 10,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  List<double> _extractValues(String field) {
    return data
        .map((item) => item.getNumericValue(field))
        .where((value) => value != null && value.isFinite)
        .cast<double>()
        .toList();
  }

  List<String>? _extractHueValues(String field) {
    return data.map((item) {
      final value = item.getNumericValue(field);
      return value != null ? value.toString() : '';
    }).where((value) => value.isNotEmpty).toList();
  }

  List<double> _limitPoints(List<double> values) {
    if (values.length <= style.maxPoints) return values;
    
    final step = values.length / style.maxPoints;
    return List.generate(style.maxPoints, (i) {
      final index = (i * step).round();
      return values[index.clamp(0, values.length - 1)];
    });
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    final n = min(x.length, y.length);
    if (n < 2) return 0.0;
    
    if (style.simplified) {
      final sampleSize = min(100, n);
      final step = n / sampleSize;
      
      double sumX = 0, sumY = 0, sumXY = 0;
      double sumX2 = 0, sumY2 = 0;
      
      for (int i = 0; i < sampleSize; i++) {
        final index = (i * step).round().clamp(0, n - 1);
        final xi = x[index];
        final yi = y[index];
        
        sumX += xi;
        sumY += yi;
        sumXY += xi * yi;
        sumX2 += xi * xi;
        sumY2 += yi * yi;
      }
      
      final numerator = sampleSize * sumXY - sumX * sumY;
      final denominator = sqrt((sampleSize * sumX2 - sumX * sumX) * 
                             (sampleSize * sumY2 - sumY * sumY));
      
      return denominator == 0 ? 0.0 : numerator / denominator;
    }
    
    double sumX = 0, sumY = 0, sumXY = 0;
    double sumX2 = 0, sumY2 = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }
    
    final numerator = n * sumXY - sumX * sumY;
    final denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    
    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  Color _getFieldColor(String field) {
    final fieldColors = {
      'age': Colors.blue,
      'cholesterol': Colors.red,
      'bmi': Colors.green,
      'heartRate': Colors.orange,
      'stressLevel': Colors.purple,
      'triglycerides': Colors.brown,
      'exerciseHoursPerWeek': Colors.teal,
      'sedentaryHoursPerDay': Colors.blueGrey,
      'income': Colors.amber,
      'physicalActivityDaysPerWeek': Colors.lightGreen,
      'sleepHoursPerDay': Colors.indigo,
      'heartAttackRisk': Colors.redAccent,
    };
    
    return fieldColors[field] ?? Colors.blue;
  }

  String _getShortFieldName(String field) {
    final shortNames = {
      'age': 'Возраст',
      'cholesterol': 'Холест.',
      'bmi': 'ИМТ',
      'heartRate': 'Пульс',
      'stressLevel': 'Стресс',
      'triglycerides': 'Триглиц.',
      'exerciseHoursPerWeek': 'Спорт',
      'sedentaryHoursPerDay': 'Сидячий',
      'income': 'Доход',
      'physicalActivityDaysPerWeek': 'Активность',
      'sleepHoursPerDay': 'Сон',
      'heartAttackRisk': 'Риск',
    };
    
    return shortNames[field] ?? field.substring(0, min(8, field.length));
  }
}

// Painter для гистограмм (полная версия)
class HistogramPainter extends CustomPainter {
  final List<double> values;
  final PairPlotStyle style;
  final String fieldName;

  HistogramPainter({
    required this.values,
    required this.style,
    required this.fieldName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final sortedValues = List<double>.from(values)..sort();
    final minVal = sortedValues.first;
    final maxVal = sortedValues.last;
    
    final binCount = 20;
    final bins = _createHistogram(values, binCount, minVal, maxVal);
    final maxCount = bins.values.reduce(max).toDouble();

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final barPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final barWidth = size.width / binCount * 0.8;
    final scaleY = size.height * 0.8 / maxCount;

    bins.forEach((bin, count) {
      final barHeight = count * scaleY;
      final x = bin * (size.width / binCount) + size.width / binCount * 0.1;
      final y = size.height - barHeight;
      
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        barPaint,
      );
      
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        borderPaint,
      );
    });

    final textPainter = TextPainter(
      text: TextSpan(
        text: fieldName,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, 4),
    );
  }

  @override
  bool shouldRepaint(covariant HistogramPainter oldDelegate) =>
      values != oldDelegate.values ||
      style != oldDelegate.style ||
      fieldName != oldDelegate.fieldName;

  Map<int, int> _createHistogram(
    List<double> values, 
    int binCount, 
    double minVal, 
    double maxVal
  ) {
    final bins = <int, int>{};
    for (int i = 0; i < binCount; i++) {
      bins[i] = 0;
    }

    final range = maxVal - minVal;
    for (final value in values) {
      if (range == 0) {
        bins[0] = bins[0]! + 1;
      } else {
        final binIndex = ((value - minVal) / range * (binCount - 1))
            .clamp(0, binCount - 1).toInt();
        bins[binIndex] = bins[binIndex]! + 1;
      }
    }

    return bins;
  }
}

// Painter для точечных диаграмм (полная версия)
class ScatterPlotPainter extends CustomPainter {
  final List<double> xValues;
  final List<double> yValues;
  final String xField;
  final String yField;
  final PairPlotStyle style;
  final List<String>? hueValues;
  final ColorPalette? palette;

  ScatterPlotPainter({
    required this.xValues,
    required this.yValues,
    required this.xField,
    required this.yField,
    required this.style,
    this.hueValues,
    this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (xValues.isEmpty || yValues.isEmpty) return;

    final xSorted = List<double>.from(xValues)..sort();
    final ySorted = List<double>.from(yValues)..sort();
    
    final xMin = xSorted.first;
    final xMax = xSorted.last;
    final yMin = ySorted.first;
    final yMax = ySorted.last;
    
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    Offset dataToPoint(double x, double y) {
      final xPos = (x - xMin) / (xMax - xMin) * size.width * 0.9 + size.width * 0.05;
      final yPos = size.height - ((y - yMin) / (yMax - yMin) * size.height * 0.9 + size.height * 0.05);
      return Offset(xPos, yPos);
    }

    for (int i = 0; i < min(xValues.length, yValues.length); i++) {
      final color = _getPointColor(i);
      final pointPaint = Paint()
        ..color = color.withOpacity(style.alpha)
        ..style = PaintingStyle.fill;
      
      final point = dataToPoint(xValues[i], yValues[i]);
      canvas.drawCircle(point, style.dotSize, pointPaint);
    }

    if (style.showCorrelation) {
      final correlation = _calculateCorrelation(xValues, yValues);
      final text = 'r = ${correlation.toStringAsFixed(2)}';
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 4, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScatterPlotPainter oldDelegate) =>
      xValues != oldDelegate.xValues ||
      yValues != oldDelegate.yValues ||
      style != oldDelegate.style ||
      hueValues != oldDelegate.hueValues;

  Color _getPointColor(int index) {
    if (hueValues == null || hueValues!.length <= index) {
      return Colors.blue;
    }

    final hueValue = hueValues![index];
    final uniqueValues = hueValues!.toSet().toList();
    final hueIndex = uniqueValues.indexOf(hueValue);

    switch (palette ?? ColorPalette.defaultPalette) {
      case ColorPalette.categorical:
        return _categoricalColors[hueIndex % _categoricalColors.length];
      case ColorPalette.sequential:
        return HSVColor.fromAHSV(1.0, 240 - (hueIndex * 60.0 / uniqueValues.length), 0.8, 0.8).toColor();
      case ColorPalette.diverging:
        return _divergingColors[hueIndex % _divergingColors.length];
      default:
        return Colors.blue;
    }
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    final n = min(x.length, y.length);
    if (n < 2) return 0.0;
    
    double sumX = 0, sumY = 0, sumXY = 0;
    double sumX2 = 0, sumY2 = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }
    
    final numerator = n * sumXY - sumX * sumY;
    final denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    
    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  static const _categoricalColors = [
    Color(0xFF1F77B4),
    Color(0xFFFF7F0E),
    Color(0xFF2CA02C),
    Color(0xFFD62728),
    Color(0xFF9467BD),
    Color(0xFF8C564B),
    Color(0xFFE377C2),
    Color(0xFF7F7F7F),
    Color(0xFFBCBD22),
    Color(0xFF17BECF),
  ];

  static const _divergingColors = [
    Color(0xFF313695),
    Color(0xFF4575B4),
    Color(0xFF74ADD1),
    Color(0xFFABD9E9),
    Color(0xFFE0F3F8),
    Color(0xFFFEE090),
    Color(0xFFFDAE61),
    Color(0xFFF46D43),
    Color(0xFFD73027),
    Color(0xFFA50026),
  ];
}

// Упрощенные painter (используются при simplified = true)
class _HistogramPainter extends CustomPainter {
  final List<double> values;
  final String fieldName;
  final Color color;

  _HistogramPainter({
    required this.values,
    required this.fieldName,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final sorted = List<double>.from(values)..sort();
    final minVal = sorted.first;
    final maxVal = sorted.last;
    
    const binCount = 10;
    final bins = _createBins(values, binCount, minVal, maxVal);
    final maxCount = bins.values.reduce(max).toDouble();

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final barPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final barWidth = size.width / binCount * 0.8;
    final scaleY = size.height * 0.8 / maxCount;

    for (int i = 0; i < binCount; i++) {
      final count = bins[i] ?? 0;
      if (count == 0) continue;
      
      final barHeight = count * scaleY;
      final x = i * (size.width / binCount) + size.width / binCount * 0.1;
      final y = size.height - barHeight;
      
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        barPaint,
      );
    }
  }

  Map<int, int> _createBins(
    List<double> values, 
    int binCount, 
    double minVal, 
    double maxVal
  ) {
    final bins = <int, int>{};
    for (int i = 0; i < binCount; i++) {
      bins[i] = 0;
    }

    final range = maxVal - minVal;
    if (range == 0) {
      bins[0] = values.length;
      return bins;
    }

    for (final value in values) {
      final binIndex = ((value - minVal) / range * (binCount - 1))
          .clamp(0, binCount - 1).toInt();
      bins[binIndex] = bins[binIndex]! + 1;
    }

    return bins;
  }

  @override
  bool shouldRepaint(covariant _HistogramPainter oldDelegate) =>
      values != oldDelegate.values || 
      fieldName != oldDelegate.fieldName;
}

class _ScatterPainter extends CustomPainter {
  final List<double> xValues;
  final List<double> yValues;
  final Color color;

  _ScatterPainter({
    required this.xValues,
    required this.yValues,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (xValues.isEmpty || yValues.isEmpty) return;

    final n = min(xValues.length, yValues.length);
    
    double xMin = xValues[0], xMax = xValues[0];
    double yMin = yValues[0], yMax = yValues[0];
    
    for (int i = 0; i < n; i++) {
      xMin = min(xMin, xValues[i]);
      xMax = max(xMax, xValues[i]);
      yMin = min(yMin, yValues[i]);
      yMax = max(yMax, yValues[i]);
    }
    
    final xRange = xMax - xMin;
    final yRange = yMax - yMin;
    xMin -= xRange * 0.05;
    xMax += xRange * 0.05;
    yMin -= yRange * 0.05;
    yMax += yRange * 0.05;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset dataToPoint(double x, double y) {
      final xPos = (x - xMin) / (xMax - xMin) * size.width;
      final yPos = size.height - (y - yMin) / (yMax - yMin) * size.height;
      return Offset(xPos, yPos);
    }

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final drawStep = max(1, n ~/ 200);
    for (int i = 0; i < n; i += drawStep) {
      final point = dataToPoint(xValues[i], yValues[i]);
      canvas.drawCircle(point, 1.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScatterPainter oldDelegate) =>
      xValues != oldDelegate.xValues || 
      yValues != oldDelegate.yValues;
}