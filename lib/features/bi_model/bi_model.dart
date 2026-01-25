import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../dataset/dataset.dart';
import 'bi_analytics_service.dart';

class BIModel extends ChangeNotifier {
  final Dataset dataset;
  late final BIAnalyticsService analytics;

  BIModel(this.dataset) {
    analytics = BIAnalyticsService(dataset);
  }

  String? xField;
  String? yField;
  String? hueField;

  bool learningMode = true;

  final Map<String, RangeValues> numericFilters = {};
  final Map<String, Set<String>> categoricalFilters = {};

  int? hoveredRow;

  void setXField(String? v) {
    xField = v;
    notifyListeners();
  }

  void setYField(String? v) {
    yField = v; 
    notifyListeners();
  }

  void setHueField(String? v) {
    hueField = v;
    notifyListeners();
  }

  void toggleLearningMode() {
    learningMode = !learningMode;
    notifyListeners();
  }

  void setHoveredRow(int? row) {
    hoveredRow = row;
    notifyListeners();
  }

  void setNumericFilter(String key, RangeValues v) {
    numericFilters[key] = v;
    notifyListeners();
  }

  void toggleCategory(String field, String value) {
    categoricalFilters.putIfAbsent(field, () => <String>{});
    if (!categoricalFilters[field]!.add(value)) {
      categoricalFilters[field]!.remove(value);
    }
    notifyListeners();
  }

  void clearAllFilters() {
    numericFilters.clear();
    categoricalFilters.clear();
    notifyListeners();
  }

  Set<String> categoriesOf(String field) =>
      categoricalFilters[field] ?? {};

  Iterable<String> allCategoriesOf(String field) {
    return dataset
        .column(field)
        .map((e) => e?.toString())
        .whereType<String>()
        .toSet();
  }
}
