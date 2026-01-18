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
  /// Уникальный ключ поля (должен совпадать с ключами DataModel).
  final String key;

  /// Человеко-читаемое название поля.
  final String label;

  /// Тип поля.
  final FieldType type;

  /// Минимальное значение (для числовых полей).
  final double? min;

  /// Максимальное значение (для числовых полей).
  final double? max;

  /// {@macro field_descriptor_class}
  const FieldDescriptor({
    required this.key,
    required this.label,
    required this.type,
    this.min,
    this.max,
  });

  /// Создаёт числовое поле.
  factory FieldDescriptor.numeric(String key, {String? label}) =>
      FieldDescriptor(key, label ?? key, FieldType.continuous);

  /// Создаёт бинарное поле (0/1).
  factory FieldDescriptor.binary(String key, {String? label}) =>
      FieldDescriptor._(key, label ?? key, FieldType.binary);

  /// Создаёт категориальное поле.
  factory FieldDescriptor.categorical(String key, {String? label}) =>
      FieldDescriptor._(key, label ?? key, FieldType.categorical);
}
