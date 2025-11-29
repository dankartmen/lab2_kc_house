import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab2_kc_house/features/box_plots/configs/house_box_plot_config.dart';
import 'package:lab2_kc_house/features/credit_card/bloc/credit_card_fraud_bloc.dart';
import 'package:lab2_kc_house/features/credit_card/data/credit_card_fraud_data_model.dart';
import 'package:lab2_kc_house/features/heart_attack/pair_plots/heart_attack_pair_plot_config.dart';
import 'package:lab2_kc_house/features/marketing/bloc/marketing_campaign_bloc.dart';
import 'package:lab2_kc_house/features/marketing/configs/grouped_marketing_campaign_pair_plot_config.dart';
import 'package:lab2_kc_house/features/marketing/configs/marketing_campaign_box_plot_config.dart';
import 'package:lab2_kc_house/features/marketing/configs/marketing_campaign_histogram_config.dart';
import 'package:lab2_kc_house/features/marketing/data/marketing_campaign_model.dart';

import 'core/visualization/screens/analysis_screen.dart';
import 'features/heart_attack/bloc/heart_attack_bloc.dart';
import 'features/heart_attack/box_plots/heart_attack_box_plot_config.dart';
import 'features/heart_attack/data/heart_attack_data_model.dart';
import 'features/heart_attack/heart_attack_analysis_widget.dart';
import 'features/heart_attack/histograms/heart_attack_histogram_config.dart';
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => HeartAttackBloc(),
                      child: const HeartAttackAnalysisScreen(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Анализ риска сердечных приступов'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => CreditCardFraudBloc(),
                      child: GenericAnalysisScreen<CreditCardFraudDataModel>(
                        bloc: CreditCardFraudBloc(),
                        title: 'Анализ мошенничества с картами',
                        autoLoad: true,
                        extraFraudAnalysisWidget: const FraudAnalysisContentWidget(),  // Встраиваем анализ
                      ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => MarketingCampaignBloc(),
                      child: const MarketingCampaignAnalysisScreen(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Анализ маркетинговой кампании'),
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

/// {@template heart_attack_analysis_screen}
/// Специализированный экран для анализа данных о рисках сердечных приступов.
/// {@endtemplate}
class HeartAttackAnalysisScreen extends StatelessWidget {
  /// {@macro heart_attack_analysis_screen}
  const HeartAttackAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericAnalysisScreen<HeartAttackDataModel>(
      bloc: context.read<HeartAttackBloc>(),
      title: 'Анализ риска сердечных приступов',
      histogramConfig: HeartAttackHistogramConfig(),
      histogramTitle: 'Гистограммы распределения факторов риска',
      boxPlotConfig: HeartAttackBoxPlotConfig(),
      boxPlotTitle: 'Диаграммы размаха по группам',
      pairPlotTitle: 'Парные диаграммы',
      autoLoad: true,
      extraAnalysisWidget: const HeartAttackAnalysisWidget(),
    );
  }
}

/// {@template marketing_campaign_analysis_screen}
/// Специализированный экран для анализа маркетинговой компании.
/// {@endtemplate}
class MarketingCampaignAnalysisScreen extends StatelessWidget {
  /// {@macro marketing_campaign_analysis_screen}
  const MarketingCampaignAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericAnalysisScreen<MarketingCampaignDataModel>(
      bloc: context.read<MarketingCampaignBloc>(),
      title: 'Анализ риска маркетинговой кампании',
      histogramConfig: MarketingCampaignHistogramConfig(),
      histogramTitle: 'Гистограммы для марркетинговой кампании',
      boxPlotConfig: MarketingCampaignBoxPlotConfig(),
      boxPlotTitle: 'Диаграммы размаха для маркетинговой кампании',
      //pairPlotTitle: 'Парные диаграммы',
      //pairPlotConfig: GroupedMarketingCampaignPairPlotConfig(),
      autoLoad: true,
    );
  }
}