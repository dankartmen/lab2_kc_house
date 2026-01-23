import 'package:flutter/material.dart';
import '../../dataset/dataset.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'pair_plot_matrix.dart';
import 'pair_plot_legend.dart';

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
  late PairPlotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _initializeController();
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


  void _initializeController() {
    _controller.initialize(
      widget.dataset,
      widget.config.hue,
      widget.config.palette,
    );
  }

  void _buildLegend() {
    final hueField = widget.config.hue;
    if (hueField == null) {
      _legend = null;
      return;
    }

    final colorScale = _controller.colorScale;
    if (colorScale != null) {
      _legend = colorScale.legend;
    } else {
      _legend = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
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
                    controller: _controller,
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
                        controller: _controller,
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