import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/bi_model/bi_model.dart';
import 'package:lab2_kc_house/features/pair_plots/scales/categorical_color_scale.dart';

import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';
import 'data/pair_plot_data_builder.dart';
import 'data/scatter_data.dart';
import 'pair_plot_config.dart';

/// Контроллер для управления состоянием PairPlot.
/// Хранит состояние фильтров и ховеров, уведомляет подписчиков об изменениях.
class PairPlotController extends ChangeNotifier {
  late BIModel model;
  late Dataset _dataset;
  CategoricalColorScale? _colorScale;
  late List<int> _visibleRows;

  // Кэши данных
  final Map<String, ScatterData> _scatterCache = {};
  final Map<String, List<double>> _numericValuesCache = {};
  final Map<String, List<String>> _categoricalValuesCache = {};
  final Map<String, List<String>> _uniqueCategoriesCache = {};
  final Map<String, List<double>> _jitterCache = {};

  // Кэш для min/max значений
  final Map<String, double> _minValueCache = {};
  final Map<String, double> _maxValueCache = {};

  int? get hoveredIndex => model.hoveredRow;
  Dataset get dataset => _dataset;
  CategoricalColorScale? get colorScale => _colorScale;

  PairPlotController(this.model) {
    _rebuild();
    model.addListener(_rebuild);
  }


  void _rebuild() {
    _dataset = model.dataset;

    _visibleRows = [];
    for (int i = 0; i < model.dataset.rows.length; i++) {
      if (_passesFilters(i)) {
        _visibleRows.add(i);
      }
    }

    invalidateCache();
  }

  bool _passesFilters(int row) {
    final r = model.dataset.rows[row];

    // Категориальные фильтры
    for (final e in model.categoricalFilters.entries) {
      final activeCategories = e.value;
      if (activeCategories.isNotEmpty) {
        final strValue = r[e.key]?.toString();
        if (strValue == null || !activeCategories.contains(strValue)) {
          return false;
        }
      }
    }

    // Числовые фильтры
    for (final e in model.numericFilters.entries) {
      final v = r[e.key];
      if (v is! num || v < e.value.start || v > e.value.end) {
        return false;
      }
    }

    return true;
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


  /// Получить минимальное значение для поля
  double getMinValue(FieldDescriptor field) {
    final key = field.key;
    if (!_minValueCache.containsKey(key)) {
      final values = getNumericValues(field);
      _minValueCache[key] = values.isNotEmpty 
          ? values.reduce((a, b) => a < b ? a : b)
          : 0.0;
    }
    return _minValueCache[key]!;
  }

  /// Получить максимальное значение для поля
  double getMaxValue(FieldDescriptor field) {
    final key = field.key;
    if (!_maxValueCache.containsKey(key)) {
      final values = getNumericValues(field);
      _maxValueCache[key] = values.isNotEmpty 
          ? values.reduce((a, b) => a > b ? a : b)
          : 0.0;
    }
    return _maxValueCache[key]!;
  }

  /// Получить предварительно рассчитанные jitter значения
  List<double> getJitters(int count, {int seed = 42}) {
    final key = 'jitters-$count-$seed';
    if (!_jitterCache.containsKey(key)) {
      final rnd = Random(seed);
      _jitterCache[key] = List.generate(count, 
        (_) => (rnd.nextDouble() - 0.5) * 0.6
      );
    }
    return _jitterCache[key]!;
  }
  
  /// Получить кэшированные категориальные значения для поля
  List<String> getCategoricalValues(FieldDescriptor field) {
    final key = field.key;
    if (!_categoricalValuesCache.containsKey(key)) {
      _categoricalValuesCache[key] = _dataset.rows
          .map((r) => r[field.key]?.toString())
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
    final hueFilterKey = hue != null 
      ? model.categoriesOf(hue.key).join(',') 
      : 'no-hue';

    final key = '${x.key}-${y.key}-${hue?.key}-${_visibleRows.hashCode}-$hueFilterKey';

    if (_scatterCache.containsKey(key)) {
      return _scatterCache[key]!;
    }

    final points = <ScatterPoint>[];
    final xs = <double>[];
    final ys = <double>[];

    for (final row in _visibleRows) {
      final r = model.dataset.rows[row];
      final xv = r[x.key];
      final yv = r[y.key];

      if (xv is! num || yv is! num) continue;

      final category = hue?.parseCategory(r[hue.key]);


      points.add(
        ScatterPoint(
          x: xv.toDouble(),
          y: yv.toDouble(),
          rowIndex: row,
          category: category,
          color: category != null
              ? _colorScale?.colorOf(category) ?? Colors.grey
              : Colors.blue,
        ),
      );

      xs.add(xv.toDouble());
      ys.add(yv.toDouble());
    }

    final data = ScatterData(
      points: points,
      correlation: computeCorrelation
          ? PairPlotDataBuilder.computeCorrelation(xs,ys)
          : null,
    );

    _scatterCache[key] = data;
    return data;
  }


  /// Вспомогательный метод для получения уникальных категорий
  List<String> _getUniqueCategories(FieldDescriptor field) {
    return _dataset.rows
        .map((row) => row[field.key]?.toString())
        .map((v) => field.parseCategory(v))
        .whereType<String>()
        .toSet()
        .toList();
  }


  /// Очистить все кэши 
  void invalidateCache() {
    _scatterCache.clear();
    _numericValuesCache.clear();
    _categoricalValuesCache.clear();
    _uniqueCategoriesCache.clear();
    _jitterCache.clear();
    _minValueCache.clear();
    _maxValueCache.clear();
    notifyListeners();
  }
}
