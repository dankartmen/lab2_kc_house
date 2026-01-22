import 'package:flutter/material.dart';

/// Контроллер для управления состоянием PairPlot.
/// Хранит состояние фильтров и ховеров, уведомляет подписчиков об изменениях.
class PairPlotController extends ChangeNotifier {
  int? _hoveredIndex;
  final Set<String> _activeCategories = {};

  int? get hoveredIndex => _hoveredIndex;
  Set<String> get activeCategories => _activeCategories;

  /// Метод для установки индекса наведенной точки.
  void setHoveredIndex(int? index) {
    if (_hoveredIndex != index) {
      _hoveredIndex = index;
      notifyListeners();
    }
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
}
