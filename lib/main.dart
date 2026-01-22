import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/pair_plot_style.dart';
import 'dataset/csv_data_source.dart';
import 'dataset/dataset.dart';
import 'dataset/field_descriptor.dart';

import 'features/pair_plots/pair_plot_config.dart';
import 'features/pair_plots/pair_plot_widget.dart';


Future<void> main() async {
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

  Future<Dataset> _loadDataset() {
      final source = CsvDataSource(
        path: 'assets/heart_attack_prediction_dataset.csv',
      );

      return source.load();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализатор данных'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Dataset>(
        future: _loadDataset(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка загрузки: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Нет данных'));
          }

          final dataset = snapshot.data!;
          // for (final f in dataset.fields) {
          //   debugPrint('${f.key}: ${f.type} [${f.min}, ${f.max}]');
          // }
          return SingleChildScrollView(
            child: PairPlot(
              dataset: dataset,
              config: PairPlotConfig(
                dataset: dataset,
                fields: dataset.fields.where((f) => f.type != FieldType.categorical).toList(),
                style: const PairPlotStyle(
                  dotSize: 4.0,
                  alpha: 0.7,
                  showHistDiagonal: true,
                  showCorrelation: true,
                  maxPoints: 100,
                ),
                palette: ColorPalette.categorical,
                hue: FieldDescriptor.binary(key: 'Heart Attack Risk', label: 'Риск сердечного приступа'),
              ),
            ),
          );
        },
      ),
    );
  }
}