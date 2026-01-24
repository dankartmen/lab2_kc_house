  import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/bi_model/bi_model.dart';
  import 'pair_plot_controller.dart';

  class PairPlotLegend extends StatelessWidget {
    final Map<String, Color> legend;
    final BIModel model;
    final String field;

    const PairPlotLegend({
      super.key,
      required this.legend,
      required this.model,
      required this.field,
    });

    @override
    Widget build(BuildContext context) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: legend.entries.map((e) {
          final active = model.categoriesOf(field).isEmpty ||
            model.categoriesOf(field).contains(e.key);

          return GestureDetector(
            onTap: () => model.toggleCategory(field,e.key),
            child: Opacity(
              opacity: active ? 1.0 : 0.3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
  }