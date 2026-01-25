import 'package:flutter/material.dart';
import '../../dataset/field_descriptor.dart';
import 'bi_model.dart';

class BIControlPanel extends StatelessWidget {
  final BIModel model;

  const BIControlPanel({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (_, __) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _title('Поля'),
            _fieldPicker(
              context,
              label: 'X',
              value: model.xField,
              onChanged: model.setXField,
            ),
            _fieldPicker(
              context,
              label: 'Y',
              value: model.yField,
              onChanged: model.setYField,
            ),
            _fieldPicker(
              context,
              label: 'Цвет',
              value: model.hueField,
              allowNull: true,
              onChanged: model.setHueField,
            ),

            const Divider(height: 24),
            _title('Фильтры'),
            _filters(),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: model.clearAllFilters,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Сбросить фильтры'),
            ),
          ],
        );
      },
    );
  }

  Widget _title(String t) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _fieldPicker(
    BuildContext context, {
    required String label,
    required String? value,
    bool allowNull = false,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text('Не выбрано'),
          items: [
            if (allowNull)
              const DropdownMenuItem(value: null, child: Text('—')),
            ...model.dataset.fields.map(
              (f) => DropdownMenuItem(value: f.key, child: Text(f.label)),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _filters() {
    return Column(
      children: model.dataset.fields.map((f) {
        if (f.type == FieldType.continuous) {
          final stats = model.analytics.numericStats(f);
          if (stats.count == 0) return const SizedBox.shrink();

          final current =
              model.numericFilters[f.key] ??
              RangeValues(stats.min!, stats.max!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.label),
              RangeSlider(
                values: current,
                min: stats.min!,
                max: stats.max!,
                onChanged: (v) => model.setNumericFilter(f.key, v),
              ),
            ],
          );
        }

        if (f.type == FieldType.categorical) {
          final values = model.allCategoriesOf(f.key).toList();
          if (values.isEmpty) return const SizedBox.shrink();

          return ExpansionTile(
            title: Text(f.label),
            children: values.map((v) {
              final active = model.categoriesOf(f.key).contains(v);
              return CheckboxListTile(
                dense: true,
                value: active,
                title: Text(v),
                onChanged: (_) => model.toggleCategory(f.key, v),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      }).toList(),
    );
  }
}
