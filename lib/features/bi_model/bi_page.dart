import 'package:flutter/material.dart';

import '../../dataset/field_descriptor.dart';
import '../pair_plots/pair_plot.dart';
import '../pair_plots/pair_plot_config.dart';
import '../pair_plots/pair_plot_controller.dart';
import '../pair_plots/pair_plot_style.dart';
import 'bi_control_panel.dart';
import 'bi_model.dart';

class BIPage extends StatefulWidget {
  final BIModel model;
  final PairPlotController controller;

  const BIPage({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  State<BIPage> createState() => _BIPageState();
}

class _BIPageState extends State<BIPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.model,
      builder: (_, __) {
        final dataset = widget.model.dataset;

        return Row(
          children: [
            SizedBox(
              width: 280,
              child: BIControlPanel(
                dataset: dataset,
                model: widget.model,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: PairPlot(
                controller: widget.controller,
                config: PairPlotConfig(
                  fields: dataset.fields,
                  style: const PairPlotStyle(
                    dotSize: 4,
                    alpha: 0.7,
                    showCorrelation: true,
                    showHistDiagonal: true,
                    maxPoints: 200,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
