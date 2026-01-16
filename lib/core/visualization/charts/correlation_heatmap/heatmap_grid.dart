import 'package:flutter/material.dart';

import 'correlation_color_scale.dart';

/// Сетка тепловой карты
class HeatmapGrid extends StatelessWidget {
  /// Матрица корреляции
  final Map<String, Map<String, double>> matrix;

  /// Размеры ячеек (НЕ масштабируются вручную)
  static const double cellWidth = 60;
  static const double cellHeight = 40;
  static const double headerWidth = 80;

  const HeatmapGrid({required this.matrix, super.key});

  @override
  Widget build(BuildContext context) {
    final labels = matrix.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeaders(labels),
        ...labels.map((row) => _buildRow(row, labels)),
      ],
    );
  }

  /// Заголовки столбцов
  Widget _buildColumnHeaders(List<String> labels) {
    return Row(
      children: [
        const SizedBox(width: headerWidth),
        ...labels.map(
          (label) => _HeaderCell(
            width: cellWidth,
            height: 30,
            text: label,
          ),
        ),
      ],
    );
  }

  /// Строка тепловой карты
  Widget _buildRow(String rowLabel, List<String> labels) {
    return Row(
      children: [
        _HeaderCell(
          width: headerWidth,
          height: cellHeight,
          text: rowLabel,
          alignRight: true,
        ),
        ...labels.map((col) {
          final value = matrix[rowLabel]?[col] ?? 0.0;
          return _HeatmapCell(value: value);
        }),
      ],
    );
  }
}

/// Ячейка заголовка
class _HeaderCell extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final bool alignRight;

  const _HeaderCell({
    required this.width,
    required this.height,
    required this.text,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignRight ? Alignment.centerRight : Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        _shorten(text),
        maxLines: 2,
        textAlign: alignRight ? TextAlign.right : TextAlign.center,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Укорачивание длинных подписей
  String _shorten(String text) {
    if (text.length <= 10) return text;
    return '${text.substring(0, 9)}…';
  }
}

/// Ячейка тепловой карты
class _HeatmapCell extends StatelessWidget {
  final double value;

  const _HeatmapCell({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = _colorForValue(value);
    final textColor = value.abs() > 0.4 ? Colors.white : Colors.black;

    return Container(
      width: HeatmapGrid.cellWidth,
      height: HeatmapGrid.cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value.toStringAsFixed(2),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// Цвет по значению корреляции
  Color _colorForValue(double v) {
    return correlationColorScale.firstWhere((range) => range.contains(v)).color;
  }
}