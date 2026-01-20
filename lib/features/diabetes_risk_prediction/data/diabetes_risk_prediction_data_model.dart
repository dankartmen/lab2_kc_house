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

  DiabetesRiskPredictionDataModel.fromMap(Map<String, dynamic> map)
      : age = map['age'] as int,
        gender = map['gender'] as String,
        polyuria = map['polyuria'] as String,
        polydipsia = map['polydipsia'] as String,
        suddenWeightLoss = map['suddenWeightLoss'] as String,
        weakness = map['weakness'] as String,
        polyphagia = map['polyphagia'] as String,
        genitalThrush = map['genitalThrush'] as String,
        visualBlurring = map['visualBlurring'] as String,
        itching = map['itching'] as String,
        irritability = map['irritability'] as String,
        delayedHealing = map['delayedHealing'] as String,
        partialParesis = map['partialParesis'] as String,
        muscleStiffness = map['muscleStiffness'] as String,
        alopecia = map['alopecia'] as String,
        obesity = map['obesity'] as String,
        result = map['result'] as String;

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
  double? getBinaryValue(String key) {
  switch (key) {
    case 'polyuria':
      return _yesNo(polyuria);
    case 'polydipsia':
      return _yesNo(polydipsia);
    case 'suddenWeightLoss':
      return _yesNo(suddenWeightLoss);
    case 'weakness':
      return _yesNo(weakness);
    case 'polyphagia':
      return _yesNo(polyphagia);
    case 'genitalThrush':
      return _yesNo(genitalThrush);
    case 'visualBlurring':
      return _yesNo(visualBlurring);
    case 'itching':
      return _yesNo(itching);
    case 'irritability':
      return _yesNo(irritability);
    case 'delayedHealing':
      return _yesNo(delayedHealing);
    case 'partialParesis':
      return _yesNo(partialParesis);
    case 'muscleStiffness':
      return _yesNo(muscleStiffness);
    case 'alopecia':
      return _yesNo(alopecia);
    case 'obesity':
      return _yesNo(obesity);
    case 'result':
      return _yesNo(result);
    default:
      return null;
  }
}
}
