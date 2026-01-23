import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/scales/categorical_color_scale.dart';

import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';
import 'data/pair_plot_data_builder.dart';
import 'data/scatter_data.dart';
import 'pair_plot_config.dart';

/// Контроллер для управления состоянием PairPlot.
/// Хранит состояние фильтров и ховеров, уведомляет подписчиков об изменениях.
class PairPlotController extends ChangeNotifier {
  int? _hoveredIndex;
  final Set<String> _activeCategories = {};
  late Dataset _dataset;
  CategoricalColorScale? _colorScale;

  // Кэши данных
  final Map<String, ScatterData> _scatterCache = {};
  final Map<String, List<double>> _numericValuesCache = {};
  final Map<String, List<String>> _categoricalValuesCache = {};
  final Map<String, List<String>> _uniqueCategoriesCache = {};

  int? get hoveredIndex => _hoveredIndex;
  Set<String> get activeCategories => _activeCategories;
  Dataset get dataset => _dataset;
  CategoricalColorScale? get colorScale => _colorScale;


  /// Метод для установки индекса наведенной точки.
  void setHoveredIndex(int? index) {
    if (_hoveredIndex != index) {
      _hoveredIndex = index;
      notifyListeners();
    }
  }

  /// Инициализация контроллера
  void initialize(Dataset dataset, FieldDescriptor? hue, ColorPalette? palette) {
    _dataset = dataset;
    
    // Создаем colorScale если есть hue
    if (hue != null) {
      final hueValues = _getUniqueCategories(hue);
      if (hueValues.isNotEmpty) {
        _colorScale = CategoricalColorScale.fromData(
          values: hueValues,
          palette: palette ?? ColorPalette.defaultPalette,
          sort: (a, b) => a.compareTo(b),
          maxCategories: 6,
        );
      }
    }
    
    // Очищаем кэш при инициализации
    invalidateCache();
  }
  
  /// Получить кэшированные числовые значения для поля
  List<double> getNumericValues(FieldDescriptor field) {
    final key = field.key;
    if (!_numericValuesCache.containsKey(key)) {
      _numericValuesCache[key] = _dataset.rows
          .map((r) => r[field.key])
          .whereType<num>()
          .map((e) => e.toDouble())
          .toList();
    }
    return _numericValuesCache[key]!;
  }

  /// Получить кэшированные категориальные значения для поля
  List<String> getCategoricalValues(FieldDescriptor field) {
    final key = field.key;
    if (!_categoricalValuesCache.containsKey(key)) {
      _categoricalValuesCache[key] = _dataset.rows
          .map((r) => r[field.key])
          .whereType<String>()
          .toList();
    }
    return _categoricalValuesCache[key]!;
  }

  /// Получить уникальные категории для поля
  List<String> getUniqueCategories(FieldDescriptor field) {
    final key = field.key;
    if (!_uniqueCategoriesCache.containsKey(key)) {
      final values = getCategoricalValues(field);
      _uniqueCategoriesCache[key] = values.toSet().toList();
    }
    return _uniqueCategoriesCache[key]!;
  }

  /// Получить ScatterData с кэшированием
  ScatterData getScatterData(
    FieldDescriptor x,
    FieldDescriptor y, {
    FieldDescriptor? hue,
    bool computeCorrelation = true,
  }) {
    final key = '${x.key}-${y.key}-${hue?.key ?? 'no-hue'}';
    
    if (!_scatterCache.containsKey(key)) {
      _scatterCache[key] = PairPlotDataBuilder.buildScatter(
        dataset: _dataset,
        x: x,
        y: y,
        hue: hue,
        colorScale: _colorScale,
        computeCorrelation: computeCorrelation,
      );
    }
    
    return _scatterCache[key]!;
  }

  /// Вспомогательный метод для получения уникальных категорий
  List<String> _getUniqueCategories(FieldDescriptor field) {
    return _dataset.rows
        .map((row) => row[field.key])
        .where((v) => v != null)
        .map((v) => field.parseCategory(v))
        .whereType<String>()
        .toSet()
        .toList();
  }
  
  /// Метод для переключения категории (добавить/удалить из фильтра).
  void toggleCategory(String category) {
    if (_activeCategories.contains(category)) {
      _activeCategories.remove(category);
    } else {
      _activeCategories.add(category);
    }
    notifyListeners();
  }

  /// Проверить, активна ли категория (показывается ли на графике).
  bool isCategoryActive(String? category) {
    if (category == null) return true;
    if (_activeCategories.isEmpty) return true;
    return _activeCategories.contains(category);
  }

  /// Сбросить все фильтры категорий.
  void resetFilters() {
    _activeCategories.clear();
    notifyListeners();
  }

  /// Очистить ховер.
  void clearHover() {
    setHoveredIndex(null);
  }

  /// Очистить все кэши 
  void invalidateCache() {
    _scatterCache.clear();
    _numericValuesCache.clear();
    _categoricalValuesCache.clear();
    _uniqueCategoriesCache.clear();
    notifyListeners();
  }
}
