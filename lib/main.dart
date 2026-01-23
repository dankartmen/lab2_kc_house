import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/pair_plot_style.dart';
import 'dataset/csv_data_source.dart';
import 'dataset/dataset.dart';
import 'dataset/field_descriptor.dart';

import 'features/pair_plots/pair_plot.dart';
import 'features/pair_plots/pair_plot_config.dart';
import 'features/pair_plots/pair_plot_controller.dart';
import 'features/pair_plots/scales/categorical_color_scale.dart';


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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PairPlotController controller;

  @override
  void initState() {
    super.initState();
    controller = PairPlotController();
  }

  Future<Dataset> _loadDataset() {
      final source = CsvDataSource(
        path: 'assets/test.csv',
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
          final colorScale = CategoricalColorScale.fromData(
            values: dataset.rows.map((r) => r['sex']).where((v) => v != null).map((v) => v.toString()).toList(),
            palette: ColorPalette.categorical,
          );
          return PairPlot(
              dataset: dataset,
              config: PairPlotConfig(
                colorScale: colorScale,
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
                
                hue: FieldDescriptor.binary(key: 'sex', label: 'Пол'),
              ),
              controller: controller,
            );
        },
      ),
    );
  }
}