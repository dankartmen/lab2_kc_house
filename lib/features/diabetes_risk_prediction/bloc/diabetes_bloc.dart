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
      final response = await http.get(Uri.parse('http://195.225.111.85:8000/api/diabetes-analysis'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load diabetes analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading diabetes analysis: $e');
    }
  }
}
