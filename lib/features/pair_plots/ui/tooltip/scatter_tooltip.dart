import 'package:flutter/material.dart';
import '../../../../dataset/field_descriptor.dart';
import '../../data/scatter_data.dart';

class ScatterTooltip extends StatelessWidget {
  final ScatterPoint point;
  final FieldDescriptor x;
  final FieldDescriptor y;

  const ScatterTooltip({
    super.key,
    required this.point,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: DefaultTextStyle(
          style: theme.textTheme.bodySmall!.copyWith(
            fontSize: 12,
            color: Colors.black,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${x.label} × ${y.label}',
                style: theme.textTheme.labelMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              _row(x.label, point.x),
              _row(y.label, point.y),

              if (point.category != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: point.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      point.category!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 4),
              Text(
                'Row #${point.rowIndex}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontFeatures: [
            FontFeature.tabularFigures(),
          ]),
        ),
      ],
    );
  }
}
