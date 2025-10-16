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
  const DataAnalyzer._(); // Приватный конструктор - класс статический

  /// Выводит в консоль первые записи данных для отладки.
  /// 
  /// Принимает:
  /// - [data] - данные для отображения,
  /// - [count] - количество отображаемых записей (по умолчанию 5).
  /// 
  /// Используется для быстрой проверки структуры данных после загрузки.
  static void printHead<T extends DataModel>(List<T> data, {int count = 5}) {
    debugPrint('=== ПЕРВЫЕ $count ЗАПИСЕЙ ===');
    for (int i = 0; i < min(count, data.length); i++) {
      final item = data[i];
      final fields = item.toJson().entries.take(3); // Ограничиваем вывод для читаемости
      final fieldString = fields.map((e) => '${e.key}: ${e.value}').join(', ');
      debugPrint('$i: ${item.getDisplayName()} - $fieldString');
    }
  }

  /// Анализирует и выводит статистику по пустым значениям в данных.
  /// 
  /// Принимает:
  /// - [data] - данные для анализа.
  /// 
  /// Выводит в консоль таблицу с количеством пустых значений по каждому полю
  /// и процентом заполненности.
  static void countEmptyValues<T extends DataModel>(List<T> data) {
    if (data.isEmpty) {
      debugPrint('Данные пусты - анализ невозможен');
      return;
    }
    
    final counters = <String, int>{};
    final firstItem = data.first.toJson();
    
    // Инициализация счетчиков для всех полей
    for (var key in firstItem.keys) {
      counters[key] = 0;
    }

    // Подсчет пустых значений
    for (var item in data) {
      final json = item.toJson();
      for (var entry in json.entries) {
        if (_isEmpty(entry.value)) {
          counters[entry.key] = counters[entry.key]! + 1;
        }
      }
    }

    // Форматированный вывод результатов в виде таблицы
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
        '${fieldDisplay.padRight(25)}${emptyCount.toString().padRight(10)}${filledCount.toString().padRight(15)}$filledPercentage%'
      );
    });
    
    debugPrint('═' * 60);
  }

  /// Выполняет статистический анализ числовых полей данных с табличным выводом.
  /// 
  /// Принимает:
  /// - [data] - данные для анализа.
  /// 
  /// Выводит в консоль описательную статистику (count, mean, std, min, max, квартили)
  /// для всех числовых полей данных в виде форматированной таблицы.
  static void describe<T extends DataModel>(List<T> data) {
    final numericFields = data.isNotEmpty ? data.first.getNumericFields() : [];
    
    if (numericFields.isEmpty) {
      debugPrint('В данных нет числовых полей для анализа');
      return;
    }
    
    // Собираем статистику для всех полей
    final fieldStats = <String, DescriptiveStats>{};
    for (var field in numericFields) {
      final stats = _calculateFieldStats(data, field);
      if (stats != null) {
        fieldStats[field] = stats;
      }
    }
    
    if (fieldStats.isEmpty) {
      debugPrint('Нет валидных числовых данных для анализа');
      return;
    }
    
    _printDescriptiveStatsTable(fieldStats, data.length);
  }

  /// Вычисляет статистику для конкретного поля.
  static DescriptiveStats? _calculateFieldStats<T extends DataModel>(List<T> data, String field) {
    final values = data
        .map((item) => item.getNumericValue(field))
        .where((value) => value != null && value.isFinite)
        .cast<double>()
        .toList();
    
    if (values.isEmpty) return null;
    
    return StatisticsCalculator.calculateDescriptiveStats(values);
  }

  /// Выводит таблицу с описательной статистикой.
  static void _printDescriptiveStatsTable(Map<String, DescriptiveStats> fieldStats, int totalRecords) {
    debugPrint('═' * 120);
    debugPrint('ОПИСАТЕЛЬНАЯ СТАТИСТИКА ЧИСЛОВЫХ ПОЛЕЙ');
    debugPrint('Всего записей: $totalRecords | Анализировано полей: ${fieldStats.length}');
    debugPrint('═' * 120);
    
    // Заголовок таблицы
    debugPrint(
      'Поле'.padRight(20) +
      'Count'.padRight(8) +
      'Mean'.padRight(12) +
      'Std'.padRight(12) +
      'Min'.padRight(12) +
      'Q1'.padRight(12) +
      'Median'.padRight(12) +
      'Q3'.padRight(12) +
      'Max'.padRight(12)
    );
    debugPrint('─' * 120);
    
    // Данные для каждого поля
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
        _formatNumber(stats.max).padRight(12)
      );
    });
    
    debugPrint('═' * 120);
  }

  /// Форматирует числа для красивого вывода.
  static String _formatNumber(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value.abs() >= 1) {
      return value.toStringAsFixed(1);
    } else {
      return value.toStringAsFixed(4);
    }
  }

  /// Проверяет, является ли значение пустым.
  /// 
  /// Принимает:
  /// - [value] - значение для проверки.
  /// 
  /// Возвращает:
  /// - [bool] true если значение считается пустым, false в противном случае.
  /// 
  /// Пустыми считаются: null, пустые строки, NaN, бесконечные числа.
  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is num) return value.isNaN || !value.isFinite;
    return false;
  }
}