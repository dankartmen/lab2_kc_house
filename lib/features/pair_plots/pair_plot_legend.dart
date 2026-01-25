import 'package:flutter/material.dart';
import '../pair_plots/scales/categorical_color_scale.dart';

class PairPlotLegend extends StatelessWidget {
  final CategoricalColorScale scale;
  final String fieldLabel;

  const PairPlotLegend({
    super.key,
    required this.scale,
    required this.fieldLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Цвет: $fieldLabel',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),

        Row(
          children: [
            ...scale.categories.map(
              (c) => Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: scale.colorOf(c),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(c),
                  SizedBox(width: 6,)
                ],
              ),
            ),
          ]
        )
      ],
    );
  }
}
