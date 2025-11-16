import '../../../core/data/data_model.dart';

/// {@template heart_attack_data_model}
/// Модель данных о пациенте для предсказания риска сердечного приступа.
/// {@endtemplate}
class HeartAttackDataModel extends DataModel {
  /// ID пациента.
  final String patientId;

  /// Возраст.
  final int age;

  /// Пол (Male/Female).
  final String sex;

  /// Холестерин.
  final double cholesterol;

  /// Давление крови (e.g., "158/88" -> systolic/diastolic).
  final String bloodPressure;

  /// Частота сердцебиения.
  final int heartRate;

  /// Диабет (0/1).
  final int diabetes;

  /// Семейная история (0/1).
  final int familyHistory;

  /// Курение (0/1).
  final int smoking;

  /// Ожирение (0/1).
  final int obesity;

  /// Потребление алкоголя (0/1).
  final int alcoholConsumption;

  /// Часы упражнений в неделю.
  final double exerciseHoursPerWeek;

  /// Диета (Average/Unhealthy/Healthy).
  final String diet;

  /// Предыдущие проблемы с сердцем (0/1).
  final int previousHeartProblems;

  /// Использование медикаментов (0/1).
  final int medicationUse;

  /// Уровень стресса (1-10).
  final int stressLevel;

  /// Часы сидячего образа жизни в день.
  final double sedentaryHoursPerDay;

  /// Доход.
  final double income;

  /// Индекс массы тела.
  final double bmi;

  /// Триглецириды.
  final double triglycerides;

  /// Дни физической активности в неделю.
  final int physicalActivityDaysPerWeek;

  /// Часы сна в день.
  final double sleepHoursPerDay;

  /// Страна.
  final String country;

  /// Континент.
  final String continent;

  /// Полушарие.
  final String hemisphere;

  /// Риск сердечного приступа (0/1).
  final int heartAttackRisk;

  /// {@macro heart_attack_data_model}
  const HeartAttackDataModel({
    required this.patientId,
    required this.age,
    required this.sex,
    required this.cholesterol,
    required this.bloodPressure,
    required this.heartRate,
    required this.diabetes,
    required this.familyHistory,
    required this.smoking,
    required this.obesity,
    required this.alcoholConsumption,
    required this.exerciseHoursPerWeek,
    required this.diet,
    required this.previousHeartProblems,
    required this.medicationUse,
    required this.stressLevel,
    required this.sedentaryHoursPerDay,
    required this.income,
    required this.bmi,
    required this.triglycerides,
    required this.physicalActivityDaysPerWeek,
    required this.sleepHoursPerDay,
    required this.country,
    required this.continent,
    required this.hemisphere,
    required this.heartAttackRisk,
  });

  /// Создаёт модель из CSV-строки (row из CsvToListConverter).
  factory HeartAttackDataModel.fromCsv(List<dynamic> row) {
    return HeartAttackDataModel(
      patientId: row[0].toString(),
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
      bmi: double.tryParse(row[18].toString()) ?? 0.0,
      triglycerides: double.tryParse(row[19].toString()) ?? 0.0,
      physicalActivityDaysPerWeek: int.tryParse(row[20].toString()) ?? 0,
      sleepHoursPerDay: double.tryParse(row[21].toString()) ?? 0.0,
      country: row[22].toString(),
      continent: row[23].toString(),
      hemisphere: row[24].toString(),
      heartAttackRisk: int.tryParse(row[25].toString()) ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'patientId': patientId,
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
        'bmi': bmi,
        'triglycerides': triglycerides,
        'physicalActivityDaysPerWeek': physicalActivityDaysPerWeek,
        'sleepHoursPerDay': sleepHoursPerDay,
        'country': country,
        'continent': continent,
        'hemisphere': hemisphere,
        'heartAttackRisk': heartAttackRisk,
      };

  @override
  String getDisplayName() => 'Patient $patientId (Age: $age, Risk: $heartAttackRisk)';

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
      case 'bmi': return bmi;
      case 'triglycerides': return triglycerides;
      case 'physicalActivityDaysPerWeek': return physicalActivityDaysPerWeek.toDouble();
      case 'sleepHoursPerDay': return sleepHoursPerDay;
      case 'heartAttackRisk': return heartAttackRisk.toDouble();
      default: return null;
    }
  }
}