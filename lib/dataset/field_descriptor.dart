/// {@template field_descriptor}
/// Описание поля данных, используемого для анализа и визуализации.
///
/// Содержит метаданные о типе поля, его отображаемом названии
/// и допустимом диапазоне значений (если применимо).
/// {@endtemplate}
enum FieldType {
  /// Непрерывная числовая величина (например, возраст).
  continuous,

  /// Бинарная величина (0/1, Yes/No).
  binary,

  /// Категориальное поле (используется для группировки, hue).
  categorical,
}

/// {@template field_descriptor_class}
/// Дескриптор поля данных.
///
/// Используется для:
/// - построения графиков
/// - выбора шкал
/// - корректной цветовой группировки
/// - отображения подписей в UI
/// {@endtemplate}
class FieldDescriptor {
  /// Уникальный ключ поля (имя колонки в Dataset).
  final String key;

  /// Человеко-читаемое название поля.
  final String label;

  /// Тип поля.
  final FieldType type;

  /// Минимальное значение (опционально, может быть вычислено).
  final double? min;

  /// Максимальное значение (опционально, может быть вычислено).
  final double? max;

  /// {@macro field_descriptor_class}
  const FieldDescriptor({
    required this.key,
    required this.label,
    required this.type,
    this.min,
    this.max,
  });

  bool get isNumeric => type == FieldType.continuous || type == FieldType.binary;
  bool get isCategorical => type == FieldType.categorical || type == FieldType.binary;


  /// Создаёт числовое (непрерывное) поле
  static FieldDescriptor numeric({String? label, double? min, double? max, required String key}) {
    return FieldDescriptor(
      key: key,
      label: label ?? key,
      type: FieldType.continuous,
      min: min,
      max: max,
    );
  }

  /// Создаёт бинарное поле (0/1, true/false)
  static FieldDescriptor binary({String? label, required String key}) {
    return FieldDescriptor(
      key: key,
      label: label ?? key,
      type: FieldType.binary,
      min: 0,
      max: 1,
    );
  }

  /// Создаёт категориальное поле
  static FieldDescriptor categorical({String? label, required String key}) {
    return FieldDescriptor(
      key: key,
      label: label ?? key,
      type: FieldType.categorical,
    );
  }
  
  dynamic parse(dynamic raw) {
    if (raw == null) return null;

    switch (type) {
      case FieldType.continuous:
        return double.tryParse(raw.toString());
      case FieldType.binary:
        final isTrue = raw == true ||
            raw == 1 ||
            raw.toString() == '1' ||
            raw.toString().toLowerCase() == 'true';

        return isTrue ? 1 : 0; 

      case FieldType.categorical:
        return raw.toString();
    }
  }

  String? parseCategory(dynamic raw) {
    if (raw == null) return null;

    switch (type) {
      case FieldType.binary:
        final isTrue = raw == true ||
            raw == 1 ||
            raw.toString() == '1' ||
            raw.toString().toLowerCase() == 'true';
        return isTrue ? '1' : '0';

      case FieldType.categorical:
        return raw.toString();

      case FieldType.continuous:
        return null;
    }
  }
}
