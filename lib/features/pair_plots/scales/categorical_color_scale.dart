import 'package:flutter/material.dart';
import '../pair_plot_config.dart';

class CategoricalColorScale {
  final Map<String, Color> colors;
  final List<String> categories;

  CategoricalColorScale._(this.colors, this.categories);

  Color colorOf(String category) {
    return colors[category] ?? Colors.grey;
  }

  /// Фабрика
  factory CategoricalColorScale.fromData({
    required List<String> values,
    required ColorPalette palette,
    int? maxCategories,
    Comparator<String>? sort,
  }) {
    var unique = values.toSet().toList();

    // сортировка
    if (sort != null) {
      unique.sort(sort);
    } else {
      unique.sort(); // default
    }

    // ограничение количества
    if (maxCategories != null && unique.length > maxCategories) {
      unique = unique.take(maxCategories).toList()
        ..add('Other');
    }

    final colors = <String, Color>{};
    final paletteColors = palette.colors;

    for (var i = 0; i < unique.length; i++) {
      colors[unique[i]] =
          paletteColors[i % paletteColors.length];
    }

    return CategoricalColorScale._(colors, unique);
  }
}
