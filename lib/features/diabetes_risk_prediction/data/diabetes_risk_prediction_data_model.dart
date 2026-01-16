import '../../../core/data/data_model.dart';

/// {@template diabetes_risk_prediction_data_model}
/// Модель данных о признаках и симптомах людей, которые либо проявляют 
/// ранние признаки диабета, либо подвержены риску развития диабета.
/// {@endtemplate}
class DiabetesRiskPredictionDataModel extends DataModel {
  /// Возраст.
  final int age;

  /// Пол (Male/Female).
  final String sex;

  /// Полиурия (Yes/No).
  final double polyuria;

  /// Полидипсия(Yes/No).
  final String polydipsia;

  /// Внезапнавя потеря веса(Yes/No).
  final int suddenWeightLoss;

  /// Слабость(Yes/No).
  final int weakness;

  /// Полифагия(Yes/No).
  final int polyphagia;

  /// Молочница(Yes/No).
  final int genitalThrush;

  /// Нечеткое зрение(Yes/No).
  final int visualBlurring;

  /// Зуд(Yes/No).
  final int itching;

  /// Раздражительность(Yes/No).
  final double irritability;

  /// Замедленное заживление ран, тканей(Yes/No).
  final String delayedHealing;

  /// Частичный паралич(Yes/No).
  final int partialParesis;

  /// Мышечная скованность(Yes/No).
  final int muscleStiffness;

  /// Алопеция(выпадение волос)(Yes/No).
  final int alopecia;

  /// Ожирение(Yes/No).
  final double obesity;

  /// Класс(Positive/Negative). 
  final double class;


  /// {@macro heart_attack_data_model}
  const DiabetesRiskPredictionDataModel({
    required this.age,
    required this.sex, 
    this.polyuria, 
    required this.polydipsia, 
    required this.suddenWeightLoss, 
    required this.weakness, 
    required this.polyphagia, 
    required this.genitalThrush, 
    required this.visualBlurring, 
    required this.itching, 
    this.irritability, 
    required this.delayedHealing, 
    required this.partialParesis, 
    required this.muscleStiffness, 
    required this.alopecia, 
    this.obesity, 
    this.double,
  });

  /// Создаёт модель из CSV-строки (row из CsvToListConverter).
  factory DiabetesRiskPredictionDataModel.fromCsv(List<dynamic> row) {
    return DiabetesRiskPredictionDataModel(
      age: int.tryParse(row[1].toString()) ?? 0,
      sex: row[2].toString(),
      cholesterol: double.tryParse(row[3].toString()) ?? 0.0,
      bloodPressure: row[4].toString(),
      heartRate: int.tryParse(row[5].toString()) ?? 0,
      diabetes: int.tryParse(row[6].toString()) ?? 0,
      familyHistory: int.tryParse(row[7].toString()) ?? 0,
      smoking: int.tryParse(row[8].toString()) ?? 0,
      obesity: int.tryParse(row[9].toString()) ?? 0,
      alcoholConsumption: int.tryParse(row[10].toString()) ?? 0,
      exerciseHoursPerWeek: double.tryParse(row[11].toString()) ?? 0.0,
      diet: row[12].toString(),
      previousHeartProblems: int.tryParse(row[13].toString()) ?? 0,
      medicationUse: int.tryParse(row[14].toString()) ?? 0,
      stressLevel: int.tryParse(row[15].toString()) ?? 0,
      sedentaryHoursPerDay: double.tryParse(row[16].toString()) ?? 0.0,
      income: double.tryParse(row[17].toString()) ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'age': age,
        'sex': sex,
        'cholesterol': cholesterol,
        'bloodPressure': bloodPressure,
        'heartRate': heartRate,
        'diabetes': diabetes,
        'familyHistory': familyHistory,
        'smoking': smoking,
        'obesity': obesity,
        'alcoholConsumption': alcoholConsumption,
        'exerciseHoursPerWeek': exerciseHoursPerWeek,
        'diet': diet,
        'previousHeartProblems': previousHeartProblems,
        'medicationUse': medicationUse,
        'stressLevel': stressLevel,
        'sedentaryHoursPerDay': sedentaryHoursPerDay,
        'income': income,
      };

  @override
  List<String> getNumericFields() => [
        'age',
        'cholesterol',
        'heartRate',
        'exerciseHoursPerWeek',
        'stressLevel',
        'sedentaryHoursPerDay',
        'income',
        'bmi',
        'triglycerides',
        'physicalActivityDaysPerWeek',
        'sleepHoursPerDay',
        'heartAttackRisk',
      ];

  @override
  double? getNumericValue(String field) {
    switch (field) {
      case 'age': return age.toDouble();
      case 'cholesterol': return cholesterol;
      case 'heartRate': return heartRate.toDouble();
      case 'exerciseHoursPerWeek': return exerciseHoursPerWeek;
      case 'stressLevel': return stressLevel.toDouble();
      case 'sedentaryHoursPerDay': return sedentaryHoursPerDay;
      case 'income': return income;
      default: return null;
    }
  }
}