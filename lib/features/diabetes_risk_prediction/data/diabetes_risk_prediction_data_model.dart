import '../../../core/data/data_model.dart';
import '../../../core/data/field_descriptor.dart';

/// {@template diabetes_risk_prediction_data_model}
/// Модель данных для анализа риска развития диабета.
///
/// Содержит демографические признаки и бинарные симптомы,
/// а также итоговый диагноз.
/// {@endtemplate}
class DiabetesRiskPredictionDataModel extends DataModel {
  /// Возраст.
  final int age;

  /// Пол (Male/Female).
  final String gender;

  /// Полиурия (Yes/No).
  final String polyuria;

  /// Полидипсия (Yes/No).
  final String polydipsia;

  /// Внезапная потеря веса (Yes/No).
  final String suddenWeightLoss;

  /// Слабость (Yes/No).
  final String weakness;

  /// Полифагия (Yes/No).
  final String polyphagia;

  /// Молочница (Yes/No).
  final String genitalThrush;

  /// Нечеткое зрение (Yes/No).
  final String visualBlurring;

  /// Зуд (Yes/No).
  final String itching;

  /// Раздражительность (Yes/No).
  final String irritability;

  /// Замедленное заживление ран, тканей (Yes/No).
  final String delayedHealing;

  /// Частичный паралич (Yes/No).
  final String partialParesis;

  /// Мышечная скованность (Yes/No).
  final String muscleStiffness;

  /// Алопеция (выпадение волос) (Yes/No).
  final String alopecia;

  /// Ожирение (Yes/No).
  final String obesity;

  /// Результат (Positive/Negative).
  final String result;

  /// {@macro diabetes_risk_prediction_data_model}
  const DiabetesRiskPredictionDataModel({
    required this.age,
    required this.gender,
    required this.polyuria,
    required this.polydipsia,
    required this.suddenWeightLoss,
    required this.weakness,
    required this.polyphagia,
    required this.genitalThrush,
    required this.visualBlurring,
    required this.itching,
    required this.irritability,
    required this.delayedHealing,
    required this.partialParesis,
    required this.muscleStiffness,
    required this.alopecia,
    required this.obesity,
    required this.result,
  });

  @override
  List<FieldDescriptor> get fieldDescriptors => const [
        FieldDescriptor(
          key: 'age',
          label: 'Возраст',
          type: FieldType.continuous,
          min: 0,
          max: 120,
        ),
        FieldDescriptor(
          key: 'polyuria',
          label: 'Полиурия',
          type: FieldType.binary,
        ),
        FieldDescriptor(
          key: 'polydipsia',
          label: 'Полидипсия',
          type: FieldType.binary,
        ),
        FieldDescriptor(
          key: 'obesity',
          label: 'Ожирение',
          type: FieldType.binary,
        ),
        FieldDescriptor(
          key: 'result',
          label: 'Диагноз',
          type: FieldType.categorical,
        ),
      ];

  @override
  List<FieldDescriptor> getNumericFieldsDescriptors() {
    return [
      FieldDescriptor.numeric('age', label: 'Возраст'),
      FieldDescriptor.binary('polyuria', label: 'Полиурия'),
      FieldDescriptor.binary('polydipsia', label: 'Полидипсия'),
      FieldDescriptor.binary('suddenWeightLoss', label: 'Внезапная потеря веса'),
      FieldDescriptor.binary('weakness', label: 'Слабость'),
      FieldDescriptor.binary('polyphagia', label: 'Полифагия'),
      FieldDescriptor.binary('genitalThrush', label: 'Молочница'),
      FieldDescriptor.binary('visualBlurring', label: 'Нечеткое зрение'),
      FieldDescriptor.binary('itching', label: 'Зуд'),
      FieldDescriptor.binary('irritability', label: 'Раздражительность'),
      FieldDescriptor.binary('delayedHealing', label: 'Замедленное заживление'),
      FieldDescriptor.binary('partialParesis', label: 'Частичный паралич'),
      FieldDescriptor.binary('muscleStiffness', label: 'Мышечная скованность'),
      FieldDescriptor.binary('alopecia', label: 'Алопеция'),
      FieldDescriptor.binary('obesity', label: 'Ожирение'),
      FieldDescriptor.binary('result', label: 'Результат'),
    ];
  }


  @override
  double? getNumericValue(String key) {
    switch (key) {
      case 'age':
        return age.toDouble();
      case 'polyuria':
        return _yesNo(polyuria);
      case 'polydipsia':
        return _yesNo(polydipsia);
      case 'obesity':
        return _yesNo(obesity);
      default:
        return null;
    }
  }

  @override
  String? getCategoricalValue(String key) {
    switch (key) {
      case 'gender':
        return gender;
      case 'result':
        return result;
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'polyuria': polyuria,
        'polydipsia': polydipsia,
        'obesity': obesity,
        'result': result,
      };

  @override
  String getDisplayName() => 'Возраст: $age, Диагноз: $result';

  double _yesNo(String value) {
    final v = value.toLowerCase();
    if (v == 'yes' || v == 'positive') return 1.0;
    if (v == 'no' || v == 'negative') return 0.0;
    return 0.0;
  }
}
