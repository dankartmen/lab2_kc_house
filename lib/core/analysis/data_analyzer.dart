import 'dart:math';
import 'package:flutter/material.dart';
import '../data/data_model.dart';
import 'statistics_calculator.dart';

/// {@template data_analyzer}
/// Утилитарный класс для анализа данных.
/// Предоставляет методы для статистического анализа и отладки данных.
/// {@endtemplate}
class DataAnalyzer {
  /// {@macro data_analyzer}
  const DataAnalyzer._(); // Приватный конструктор — класс статический

  /// Выводит в консоль первые записи данных для отладки.
  /// 
  /// Принимает:
  /// - [data] — данные для отображения,
  /// - [count] — количество отображаемых записей (по умолчанию 5).
  static void printHead<T extends DataModel>(List<T> data, {int count = 5}) {
    debugPrint('=== ПЕРВЫЕ $count ЗАПИСЕЙ ===');
    for (int i = 0; i < min(count, data.length); i++) {
      final item = data[i];
      final fields = item.toJson().entries.take(3); // Ограничиваем вывод
      final fieldString = fields.map((e) => '${e.key}: ${e.value}').join(', ');
      debugPrint('$i: ${item.getDisplayName()} - $fieldString');
    }
  }

  /// Анализирует пустые значения в данных и выводит таблицу.
  static void countEmptyValues<T extends DataModel>(List<T> data) {
    if (data.isEmpty) {
      debugPrint('Данные пусты — анализ невозможен');
      return;
    }

    final counters = <String, int>{};
    final firstItem = data.first.toJson();
    for (var key in firstItem.keys) counters[key] = 0;

    for (var item in data) {
      final json = item.toJson();
      for (var entry in json.entries) {
        if (_isEmpty(entry.value)) counters[entry.key] = counters[entry.key]! + 1;
      }
    }

    debugPrint('═' * 60);
    debugPrint('СТАТИСТИКА ПУСТЫХ ЗНАЧЕНИЙ');
    debugPrint('Всего записей: ${data.length}');
    debugPrint('═' * 60);
    debugPrint('${'Поле'.padRight(25)}${'Пустых'.padRight(10)}${'Заполнено'.padRight(15)}%');
    debugPrint('─' * 60);

    counters.forEach((field, emptyCount) {
      final filledCount = data.length - emptyCount;
      final filledPercentage = (filledCount / data.length * 100).toStringAsFixed(1);
      final fieldDisplay = field.length > 24 ? '${field.substring(0, 22)}..' : field;
      debugPrint(
          '${fieldDisplay.padRight(25)}${emptyCount.toString().padRight(10)}${filledCount.toString().padRight(15)}$filledPercentage%');
    });

    debugPrint('═' * 60);
  }

  /// Статистический анализ числовых полей.
  static void describe<T extends DataModel>(List<T> data) {
    final numericFields = data.isNotEmpty
    ? data.first.getNumericFieldsDescriptors().map((f) => f.key).toList()
    : [];

    if (numericFields.isEmpty) {
      debugPrint('В данных нет числовых полей для анализа');
      return;
    }

    final fieldStats = <String, DescriptiveStats>{};
    for (var field in numericFields) {
      final stats = _calculateFieldStats(data, field);
      if (stats != null) fieldStats[field] = stats;
    }

    if (fieldStats.isEmpty) {
      debugPrint('Нет валидных числовых данных для анализа');
      return;
    }

    _printDescriptiveStatsTable(fieldStats, data.length);
  }

  static DescriptiveStats? _calculateFieldStats<T extends DataModel>(List<T> data, String field) {
    final values = data
        .map((item) => item.getNumericValue(field))
        .where((v) => v != null && v.isFinite)
        .cast<double>()
        .toList();
    if (values.isEmpty) return null;
    return StatisticsCalculator.calculateDescriptiveStats(values);
  }

  static void _printDescriptiveStatsTable(Map<String, DescriptiveStats> fieldStats, int totalRecords) {
    debugPrint('═' * 120);
    debugPrint('ОПИСАТЕЛЬНАЯ СТАТИСТИКА ЧИСЛОВЫХ ПОЛЕЙ');
    debugPrint('Всего записей: $totalRecords | Анализировано полей: ${fieldStats.length}');
    debugPrint('═' * 120);

    debugPrint(
        'Поле'.padRight(20) +
            'Count'.padRight(8) +
            'Mean'.padRight(12) +
            'Std'.padRight(12) +
            'Min'.padRight(12) +
            'Q1'.padRight(12) +
            'Median'.padRight(12) +
            'Q3'.padRight(12) +
            'Max'.padRight(12));
    debugPrint('─' * 120);

    fieldStats.forEach((field, stats) {
      final fieldDisplay = field.length > 18 ? '${field.substring(0, 16)}..' : field;
      debugPrint(
          fieldDisplay.padRight(20) +
              stats.count.toString().padRight(8) +
              _formatNumber(stats.mean).padRight(12) +
              _formatNumber(stats.std).padRight(12) +
              _formatNumber(stats.min).padRight(12) +
              _formatNumber(stats.q1).padRight(12) +
              _formatNumber(stats.median).padRight(12) +
              _formatNumber(stats.q3).padRight(12) +
              _formatNumber(stats.max).padRight(12));
    });

    debugPrint('═' * 120);
  }

  static String _formatNumber(double value) {
    if (value.abs() >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value.abs() >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    if (value.abs() >= 1) return value.toStringAsFixed(1);
    return value.toStringAsFixed(4);
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is num) return value.isNaN || !value.isFinite;
    return false;
  }
}
