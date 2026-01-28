import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../dataset/field_descriptor.dart';
import 'analysis/insight_engine.dart';
import 'config/pair_plot_config.dart';
import 'controller/pair_plot_controller.dart';
import 'ui/cells/hoverable_scatter_cell.dart';
import '../rendering/layout/plot_layout.dart';
import 'ui/tooltip/scatter_tooltip.dart';
import 'utils/plot_mapper.dart';

/// Fullscreen-экран анализа одной пары признаков
///
/// ВАЖНО:
/// - Здесь максимум информации
/// - В матрице — только обзор
class PairPlotDetailPage extends StatefulWidget {
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotController controller;
  final PairPlotConfig config;

  const PairPlotDetailPage({
    super.key,
    required this.x,
    required this.y,
    required this.controller,
    required this.config
  });

  @override
  State<PairPlotDetailPage> createState() => _PairPlotDetailPageState();
}

class _PairPlotDetailPageState extends State<PairPlotDetailPage> {
  final GlobalKey _repaintKey = GlobalKey();

  bool _useLogScale = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.getScatterData(
      widget.x,
      widget.y,
      computeCorrelation: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.x.label} × ${widget.y.label}'),
        actions: [
          _buildScaleToggle(),
          _buildExportMenu(data),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCorrelationExplanation(data.correlation),
            const SizedBox(height: 12),
            _buildHowToReadExplanation(data.correlation),
            const SizedBox(height: 12),
            _buildLegend(),
            const SizedBox(height: 12),
            Expanded(child: _buildPlot(data)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ГРАФИК
  // ------------------------------------------------------------

  Widget _buildPlot(data) {
    return RepaintBoundary(
      key: _repaintKey,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final plotLayout = PlotLayout(
            paddingLeft: 56,
            paddingBottom: 48,
          );

          final plotRect = plotLayout.plotRect(constraints.biggest);

          final xs = data.points.map((p) => p.x);
          final ys = data.points.map((p) => p.y);

          double mapValue(double v) {
            if (!_useLogScale) return v;
            return v > 0 ? log(v) : 0;
          }

          final mapper = PlotMapper(
            plotRect: plotRect,
            xMin: mapValue(xs.reduce((a, b) => a < b ? a : b)),
            xMax: mapValue(xs.reduce((a, b) => a > b ? a : b)),
            yMin: mapValue(ys.reduce((a, b) => a < b ? a : b)),
            yMax: mapValue(ys.reduce((a, b) => a > b ? a : b)),
          );

          final mappedData = data.copyMapped(mapValue);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              HoverableScatterCell(
                data: mappedData,
                mapper: mapper,
                x: widget.x,
                y: widget.y,
                style: widget.config.style,
                colorScale: widget.controller.colorScale,
                showXAxis: true,
                showYAxis: true,
                plotLayout: plotLayout,
                controller: widget.controller,
                filteredPoints: mappedData.points,
              ),

              AnimatedBuilder(
                animation: widget.controller.model,
                builder: (_, __) {
                  final row = widget.controller.model.hoveredRow;
                  if (row == null) return const SizedBox.shrink();

                  final point = mappedData.points
                      .firstWhere((p) => p.rowIndex == row);

                  final pos = mapper.map(point.x, point.y);

                  return Positioned(
                    left: pos.dx + 12,
                    top: pos.dy - 12,
                    child: ScatterTooltip(
                      point: point,
                      x: widget.x,
                      y: widget.y,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // ⑤.1 ЛЕГЕНДА
  // ------------------------------------------------------------

  Widget _buildLegend() {
    final scale = widget.controller.colorScale;
    if (scale == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      children: scale.categories.map((c) {
        final active = widget.controller.isCategoryVisible(c);

        return GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.toggleCategory(c);
            });
          },
          child: Opacity(
            opacity: active ? 1.0 : 0.3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: scale.colorOf(c),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(c),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  // ------------------------------------------------------------
  // ⑤.2 LOG / LINEAR
  // ------------------------------------------------------------

  Widget _buildScaleToggle() {
    return Row(
      children: [
        const Text('Log'),
        Switch(
          value: _useLogScale,
          onChanged: (v) => setState(() => _useLogScale = v),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ⑤.3 ОБЪЯСНЕНИЯ
  // ------------------------------------------------------------

  Widget _buildCorrelationExplanation(double? r) {
    if (r == null) {
      return const Text('Недостаточно данных для расчёта корреляции.');
    }

    final abs = r.abs();
    String strength;

    if (abs > 0.7) {
      strength = 'сильная';
    } else if (abs > 0.3) {
      strength = 'умеренная';
    } else {
      strength = 'слабая';
    }

    final direction = r > 0 ? 'положительная' : 'отрицательная';

    return Column(
      children: [
        Text(
          'Корреляция: r = ${r.toStringAsFixed(2)} — $strength $direction связь.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          InsightEngine.buildInsight(
            xLabel: widget.x.label,
            yLabel: widget.y.label,
            correlation: r,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),

      ],
    );
  }

  Widget _buildHowToReadExplanation(double? r) {
    if (r == null || r.abs() < 0.3) {
      return const Text(
        'Явной зависимости не наблюдается. '
        'Возможно, связь нелинейная или отсутствует.',
      );
    }

    return const Text(
      'Обратите внимание на направление тренда. '
      'Чем плотнее точки вдоль линии — тем сильнее связь. '
      'Выбросы могут искажать корреляцию.',
    );
  }

  // ------------------------------------------------------------
  // ⑤.4 ЭКСПОРТ
  // ------------------------------------------------------------

  Widget _buildExportMenu(data) {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        if (v == 'png') await _exportPNG();
        if (v == 'csv') await _exportCSV(data);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'png', child: Text('Экспорт PNG')),
        PopupMenuItem(value: 'csv', child: Text('Экспорт CSV')),
      ],
    );
  }

  Future<void> _exportPNG() async {
    final boundary =
        _repaintKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pair_plot.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _exportCSV(data) async {
    final buffer = StringBuffer('x,y\n');

    for (final p in data.points) {
      buffer.writeln('${p.x},${p.y}');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pair_plot.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)]);
  }
}
