import 'package:flutter/material.dart';

import 'core/visualization/screens/analysis_screen.dart';
import 'features/population/bloc/population_bloc.dart';
import 'features/population/data/population_model.dart';

/// {@template population_analysis_screen}
/// Специализированный экран для анализа данных о населении.
/// {@endtemplate}
class PopulationAnalysisScreen extends StatelessWidget {
  /// {@macro population_analysis_screen}
  const PopulationAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericAnalysisScreen<PopulationData>(
      bloc: PopulationBloc(),
      title: 'Анализ населения стран',
      autoLoad: true,
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: true,
      title: 'Анализатор данных о населении',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PopulationAnalysisScreen(),
    );
  }
}