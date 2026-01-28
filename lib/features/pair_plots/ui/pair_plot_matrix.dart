import 'package:flutter/material.dart';
import '../../../dataset/field_descriptor.dart';
import 'cells/pair_plot_cell.dart';
import '../config/pair_plot_config.dart';
import '../controller/pair_plot_controller.dart';

class PairPlotMatrix extends StatelessWidget {
  final PairPlotConfig config;
  final PairPlotController controller;
  final Size cellSize;

  const PairPlotMatrix({
    super.key,
    required this.config,
    required this.controller,
    required this.cellSize,
  });

  List<FieldDescriptor> get _numericFields =>
      config.fields
          .where((f) => f.type == FieldType.continuous)
          .toList();

  List<FieldDescriptor> get _categoricalFields =>
      config.fields
          .where((f) => f.type == FieldType.categorical)
          .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumericNumeric(),
        const SizedBox(height: 24),
        _buildNumericCategorical(),
        const SizedBox(height: 24),
        _buildDiagonal(),
      ],
    );
  }

  Widget _buildNumericNumeric() {
    if (_numericFields.length < 2) {
      return const SizedBox.shrink();
    }

    return _Section(
      title: 'Числовые зависимости',
      subtitle: 'Диаграммы рассеяния и корреляции',
      child: Column(
        children: _numericFields.map((y) {
          final xs = _numericFields.where((x) => x != y).toList();
          if (xs.isEmpty) return const SizedBox.shrink();

          return Row(
            children: xs.map((x) {
              final data = controller.getScatterData(x, y);
              if (data.points.isEmpty) {
                return const SizedBox.shrink();
              }

              return _cell(x, y);
            }).toList(),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildNumericCategorical() {
    if (_numericFields.isEmpty || _categoricalFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return _Section(
      title: 'Распределения по категориям',
      subtitle: 'Сравнение числовых значений между группами',
      child: Column(
        children: _numericFields.map((num) {
          final cats = _categoricalFields.where((cat) {
            return controller
                .visibleRowsFor(cat, num)
                .isNotEmpty;
          }).toList();

          if (cats.isEmpty) return const SizedBox.shrink();

          return Row(
            children: cats.map((cat) {
              return _cell(cat, num);
            }).toList(),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildDiagonal() {
    return _Section(
      title: 'Распределения признаков',
      subtitle: 'Общая структура данных',
      child: Wrap(
        children: config.fields.map((f) {
          final hasData = f.type == FieldType.continuous
              ? controller.getNumericValues(f).isNotEmpty
              : controller.getCategoricalValues(f).isNotEmpty;

          if (!hasData) return const SizedBox.shrink();

          return _cell(f, f);
        }).toList(),
      ),
    );
  }

  Widget _cell(FieldDescriptor x, FieldDescriptor y) {
    return SizedBox(
      width: cellSize.width,
      height: cellSize.height,
      child: PairPlotCell(
        x: x,
        y: y,
        config: config,
        controller: controller,
        isDiagonal: x == y,
        showXAxis: true,
        showYAxis: true,
      ),
    );
  }
}


class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
