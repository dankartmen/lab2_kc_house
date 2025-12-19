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
  final int maxPointsPerPlot; 
  final bool showCorrelation;

  const PairPlot({
    super.key,
    required this.data,
    required this.config,
    required this.title,
    this.style = const PairPlotStyle(),
    this.plotSize = const Size(200, 200),
    this.maxPointsPerPlot = 1000,
    this.showCorrelation = true,
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
            _buildPairPlotMatrix(),
          ],
        ),
      ),
    );
  }

  Widget _buildPairPlotMatrix() {
    final fields = config.numericFields;
    final n = fields.length;

    // Заранее кэшируем все значения
    final valueCache = _createValueCache(fields);

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
                children: fields.map((field) {
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
            ...List.generate(n, (row) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок строки
                  SizedBox(
                    width: 40,
                    height: plotSize.height,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          _getShortFieldName(fields[row]),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Графики в строке
                  ...List.generate(n, (col) {
                    return _buildPlotCell(
                      fields[col], // X
                      fields[row], // Y
                      col == row,
                      valueCache[fields[col]] ?? [],
                      valueCache[fields[row]] ?? [],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlotCell(String xField, String yField, bool isDiagonal, List<double> xValues, List<double> yValues) {
    return Container(
      width: plotSize.width,
      height: plotSize.height,
      padding: const EdgeInsets.all(2),
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

    // Гистограмма на диагонали
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

  Widget _buildScatterPlot(String xField, String yField, List<double> xValues, List<double> yValues) {
    if (xValues.isEmpty || yValues.isEmpty) {
      return _buildEmptyPlot('Нет данных');
    }

    // Парный точечный график
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
            showCorrelation: showCorrelation,
          ),
        );
      },
    );
  }

  Map<String, List<double>> _createValueCache(List<String> fields) {
    final cache = <String, List<double>>{};
    
    for (final field in fields) {
      final values = data
          .map((item) => item.getNumericValue(field))
          .where((value) => value != null && value.isFinite)
          .cast<double>()
          .toList();
      cache[field] = values;
    }
    
    return cache;
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
    
    return shortNames[field] ?? (field.length > 10 ? '${field.substring(0, 10)}.' : field);
  }

  List<String>? _extractHueValues(String field) {
    // Извлекаем значения для цветовой группировки
    return data.map((item) {
      final value = item.getNumericValue(field);
      return value != null ? value.toString() : '';
    }).where((value) => value.isNotEmpty).toList();
  }

  Widget _buildEmptyPlot(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 8,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}

// Painter для гистограмм на диагонали
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
    
    // Вычисляем гистограмму
    final binCount = 20;
    final bins = _createHistogram(values, binCount, minVal, maxVal);
    final maxCount = bins.values.reduce(max).toDouble();

    // Очищаем фон
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Рисуем гистограмму
    final barPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.9)
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

    // Подпись поля
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
        final binIndex = ((value - minVal) / range * (binCount - 1)).clamp(0, binCount - 1).toInt();
        bins[binIndex] = bins[binIndex]! + 1;
      }
    }

    return bins;
  }
}

// Painter для точечных диаграмм
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

    // Подготовка данных
    final xSorted = List<double>.from(xValues)..sort();
    final ySorted = List<double>.from(yValues)..sort();
    
    final xMin = xSorted.first;
    final xMax = xSorted.last;
    final yMin = ySorted.first;
    final yMax = ySorted.last;
    
    // Очищаем фон
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Рисуем сетку
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Вертикальные линии
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // Горизонтальные линии
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Функция преобразования данных в координаты
    Offset dataToPoint(double x, double y) {
      final xPos = (x - xMin) / (xMax - xMin) * size.width * 0.9 + size.width * 0.05;
      final yPos = size.height - ((y - yMin) / (yMax - yMin) * size.height * 0.9 + size.height * 0.05);
      return Offset(xPos, yPos);
    }

    // Рисуем точки
    for (int i = 0; i < min(xValues.length, yValues.length); i++) {
      final color = _getPointColor(i);
      final pointPaint = Paint()
        ..color = color.withValues(alpha: style.alpha)
        ..style = PaintingStyle.fill;
      
      final point = dataToPoint(xValues[i], yValues[i]);
      canvas.drawCircle(point, style.dotSize, pointPaint);
    }

    // Показываем коэффициент корреляции если нужно
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
      return Colors.blue; // Цвет по умолчанию
    }

    final hueValue = hueValues![index];
    final uniqueValues = hueValues!.toSet().toList();
    final hueIndex = uniqueValues.indexOf(hueValue);

    // Выбор цветовой палитры
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

  // Цвета для категориальной палитры
  static const _categoricalColors = [
    Color(0xFF1F77B4), // синий
    Color(0xFFFF7F0E), // оранжевый
    Color(0xFF2CA02C), // зеленый
    Color(0xFFD62728), // красный
    Color(0xFF9467BD), // фиолетовый
    Color(0xFF8C564B), // коричневый
    Color(0xFFE377C2), // розовый
    Color(0xFF7F7F7F), // серый
    Color(0xFFBCBD22), // желто-зеленый
    Color(0xFF17BECF), // бирюзовый
  ];

  static const _divergingColors = [
    Color(0xFF313695), // темно-синий
    Color(0xFF4575B4), // синий
    Color(0xFF74ADD1), // светло-синий
    Color(0xFFABD9E9), // очень светло-синий
    Color(0xFFE0F3F8), // почти белый
    Color(0xFFFEE090), // светло-желтый
    Color(0xFFFDAE61), // оранжевый
    Color(0xFFF46D43), // красно-оранжевый
    Color(0xFFD73027), // красный
    Color(0xFFA50026), // темно-красный
  ];
}