import 'package:flutter/material.dart';
import '../../dataset/dataset.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'pair_plot_matrix.dart';
import 'pair_plot_legend.dart';
import 'scales/categorical_color_scale.dart';

class PairPlot extends StatefulWidget {
  final Dataset dataset;
  final PairPlotConfig config;
  final PairPlotController controller;
  final Size cellSize;

  const PairPlot({
    super.key,
    required this.dataset,
    required this.config,
    required this.controller,
    this.cellSize = const Size(180, 180),
  });

  @override
  State<PairPlot> createState() => _PairPlotState();
}

class _PairPlotState extends State<PairPlot> {
  Map<String, Color>? _legend;

  @override
  void initState() {
    super.initState();
    _buildLegend();
  }

  @override
  void didUpdateWidget(covariant PairPlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.hue != widget.config.hue ||
        oldWidget.config.palette != widget.config.palette) {
      _buildLegend();
    }
  }

  void _buildLegend() {
    final hueField = widget.config.hue;
    if (hueField == null) {
      _legend = null;
      return;
    }

    final hueValues = widget.dataset.rows
        .map((row) => row[hueField.key])
        .where((v) => v != null)
        .map((v) => hueField.parseCategory(v))
        .whereType<String>()
        .toSet()
        .toList();

    if (hueValues.isEmpty) {
      _legend = null;
      return;
    }

    final colorScale = CategoricalColorScale.fromData(
      values: hueValues,
      palette: widget.config.palette ?? ColorPalette.defaultPalette,
      sort: (a, b) => a.compareTo(b),
      maxCategories: 6,
    );

    _legend = colorScale.legend;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_legend != null && _legend!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  PairPlotLegend(
                    legend: _legend!,
                    controller: widget.controller,
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: widget.cellSize.width * widget.config.fields.length,
                      child: PairPlotMatrix(
                        dataset: widget.dataset,
                        config: widget.config,
                        controller: widget.controller,
                        cellSize: widget.cellSize,
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