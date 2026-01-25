import 'package:flutter/material.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'pair_plot_matrix.dart';
import 'pair_plot_legend.dart';

class PairPlot extends StatelessWidget {
  final PairPlotConfig config;
  final PairPlotController controller;
  final Size cellSize;

  const PairPlot({
    super.key,
    required this.config,
    required this.controller,
    this.cellSize = const Size(180, 180),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final legend = controller.colorScale?.legend;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (legend != null && controller.model.hueField != null) ...[
                  PairPlotLegend(
                    legend: legend,
                    model: controller.model,
                    field: controller.model.hueField!,
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: cellSize.width * config.fields.length,
                        height: cellSize.height * config.fields.length,
                        child: PairPlotMatrix(
                          config: config,
                          controller: controller,
                          cellSize: cellSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}