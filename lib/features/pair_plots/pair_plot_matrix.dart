import 'package:flutter/material.dart';
import 'pair_plot_cell.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import '../../dataset/dataset.dart';

class PairPlotMatrix extends StatelessWidget {
  final Dataset dataset;
  final PairPlotConfig config;
  final PairPlotController controller;
  final Size cellSize;

  const PairPlotMatrix({
    super.key,
    required this.dataset,
    required this.config,
    required this.controller,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    final fields = config.fields;
    final n = fields.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: n,
        childAspectRatio: cellSize.width / cellSize.height,
      ),
      itemCount: n * n,
      itemBuilder: (context, index) {
        final row = index ~/ n;
        final col = index % n;

        final x = fields[col];
        final y = fields[row];
        final isDiagonal = row == col;

        // Определяем, нужно ли рисовать оси
        final showYAxis = col == 0;
        final showXAxis = row == n - 1;

        return PairPlotCell(
          dataset: dataset,
          x: x,
          y: y,
          config: config,
          controller: controller,
          isDiagonal: isDiagonal,
          showXAxis: showXAxis,
          showYAxis: showYAxis,
        );
      },
    );
  }
}