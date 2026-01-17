import '../../../core/data/data_model.dart';

/// {@template diabetes_risk_prediction_data_model}
/// Модель данных о признаках и симптомах людей, которые либо проявляют 
/// ранние признаки диабета, либо подвержены риску развития диабета.
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

  /// Создаёт модель из CSV-строки (row из CsvToListConverter).
  factory DiabetesRiskPredictionDataModel.fromCsv(List<dynamic> row) {
    return DiabetesRiskPredictionDataModel(
      age: int.tryParse(row[0].toString()) ?? 0,
      gender: row[1].toString().trim(),
      polyuria: row[2].toString().trim(),
      polydipsia: row[3].toString().trim(),
      suddenWeightLoss: row[4].toString().trim(),
      weakness: row[5].toString().trim(),
      polyphagia: row[6].toString().trim(),
      genitalThrush: row[7].toString().trim(),
      visualBlurring: row[8].toString().trim(),
      itching: row[9].toString().trim(),
      irritability: row[10].toString().trim(),
      delayedHealing: row[11].toString().trim(),
      partialParesis: row[12].toString().trim(),
      muscleStiffness: row[13].toString().trim(),
      alopecia: row[14].toString().trim(),
      obesity: row[15].toString().trim(),
      result: row[16].toString().trim(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'polyuria': polyuria,
        'polydipsia': polydipsia,
        'suddenWeightLoss': suddenWeightLoss,
        'weakness': weakness,
        'polyphagia': polyphagia,
        'genitalThrush': genitalThrush,
        'visualBlurring': visualBlurring,
        'itching': itching,
        'irritability': irritability,
        'delayedHealing': delayedHealing,
        'partialParesis': partialParesis,
        'muscleStiffness': muscleStiffness,
        'alopecia': alopecia,
        'obesity': obesity,
        'result': result,
      };

  @override
  String getDisplayName() => 'Age: $age, Result: $result';

  @override
  List<String> getNumericFields() => [
        'age',
        'polyuria',
        'polydipsia',
        'suddenWeightLoss',
        'weakness',
        'polyphagia',
        'genitalThrush',
        'visualBlurring',
        'itching',
        'irritability',
        'delayedHealing',
        'partialParesis',
        'muscleStiffness',
        'alopecia',
        'obesity',
        'result',
      ];

  @override
  double? getNumericValue(String field) {
    switch (field) {
      case 'age': return age.toDouble();
      case 'polyuria': return _convertToBinary(polyuria);
      case 'polydipsia': return _convertToBinary(polydipsia);
      case 'suddenWeightLoss': return _convertToBinary(suddenWeightLoss);
      case 'weakness': return _convertToBinary(weakness);
      case 'polyphagia': return _convertToBinary(polyphagia);
      case 'genitalThrush': return _convertToBinary(genitalThrush);
      case 'visualBlurring': return _convertToBinary(visualBlurring);
      case 'itching': return _convertToBinary(itching);
      case 'irritability': return _convertToBinary(irritability);
      case 'delayedHealing': return _convertToBinary(delayedHealing);
      case 'partialParesis': return _convertToBinary(partialParesis);
      case 'muscleStiffness': return _convertToBinary(muscleStiffness);
      case 'alopecia': return _convertToBinary(alopecia);
      case 'obesity': return _convertToBinary(obesity);
      case 'result': return _convertToBinary(result);
      default: return null;
    }
  }

  /// Конвертирует строковые Yes/No значения в числовые (1.0/0.0)
  double? getBinaryValue(String field) {
    switch (field) {
      case 'polyuria': return _convertToBinary(polyuria);
      case 'polydipsia': return _convertToBinary(polydipsia);
      case 'suddenWeightLoss': return _convertToBinary(suddenWeightLoss);
      case 'weakness': return _convertToBinary(weakness);
      case 'polyphagia': return _convertToBinary(polyphagia);
      case 'genitalThrush': return _convertToBinary(genitalThrush);
      case 'visualBlurring': return _convertToBinary(visualBlurring);
      case 'itching': return _convertToBinary(itching);
      case 'irritability': return _convertToBinary(irritability);
      case 'delayedHealing': return _convertToBinary(delayedHealing);
      case 'partialParesis': return _convertToBinary(partialParesis);
      case 'muscleStiffness': return _convertToBinary(muscleStiffness);
      case 'alopecia': return _convertToBinary(alopecia);
      case 'obesity': return _convertToBinary(obesity);
      case 'result': return _convertToBinary(result);
      default: return null;
    }
  }

  double _convertToBinary(String value) {
    if (value.toLowerCase() == 'yes' || value.toLowerCase() == 'positive') {
      return 1.0;
    } else if (value.toLowerCase() == 'no' || value.toLowerCase() == 'negative') {
      return 0.0;
    }
    return 0.0;
  }

  /// Список всех бинарных полей
  List<String> getBinaryFields() => [
    'polyuria',
    'polydipsia',
    'suddenWeightLoss',
    'weakness',
    'polyphagia',
    'genitalThrush',
    'visualBlurring',
    'itching',
    'irritability',
    'delayedHealing',
    'partialParesis',
    'muscleStiffness',
    'alopecia',
    'obesity',
    'result',
  ];
}