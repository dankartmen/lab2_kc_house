import 'package:flutter/material.dart';

import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';
import 'bi_model.dart';

class BIControlPanel extends StatelessWidget {
  final Dataset dataset;
  final BIModel model;

  const BIControlPanel({
    super.key,
    required this.dataset,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _sectionTitle('Поля'),
            _fieldDropdown(
              label: 'X',
              value: model.xField,
              onChanged: (v) => model.xField = v,
            ),
            _fieldDropdown(
              label: 'Y',
              value: model.yField,
              onChanged: (v) => model.yField = v,
            ),
            _fieldDropdown(
              label: 'Цвет (Hue)',
              value: model.hueField,
              allowNull: true,
              onChanged: (v) => model.hueField = v,
            ),
            const Divider(height: 24),

            _sectionTitle('Фильтры'),
            ..._numericFilters(),
            ..._categoricalFilters(),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                model.clearCategoryFilters();
                model.clearAllNumericFilters();
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Сбросить фильтры'),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
  
  Widget _fieldDropdown({
    required String label,
    String? value,
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
              const DropdownMenuItem(
                value: null,
                child: Text('—'),
              ),
            ...dataset.fields.map(
              (f) => DropdownMenuItem(
                value: f.key,
                child: Text(f.label),
              ),
            ),
          ],
          onChanged: (v) {
            onChanged(v);
            model.notifyListeners();
          },
        ),
      ],
    );
  }

  List<Widget> _numericFilters() {
    return dataset.fields
        .where((f) => f.type == FieldType.continuous)
        .map((f) {
      final values = dataset.column(f.key).whereType<num>();
      if (values.isEmpty) return const SizedBox.shrink();

      final min = values.reduce((a, b) => a < b ? a : b).toDouble();
      final max = values.reduce((a, b) => a > b ? a : b).toDouble();

      final current = model.numericFilters[f.key] ??
          RangeValues(min, max);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.label),
          RangeSlider(
            values: current,
            min: min,
            max: max,
            onChanged: (v) => model.setNumericFilter(f.key, v),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _categoricalFilters() {
    return dataset.fields
        .where((f) => f.type == FieldType.categorical)
        .map((f) {
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
    }).toList();
  }

}