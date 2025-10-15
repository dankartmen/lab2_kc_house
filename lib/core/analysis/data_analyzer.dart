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

    // Форматированный вывод результатов
    debugPrint('=== СТАТИСТИКА ПУСТЫХ ЗНАЧЕНИЙ ===');
    debugPrint('Всего записей: ${data.length}');
    
    counters.forEach((field, emptyCount) {
      final filledCount = data.length - emptyCount;
      final filledPercentage = (filledCount / data.length * 100).toStringAsFixed(1);
      debugPrint('$field: $emptyCount/$data.length ($filledPercentage% заполнено)');
    });
  }

  /// Выполняет статистический анализ числовых полей данных.
  /// 
  /// Принимает:
  /// - [data] - данные для анализа.
  /// 
  /// Выводит в консоль описательную статистику (count, mean, std, min, max, квартили)
  /// для всех числовых полей данных.
  static void describe<T extends DataModel>(List<T> data) {
    final numericFields = data.isNotEmpty ? data.first.getNumericFields() : [];
    
    if (numericFields.isEmpty) {
      debugPrint('В данных нет числовых полей для анализа');
      return;
    }
    
    debugPrint('=== СТАТИСТИЧЕСКОЕ РЕЗЮМЕ ===');
    for (var field in numericFields) {
      _describeField(data, field);
    }
  }

  /// Анализирует и выводит статистику для конкретного поля.
  /// 
  /// Принимает:
  /// - [data] - данные для анализа,
  /// - [field] - имя поля для анализа.
  /// 
  /// Вычисляет основные статистические показатели для указанного поля.
  static void _describeField<T extends DataModel>(List<T> data, String field) {
    final values = data
        .map((item) => item.getNumericValue(field))
        .where((value) => value != null && value.isFinite)
        .cast<double>()
        .toList();
    
    if (values.isEmpty) {
      debugPrint('$field: нет валидных значений для анализа');
      return;
    }
    
    final stats = StatisticsCalculator.calculateDescriptiveStats(values);
    debugPrint('$field: count=${stats.count}, mean=${stats.mean.toStringAsFixed(2)}, '
               'std=${stats.std.toStringAsFixed(2)}, min=${stats.min.toStringAsFixed(2)}, '
               'Q1=${stats.q1.toStringAsFixed(2)}, median=${stats.median.toStringAsFixed(2)}, '
               'Q3=${stats.q3.toStringAsFixed(2)}, max=${stats.max.toStringAsFixed(2)}');
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