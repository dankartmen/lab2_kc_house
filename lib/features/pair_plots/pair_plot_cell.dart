import 'package:flutter/material.dart';
import '../../dataset/field_descriptor.dart';
import 'hoverable_scatter_cell.dart';
import 'layout/plot_layout.dart';
import 'painters/histogram_painter.dart';
import 'painters/categorical_histogram_painter.dart';
import 'painters/strip_plot_painter.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'utils/plot_mapper.dart';

class PairPlotCell extends StatelessWidget {
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotConfig config;
  final PairPlotController controller;
  final bool isDiagonal;
  final bool showXAxis;
  final bool showYAxis;

  const PairPlotCell({
    super.key,
    required this.x,
    required this.y,
    required this.config,
    required this.controller,
    this.isDiagonal = false,
    this.showXAxis = false,
    this.showYAxis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Основной график
          isDiagonal ? _buildDiagonal() : _buildOffDiagonal(),
          
          // Заголовок ячейки
          if (!isDiagonal) _buildCellHeader(),
          
          // Информационная иконка
          Positioned(
            top: 2,
            right: 2,
            child: Tooltip(
              message: _getCellDescription(),
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 5),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, size: 12, color: Colors.grey),
              ),
            ),
          ),
          
          // Статистика для диагональных ячеек
          if (isDiagonal && x.type == FieldType.continuous) _buildDistributionStats(),
        ],
      ),
    );
  }

  Widget _buildCellHeader() {
    if (isDiagonal) return const SizedBox.shrink();
    
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${x.label} × ${y.label}',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionStats() {
    final values = controller.getNumericValues(x);
    if (values.isEmpty) return const SizedBox.shrink();
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sorted = values.toList()..sort();
    final median = sorted[sorted.length ~/ 2];
    
    return Positioned(
      bottom: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('μ:', mean.toStringAsFixed(1)),
            _buildStatRow('M:', median.toStringAsFixed(1)),
            _buildStatRow('n:', values.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  String _getCellDescription() {
    if (isDiagonal) {
      if (x.type == FieldType.categorical) {
        return 'Гистограмма категорий "${x.label}"\nПоказывает частоту каждой категории';
      }
      return 'Распределение "${x.label}"\nПоказывает как распределены значения переменной';
    }
    
    if (x.type == FieldType.categorical && y.type == FieldType.categorical) {
      return 'Пересечение двух категориальных переменных\nИспользуйте другие графики для анализа';
    }
    
    if (x.type == FieldType.categorical || y.type == FieldType.categorical) {
      return 'Стрипплот (Strip Plot)\nПоказывает распределение числовой переменной по категориям\nТочки слегка разбросаны по горизонтали для лучшей видимости';
    }
    
    final correlation = controller.getScatterData(x, y, computeCorrelation: true).correlation;
    String correlationDesc = '';
    
    if (correlation != null) {
      final absCorr = correlation.abs();
      if (absCorr > 0.7) {
        correlationDesc = 'Сильная ${correlation > 0 ? 'положительная' : 'отрицательная'} связь';
      } else if (absCorr > 0.3) {
        correlationDesc = 'Умеренная ${correlation > 0 ? 'положительная' : 'отрицательная'} связь';
      } else {
        correlationDesc = 'Слабая или отсутствующая линейная связь';
      }
    }
    
    return 'Диаграмма рассеяния\n'
        'Показывает взаимосвязь между "${x.label}" и "${y.label}"\n'
        '${correlation != null ? 'Коэффициент корреляции: ${correlation.toStringAsFixed(2)}\n$correlationDesc' : ''}\n'
        'Наведите курсор на точку для деталей';
  }

  Widget _buildDiagonal() {
    if (x.type == FieldType.categorical) return _buildCategoricalHistogram();
    if (!config.style.showHistDiagonal) return _emptyWithDescription('—', 'Распределение скрыто в настройках');

    final values = controller.getNumericValues(x);
    if (values.isEmpty) return _emptyWithDescription('Нет данных', 'Нет числовых значений для отображения');

    return LayoutBuilder(
      builder: (_, constraints) {
        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: HistogramPainter(values: values, label: x.label),
                size: constraints.biggest,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                x.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoricalHistogram() {
    final values = controller.getCategoricalValues(x);
    if (values.isEmpty) return _emptyWithDescription('Нет данных', 'Нет категориальных значений');

    return LayoutBuilder(
      builder: (_, constraints) {
        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: CategoricalHistogramPainter(
                  values: values,
                  colorScale: controller.colorScale,
                ),
                size: constraints.biggest,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                x.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOffDiagonal() {
    if (x.type == FieldType.categorical && y.type == FieldType.categorical) {
      return _emptyWithDescription(
        'N/A',
        'Для анализа двух категориальных переменных\nиспользуйте таблицы сопряженности или мозаичные графики',
      );
    }
    
    if (x.type == FieldType.categorical || y.type == FieldType.categorical) {
      return _buildCategoricalNumeric();
    }
    
    return _buildScatter();
  }

  Widget _buildScatter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final data = controller.getScatterData(
          x,
          y,
          computeCorrelation: config.style.showCorrelation,
        );
        
        if (data.points.isEmpty) {
          return _emptyWithDescription(
            'Нет данных',
            'Нет общих значений для "${x.label}" и "${y.label}"\n'
            'или все данные отфильтрованы',
          );
        }

        final plotLayout = PlotLayout();
        final plotRect = plotLayout.plotRect(constraints.biggest);

        final xs = data.points.map((p) => p.x);
        final ys = data.points.map((p) => p.y);

        final mapper = PlotMapper(
          plotRect: plotRect,
          xMin: xs.reduce((a, b) => a < b ? a : b),
          xMax: xs.reduce((a, b) => a > b ? a : b),
          yMin: ys.reduce((a, b) => a < b ? a : b),
          yMax: ys.reduce((a, b) => a > b ? a : b),
        );

        // Показать коэффициент корреляции
        Widget correlationIndicator = const SizedBox.shrink();
        if (data.correlation != null) {
          correlationIndicator = Positioned(
            top: 20,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getCorrelationColor(data.correlation!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'r = ${data.correlation!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            HoverableScatterCell(
              data: data,
              mapper: mapper,
              x: x,
              y: y,
              style: config.style,
              colorScale: controller.colorScale,
              showXAxis: showXAxis,
              showYAxis: showYAxis,
              plotLayout: plotLayout,
              controller: controller,
              filteredPoints: data.points,
            ),
            correlationIndicator,
          ],
        );
      },
    );
  }

  Color _getCorrelationColor(double correlation) {
    final absCorr = correlation.abs();
    if (absCorr > 0.7) return Colors.red;
    if (absCorr > 0.3) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildCategoricalNumeric() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isXCat = x.type == FieldType.categorical;
        final catField = isXCat ? x : y;
        final numField = isXCat ? y : x;

        final rows = controller.visibleRowsFor(catField, numField);
        if (rows.isEmpty) {
          return _emptyWithDescription(
            'Нет данных',
            'Нет общих значений для "${catField.label}" и "${numField.label}"',
          );
        }

        final categories = rows
            .map((r) => catField.parseCategory(r[catField.key]))
            .whereType<String>()
            .toSet()
            .toList();

        final plotRect = PlotLayout().plotRect(constraints.biggest);

        return Stack(
          children: [
            CustomPaint(
              painter: StripPlotPainter(
                rows: rows,
                catField: catField,
                numField: numField,
                categories: categories,
                plotRect: plotRect,
                colorScale: controller.colorScale,
                isVertical: isXCat,
                controller: controller,
              ),
              size: constraints.biggest,
            ),
          ],
        );
      },
    );
  }

  Widget _emptyWithDescription(String title, String description) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      );
}