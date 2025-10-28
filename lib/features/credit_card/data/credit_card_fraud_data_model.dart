import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/data/data_model.dart';

/// {@template credit_card_fraud_data_model}
/// Модель данных для обнаружения мошенничества с кредитными картами
/// {@endtemplate}
class CreditCardFraudDataModel extends DataModel {
  final double time;
  final double v1;
  final double v2;
  final double v3;
  final double v4;
  final double v5;
  final double v6;
  final double v7;
  final double v8;
  final double v9;
  final double v10;
  final double v11;
  final double v12;
  final double v13;
  final double v14;
  final double v15;
  final double v16;
  final double v17;
  final double v18;
  final double v19;
  final double v20;
  final double v21;
  final double v22;
  final double v23;
  final double v24;
  final double v25;
  final double v26;
  final double v27;
  final double v28;
  final double amount;
  final int classLabel;

  const CreditCardFraudDataModel({
    required this.time,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.v4,
    required this.v5,
    required this.v6,
    required this.v7,
    required this.v8,
    required this.v9,
    required this.v10,
    required this.v11,
    required this.v12,
    required this.v13,
    required this.v14,
    required this.v15,
    required this.v16,
    required this.v17,
    required this.v18,
    required this.v19,
    required this.v20,
    required this.v21,
    required this.v22,
    required this.v23,
    required this.v24,
    required this.v25,
    required this.v26,
    required this.v27,
    required this.v28,
    required this.amount,
    required this.classLabel,
  });

  /// Создает объект из CSV строки
  factory CreditCardFraudDataModel.fromCsv(List<dynamic> row) {
    return CreditCardFraudDataModel(
      time: _parseDouble(row[0]),
      v1: _parseDouble(row[1]),
      v2: _parseDouble(row[2]),
      v3: _parseDouble(row[3]),
      v4: _parseDouble(row[4]),
      v5: _parseDouble(row[5]),
      v6: _parseDouble(row[6]),
      v7: _parseDouble(row[7]),
      v8: _parseDouble(row[8]),
      v9: _parseDouble(row[9]),
      v10: _parseDouble(row[10]),
      v11: _parseDouble(row[11]),
      v12: _parseDouble(row[12]),
      v13: _parseDouble(row[13]),
      v14: _parseDouble(row[14]),
      v15: _parseDouble(row[15]),
      v16: _parseDouble(row[16]),
      v17: _parseDouble(row[17]),
      v18: _parseDouble(row[18]),
      v19: _parseDouble(row[19]),
      v20: _parseDouble(row[20]),
      v21: _parseDouble(row[21]),
      v22: _parseDouble(row[22]),
      v23: _parseDouble(row[23]),
      v24: _parseDouble(row[24]),
      v25: _parseDouble(row[25]),
      v26: _parseDouble(row[26]),
      v27: _parseDouble(row[27]),
      v28: _parseDouble(row[28]),
      amount: _parseDouble(row[29]),
      classLabel: _parseInt(row[30]),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    final str = value.toString();
    if (str.contains('e+')) {
      // Обработка научной нотации: "1.225e+006"
      final parts = str.split('e+');
      final base = double.parse(parts[0]);
      final exponent = int.parse(parts[1]);
      return base * pow(10, exponent).toDouble();
    }
    
    return double.tryParse(str) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'v4': v4,
      'v5': v5,
      'v6': v6,
      'v7': v7,
      'v8': v8,
      'v9': v9,
      'v10': v10,
      'v11': v11,
      'v12': v12,
      'v13': v13,
      'v14': v14,
      'v15': v15,
      'v16': v16,
      'v17': v17,
      'v18': v18,
      'v19': v19,
      'v20': v20,
      'v21': v21,
      'v22': v22,
      'v23': v23,
      'v24': v24,
      'v25': v25,
      'v26': v26,
      'v27': v27,
      'v28': v28,
      'amount': amount,
      'class': classLabel,
    };
  }

  @override
  String getDisplayName() {
    return 'Транзакция ${time.toInt()}с - ${classLabel == 1 ? 'Мошенническая' : 'Нормальная'} - \$${amount.toStringAsFixed(2)}';
  }

  @override
  List<String> getNumericFields() {
    return [
      'time',
      'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'v8', 'v9', 'v10',
      'v11', 'v12', 'v13', 'v14', 'v15', 'v16', 'v17', 'v18', 'v19', 'v20',
      'v21', 'v22', 'v23', 'v24', 'v25', 'v26', 'v27', 'v28',
      'amount',
      'class',
    ];
  }

  @override
  double? getNumericValue(String field) {
    switch (field) {
      case 'time': return time;
      case 'v1': return v1;
      case 'v2': return v2;
      case 'v3': return v3;
      case 'v4': return v4;
      case 'v5': return v5;
      case 'v6': return v6;
      case 'v7': return v7;
      case 'v8': return v8;
      case 'v9': return v9;
      case 'v10': return v10;
      case 'v11': return v11;
      case 'v12': return v12;
      case 'v13': return v13;
      case 'v14': return v14;
      case 'v15': return v15;
      case 'v16': return v16;
      case 'v17': return v17;
      case 'v18': return v18;
      case 'v19': return v19;
      case 'v20': return v20;
      case 'v21': return v21;
      case 'v22': return v22;
      case 'v23': return v23;
      case 'v24': return v24;
      case 'v25': return v25;
      case 'v26': return v26;
      case 'v27': return v27;
      case 'v28': return v28;
      case 'amount': return amount;
      case 'class': return classLabel.toDouble();
      default: 
        debugPrint('Unknown field: $field');
        return 0.0;
    }
  }

  /// Проверяет, является ли транзакция мошеннической
  bool get isFraud => classLabel == 1;

  /// Проверяет, является ли транзакция нормальной
  bool get isNormal => classLabel == 0;
}