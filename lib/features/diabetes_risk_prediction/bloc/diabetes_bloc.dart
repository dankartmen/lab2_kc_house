import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../core/data/data_bloc.dart';
import '../data/csv_diabetes_data_source.dart';
import '../data/diabetes_risk_prediction_data_model.dart';

/// {@template diabetes_bloc}
/// BLoC для управления данными о рисках диабета.
/// {@endtemplate}
class DiabetesBloc extends GenericBloc<DiabetesRiskPredictionDataModel> {
  DiabetesBloc() : super(dataSource: const CsvDiabetesDataSource());

  @override
  Future<Map<String, dynamic>> loadAnalysisData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.234.193:8000/api/diabetes-analysis'));
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        // Проверяем успешность ответа
        if (decoded['success'] == false) {
          throw Exception(decoded['error'] ?? 'Ошибка загрузки анализа диабета');
        }
        
        return decoded;
      } else {
        throw Exception('Failed to load diabetes analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading diabetes analysis: $e');
    }
  }
}
