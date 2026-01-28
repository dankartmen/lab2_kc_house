import 'package:flutter/material.dart';
import '../pair_plots/pair_plot.dart';
import '../pair_plots/config/pair_plot_config.dart';
import '../pair_plots/config/pair_plot_style.dart';
import '../pair_plots/controller/pair_plot_controller.dart';
import 'bi_control_panel.dart';
import 'bi_model.dart';

class BIPage extends StatelessWidget {
  final BIModel model;
  final PairPlotController controller;

  const BIPage({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (_, __) {
        return Row(
          children: [
            SizedBox(width: 280, child: BIControlPanel(model: model)),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  if (model.learningMode) _help(),
                  Expanded(
                    child: PairPlot(
                      controller: controller,
                      config: PairPlotConfig(
                        fields: model.dataset.fields,
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text(
              'Связи между показателями',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Режим обучения',
              icon: const Icon(Icons.school),
              onPressed: model.toggleLearningMode,
            ),
          ],
        ),
      );

  Widget _help() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'Каждая ячейка показывает, как связаны два показателя.\n'
          'Чем выше точка — тем больше значение.\n'
          'Цвет обозначает категорию.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
}
