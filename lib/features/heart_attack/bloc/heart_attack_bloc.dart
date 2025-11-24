import 'dart:convert';

import '../data/csv_heart_attack_data_source.dart';
import '../data/heart_attack_data_model.dart';
import 'package:http/http.dart' as http;
import '../../../core/data/data_bloc.dart';

/// {@template heart_attack_bloc}
/// BLoC для управления данными о рисках сердечных приступов.
/// {@endtemplate}
class HeartAttackBloc extends GenericBloc<HeartAttackDataModel> {
  HeartAttackBloc() : super(dataSource: const CsvHeartAttackDataSource());

  @override
  Future<Map<String, dynamic>> loadAnalysisData() async {
    try {
      final response = await http.get(Uri.parse('http://195.225.111.85:8000/api/heart-attack-analysis'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load heart attack analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading heart attack analysis: $e');
    }
  }
}