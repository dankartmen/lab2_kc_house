import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab2_kc_house/features/box_plots/configs/house_box_plot_config.dart';
import 'package:lab2_kc_house/features/credit_card/bloc/credit_card_fraud_bloc.dart';
import 'package:lab2_kc_house/features/credit_card/data/credit_card_fraud_data_model.dart';

import 'core/visualization/screens/analysis_screen.dart';
import 'features/histograms/configs/house_histogram_config.dart';
import 'features/histograms/configs/population_histogram_config.dart';
import 'features/house/bloc/house_bloc.dart';
import 'features/house/data/house_data_model.dart';
import 'features/population/bloc/population_bloc.dart';
import 'features/population/data/population_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Анализатор данных о недвижимости',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализатор данных'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context)=> BlocProvider(
                      create: (context)=> CreditCardFraudBloc(), 
                      child: CreditCardFraudAnalysisScreen(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Анализ мошенничества с кредитными картами'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => HouseDataBloc(),
                      child: const HouseAnalysisScreen(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Анализ недвижимости'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => PopulationBloc(),
                      child: const PopulationAnalysisScreen(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Анализ населения'),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template house_analysis_screen}
/// Специализированный экран для анализа данных о недвижимости.
/// {@endtemplate}
class HouseAnalysisScreen extends StatelessWidget {
  /// {@macro house_analysis_screen}
  const HouseAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericAnalysisScreen<HouseDataModel>(
      bloc: context.read<HouseDataBloc>(),
      title: 'Анализ недвижимости',
      histogramConfig: HouseHistogramConfig(),
      histogramTitle: 'Гистограммы распределения цен и площадей',
      boxPlotConfig: HouseBoxPlotConfig(),
      boxPlotTitle: 'Диаграмма размаха',
      autoLoad: true,
    );
  }
}

/// {@template population_analysis_screen}
/// Специализированный экран для анализа данных о населении.
/// {@endtemplate}
class PopulationAnalysisScreen extends StatelessWidget {
  /// {@macro population_analysis_screen}
  const PopulationAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericAnalysisScreen<PopulationData>(
      bloc: context.read<PopulationBloc>(),
      title: 'Анализ населения стран',
      histogramConfig: PopulationHistogramConfig(),  // Конфигурация для населения
      histogramTitle: 'Гистограммы распределения по странам',
      autoLoad: true,
    );
  }

}

/// {@template house_analysis_screen}
/// Специализированный экран для анализа данных о недвижимости.
/// {@endtemplate}
class CreditCardFraudAnalysisScreen extends StatelessWidget {
  /// {@macro house_analysis_screen}
  const CreditCardFraudAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericAnalysisScreen<CreditCardFraudDataModel>(
      bloc: context.read<CreditCardFraudBloc>(),
      title: 'Анализ мошенничества с кредитными картами',
      //histogramConfig: HouseHistogramConfig(),
      //histogramTitle: 'Гистограммы распределения цен и площадей',
      //boxPlotConfig: HouseBoxPlotConfig(),
      //boxPlotTitle: 'Диаграмма размаха',
      autoLoad: true,
    );
  }
}
