import 'package:flutter/material.dart';
import '../../dataset/dataset.dart';

class BIModel extends ChangeNotifier {
  late Dataset _dataset;
  Dataset get dataset => _dataset;

  String? xField;
  String? yField;
  String? hueField;

  void setXField(String? v) {
    xField = v;
    notifyListeners();
  }

  void setYField(String? v) {
    xField = v;
    notifyListeners();
  }
  final Map<String, Set<String>> categoricalFilters = {};
  final Map<String, RangeValues> numericFilters = {};

  int? hoveredRow;
  final Set<int> selectedRows = {};

  BIModel(Dataset initialDataset) {
    _dataset = initialDataset;
  }

  /* ================= DATASET ================= */

  void setDataset(Dataset dataset) {
    _dataset = dataset;
    clearAllFilters();
    notifyListeners();
  }

  /* ================= HUE ================= */

  void setHueField(String? fieldKey) {
    if (hueField != fieldKey) {
      hueField = fieldKey;
      notifyListeners();
    }
  }

  /* ================= CATEGORY FILTERS ================= */

  bool isCategoryActive(String field, dynamic value) {
    final set = categoricalFilters[field];
    if (set == null || set.isEmpty) return true;
    return set.contains(value.toString());
  }

  Set<String> categoriesOf(String field) =>
      categoricalFilters[field] ?? {};

  Set<String> allCategoriesOf(String field) {
    return _dataset.rows
        .map((row) => row[field]?.toString())
        .whereType<String>()
        .toSet();
  }

  void toggleCategory(String field, dynamic value) {
    final set =
        categoricalFilters.putIfAbsent(field, () => <String>{});

    final v = value.toString();
    if (set.contains(v)) {
      set.remove(v);
    } else {
      set.add(v);
    }

    if (set.length == allCategoriesOf(field).length) {
      set.clear();
    }

    notifyListeners();
  }

  void clearCategoryFilters() {
    categoricalFilters.clear();
    notifyListeners();
  }

  /* ================= NUMERIC FILTERS ================= */

  void setNumericFilter(String field, RangeValues range) {
    numericFilters[field] = range;
    notifyListeners();
  }

  void clearNumericFilter(String field) {
    numericFilters.remove(field);
    notifyListeners();
  }

  void clearAllNumericFilters() {
    numericFilters.clear();
    notifyListeners();
  }

  void clearAllFilters() {
    categoricalFilters.clear();
    numericFilters.clear();
  }

  /* ================= HOVER / SELECTION ================= */

  void setHoveredRow(int? row) {
    if (hoveredRow != row) {
      hoveredRow = row;
      notifyListeners();
    }
  }

  void toggleRowSelection(int row) {
    if (selectedRows.contains(row)) {
      selectedRows.remove(row);
    } else {
      selectedRows.add(row);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedRows.clear();
    notifyListeners();
  }

  bool hasAnyFilter() {
    return categoricalFilters.values.any((v) => v.isNotEmpty) ||
        numericFilters.isNotEmpty;
  }
}
