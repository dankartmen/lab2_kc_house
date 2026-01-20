import 'dart:developer';

import 'package:lab2_kc_house/core/data/field_descriptor.dart';

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

  @override
  HeartAttackDataModel.fromMap(Map<String, dynamic> map)
      : patientId = map['Patient ID'] ?? '',
        age = _parseInt(map['Age']),
        sex = map['Sex']?.toString() ?? '',
        cholesterol = _parseDouble(map['Cholesterol']),
        bloodPressure = map['Blood Pressure']?.toString() ?? '',
        heartRate = _parseInt(map['Heart Rate']),
        diabetes = _parseInt(map['Diabetes']),
        familyHistory = _parseInt(map['Family History']),
        smoking = _parseInt(map['Smoking']),
        obesity = _parseInt(map['Obesity']),
        alcoholConsumption = _parseInt(map['Alcohol Consumption']),
        exerciseHoursPerWeek = _parseDouble(map['Exercise Hours Per Week']),
        diet = map['Diet']?.toString() ?? '',
        previousHeartProblems = _parseInt(map['Previous Heart Problems']),
        medicationUse = _parseInt(map['Medication Use']),
        stressLevel = _parseInt(map['Stress Level']),
        sedentaryHoursPerDay = _parseDouble(map['Sedentary Hours Per Day']),
        income = _parseDouble(map['Income']),
        bmi = _parseDouble(map['BMI']),
        triglycerides = _parseDouble(map['Triglycerides']),
        physicalActivityDaysPerWeek = _parseInt(map['Physical Activity Days Per Week']),
        sleepHoursPerDay = _parseDouble(map['Sleep Hours Per Day']),
        country = map['Country']?.toString() ?? '',
        continent = map['Continent']?.toString() ?? '',
        hemisphere = map['Hemisphere']?.toString() ?? '',
        heartAttackRisk = _parseInt(map['Heart Attack Risk']);

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

  @override
  List<FieldDescriptor> get fieldDescriptors => [
        FieldDescriptor(
          key: 'age',
          label: 'Возраст',
          type: FieldType.continuous,
        ),
        FieldDescriptor(
          key: 'cholesterol',
          label: 'Холестерин',
          type: FieldType.continuous,
        ),
        FieldDescriptor(
          key: 'bmi',
          label: 'ИМТ',
          type: FieldType.continuous,
        ),
        FieldDescriptor(
          key: 'heartRate',
          label: 'ЧСС',
          type: FieldType.continuous,
        ),
        FieldDescriptor(
          key: 'stressLevel',
          label: 'Уровень стресса',
          type: FieldType.continuous,
        ),
        FieldDescriptor(
          key: 'triglycerides',
          label: 'Триглицериды',
          type: FieldType.continuous,
        ),
        FieldDescriptor(
          key: 'heartAttackRisk',
          label: 'Риск сердечного приступа',
          type: FieldType.categorical,
        ),
      ];

  @override
  String? getCategoricalValue(String key) {
    switch (key) {
      case 'heartAttackRisk': return heartAttackRisk.toString();
      case 'sex': return sex;
      case 'diet': return diet;
      case 'country': return country;
      case 'continent': return continent;
      case 'hemisphere': return hemisphere;
      default: return null;
    }
  }

  static int _parseInt(dynamic value) {
    // log( value.toString(), name: 'Parsing Int');
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    // log(parsed.toString(), name: 'Parsing Int');
    return parsed ?? 0;
  }
  return 0;
}

static double _parseDouble(dynamic value) {
  // log( value.toString(), name: 'Parsing Double');
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed ?? 0.0;
  }
  return 0.0;
}
}