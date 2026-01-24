import 'package:flutter/material.dart';
import '../pair_plot_config.dart';

class CategoricalColorScale {
  final Map<String, Color> _colors;
  final List<String> categories;

  CategoricalColorScale._(this._colors, this.categories);

  Color colorOf(String category) {
    return _colors[category] ?? Colors.grey;
  }

  Map<String, Color> get legend => Map.unmodifiable(_colors);

  /// Фабрика
  factory CategoricalColorScale.fromData({
    required List<String> values,
    int maxCategories = 6,
  }) {
    var unique = values.toSet().toList()..sort();

    if (unique.length > maxCategories){
      unique = unique.take(maxCategories).toList()..add('Other');
    }

    final palette = Colors.primaries;
    final colors = <String, Color>{};
    for (var i = 0; i < unique.length; i++) {
      colors[unique[i]] =
          palette[i % palette.length];
    }

    return CategoricalColorScale._(colors, unique);
  }
}
