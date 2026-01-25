import 'package:flutter/material.dart';
import 'pair_plot_cell.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import '../../dataset/field_descriptor.dart';

class PairPlotMatrix extends StatelessWidget {
  final PairPlotConfig config;
  final PairPlotController controller;
  final Size cellSize;

  const PairPlotMatrix({
    super.key,
    required this.config,
    required this.controller,
    required this.cellSize,
  });

  bool _hasData(FieldDescriptor x, FieldDescriptor y) {
    // Диагональ
    if (x == y) {
      if (x.type == FieldType.continuous) {
        return controller.getNumericValues(x).isNotEmpty;
      }
      if (x.type == FieldType.categorical) {
        return controller.getCategoricalValues(x).isNotEmpty;
      }
      return false;
    }

    // Две категориальные — не рисуем
    if (x.type == FieldType.categorical &&
        y.type == FieldType.categorical) {
      return false;
    }

    // Scatter
    if (x.type == FieldType.continuous &&
        y.type == FieldType.continuous) {
      return controller.getScatterData(x, y).points.isNotEmpty;
    }

    // Strip plot
    final cat = x.type == FieldType.categorical ? x : y;
    final num = x.type == FieldType.categorical ? y : x;

    return controller
        .visibleRowsFor(cat, num)
        .isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final fields = config.fields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((y) {
        // Все валидные X для текущего Y
        final validX = fields.where((x) => _hasData(x, y)).toList();

        if (validX.isEmpty) {
          // Если для этой строки вообще нет данных — строку не рисуем
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: validX.map((x) {
            final isDiagonal = x == y;

            return SizedBox(
              width: cellSize.width,
              height: cellSize.height,
              child: PairPlotCell(
                x: x,
                y: y,
                config: config,
                controller: controller,
                isDiagonal: isDiagonal,
                showXAxis: true,
                showYAxis: true,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
