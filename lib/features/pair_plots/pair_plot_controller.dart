import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/bi_model/bi_model.dart';
import 'package:lab2_kc_house/features/pair_plots/scales/categorical_color_scale.dart';

import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';
import 'data/pair_plot_data_builder.dart';
import 'data/scatter_data.dart';

/// Контроллер для управления состоянием PairPlot.
/// Хранит состояние фильтров и ховеров, уведомляет подписчиков об изменениях.
class PairPlotController extends ChangeNotifier {
  late BIModel model;
  
  Dataset get dataset => model.dataset;

  CategoricalColorScale? _colorScale;
  CategoricalColorScale? get colorScale => _colorScale;
  
  late List<int> _visibleRows;

  // Кэши данных
  final Map<String, ScatterData> _scatterCache = {};
  final Map<String, List<double>> _numericCache = {};
  final Map<String, List<String>> _categoricalCache = {};
  final Map<String, double> _minCache = {};
  final Map<String, double> _maxCache = {};
  final Map<String, List<double>> _jitterCache = {};


  PairPlotController(this.model) {
    _rebuild();
    model.addListener(_rebuild);
  }


  void _rebuild() {
    _visibleRows = List.generate(
      dataset.rows.length,
      (i) => i,
    ).where(_passesFilters).toList();

    _buildColorScale();
    invalidateCache(notify: false);
    notifyListeners();
  }

  void _buildColorScale() {
    final hueKey = model.hueField;
    if (hueKey == null) {
      _colorScale = null;
      return;
    }

    final field = dataset.fields.firstWhere(
      (f) => f.key == hueKey,
      orElse: () => throw StateError('Hue field not found'),
    );

    final categories = _visibleRows
        .map((r) => field.parseCategory(dataset.rows[r][hueKey]))
        .whereType<String>()
        .toList();

    if (categories.isEmpty) {
      _colorScale = null;
      return;
    }

    _colorScale = CategoricalColorScale.fromData(
      values: categories,
    );
  }

  bool _passesFilters(int row) {
    final r = dataset.rows[row];

    // Категориальные фильтры
    for (final e in model.categoricalFilters.entries) {
      if (e.value.isEmpty) continue;
      final v = r[e.key]?.toString();
      if (v == null || !e.value.contains(v)) return false;
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
  
  List<Map<String, dynamic>> visibleRowsFor(
    FieldDescriptor catField,
    FieldDescriptor numField,
  ) {
    return _visibleRows
        .map((i) => dataset.rows[i])
        .where((r) =>
            r.containsKey(catField.key) &&
            r.containsKey(numField.key))
        .toList();
  }

  List<double> getNumericValues(FieldDescriptor field) {
    return _numericCache.putIfAbsent(
      field.key,
      () => _visibleRows
          .map((i) => dataset.rows[i][field.key])
          .whereType<num>()
          .map((e) => e.toDouble())
          .toList(),
    );
  }

  List<String> getCategoricalValues(FieldDescriptor field) {
    return _categoricalCache.putIfAbsent(
      field.key,
      () => _visibleRows
          .map((i) => field.parseCategory(dataset.rows[i][field.key]))
          .whereType<String>()
          .toList(),
    );
  }

  /// Получить минимальное значение для поля
  double getMin(FieldDescriptor field) {
    return _minCache.putIfAbsent(
      field.key,
      () => getNumericValues(field).reduce(min),
    );
  }

  /// Получить максимальное значение для поля
  double getMax(FieldDescriptor field) {
    return _maxCache.putIfAbsent(
      field.key,
      () => getNumericValues(field).reduce(max),
    );
  }

  /// Получить предварительно рассчитанные jitter значения
  List<double> getJitters(int count, int seed) {
    final key = '$count-$seed';
    return _jitterCache.putIfAbsent(
      key,
      () {
        final rnd = Random(seed);
        return List.generate(count, (_) => (rnd.nextDouble() - 0.5) * 0.6);
      },
    );
  }
  

  ScatterData getScatterData(
    FieldDescriptor x,
    FieldDescriptor y, {
    bool computeCorrelation = true,
  }) {
    final hueKey = model.hueField;
    final cacheKey =
        '${x.key}|${y.key}|$hueKey|${_visibleRows.join(",")}';

    if (_scatterCache.containsKey(cacheKey)) {
      return _scatterCache[cacheKey]!;
    }

    final points = <ScatterPoint>[];
    final xs = <double>[];
    final ys = <double>[];

    for (final row in _visibleRows) {
      final r = model.dataset.rows[row];
      final xv = r[x.key];
      final yv = r[y.key];

      if (xv is! num || yv is! num) continue;

      final category = hueKey != null
        ? r[hueKey]?.toString()
        : null;


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

    _scatterCache[cacheKey] = data;
    return data;
  }


  /// Очистить все кэши 
  void invalidateCache({bool notify = true}) {
    _scatterCache.clear();
    _numericCache.clear();
    _categoricalCache.clear();
    _jitterCache.clear();
    _minCache.clear();
    _maxCache.clear();
    if (notify) notifyListeners();
  }
}
