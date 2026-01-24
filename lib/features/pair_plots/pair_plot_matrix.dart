import 'package:flutter/material.dart';
import 'pair_plot_cell.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import '../../dataset/dataset.dart';

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
      itemBuilder: (_, index) {
        final row = index ~/ n;
        final col = index % n;

        return PairPlotCell(
          x: fields[col],
          y: fields[row],
          config: config,
          controller: controller,
          isDiagonal: row == col,
          showXAxis: col == 0,
          showYAxis: row == n - 1,
        );
      },
    );
  }
}