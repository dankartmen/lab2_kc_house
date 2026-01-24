import 'package:flutter/material.dart';

import '../../dataset/dataset.dart';

class BIModel extends ChangeNotifier {
  final Dataset dataset;

  String? xField;
  String? yField;
  String? hueField;

  final Map<String, Set<dynamic>> categoricalFilters;
  final Map<String, RangeValues> numericFilters;

  int? hoveredRow;
  final Set<int> selectedRows;

  BIModel(this.dataset)
      : categoricalFilters = {},
        numericFilters = {},
        selectedRows = {};

  // ===== CATEGORY FILTERS =====

  bool isCategoryActive(String field, dynamic value) {
    final set = categoricalFilters[field];
    if (set == null || set.isEmpty) return true;
    return set.contains(value);
  }

  Set<dynamic> categoriesOf(String field) =>
      categoricalFilters[field] ?? {};

  void toggleCategory(String field, dynamic value) {
    final set = categoricalFilters.putIfAbsent(field, () => {});

    final stringValue = value.toString();

    if (set.contains(stringValue)) {
      set.remove(stringValue);
    } else {
      set.add(stringValue);
    }

    // Если все категории выбраны - очищаем фильтр
    final allValues = _getAllCategoriesForField(field);
    if (set.length == allValues.length) {
      set.clear();
    }

    notifyListeners();
  }

  // Вспомогательный метод для получения всех категорий поля
  Set<String?> _getAllCategoriesForField(String field) {
    return dataset.rows
        .map((row) => row[field]?.toString())
        .where((v) => v != null)
        .toSet();
  }

  void clearCategoryFilter(String field) {
    categoricalFilters.remove(field);
    notifyListeners();
  }

  // ===== HOVER =====

  void setHoveredRow(int? row) {
    if (hoveredRow != row) {
      hoveredRow = row;
      notifyListeners();
    }
  }
}
