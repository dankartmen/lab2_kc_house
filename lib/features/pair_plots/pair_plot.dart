import 'package:flutter/material.dart';
import 'config/pair_plot_config.dart';
import 'controller/pair_plot_controller.dart';
import 'ui/pair_plot_matrix.dart';
import 'ui/legend/pair_plot_legend.dart';

class PairPlot extends StatelessWidget {
  final PairPlotConfig config;
  final PairPlotController controller;

  const PairPlot({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final legend = controller.colorScale?.legend;

        return LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = _computeCellSize(constraints.maxWidth);

            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (legend != null && controller.model.hueField != null) ...[
                      PairPlotLegend(
                        scale: controller.colorScale!,
                        fieldLabel: controller.model.hueField!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: PairPlotMatrix(
                          config: config,
                          controller: controller,
                          cellSize: cellSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Умный расчёт размера ячейки
  Size _computeCellSize(double availableWidth) {
    const min = 140.0;
    const max = 240.0;

    final columns = 3; // средняя плотность
    final raw = availableWidth / columns;

    final clamped = raw.clamp(min, max);

    return Size(clamped, clamped);
  }
}
