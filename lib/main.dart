import 'package:flutter/material.dart';
import 'dataset/csv_data_source.dart';
import 'dataset/dataset.dart';
import 'dataset/field_descriptor.dart';
import 'features/pair_plots/pair_plot.dart';
import 'features/pair_plots/pair_plot_config.dart';
import 'features/pair_plots/pair_plot_controller.dart';
import 'features/bi_model/bi_model.dart';
import 'features/pair_plots/pair_plot_style.dart';

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
  late PairPlotController controller;

  @override
  void initState() {
    super.initState();
  }

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

          // Hue для цвета
          final hueField = FieldDescriptor.categorical(
            key: 'Heart Attack Risk',
            label: 'Риск сердечного приступа',
          );

          // Инициализация контроллера с BIModel
          final model = BIModel(dataset);
          controller = PairPlotController(model);
          controller.initialize(dataset, hueField, ColorPalette.categorical);

          // Поля для визуализации
          final numericFields =
              dataset.fields.where((f) => f.type == FieldType.continuous).toList();

          return PairPlot(
            dataset: dataset,
            config: PairPlotConfig(
              dataset: dataset,
              fields: numericFields,
              hue: hueField,
              palette: ColorPalette.categorical,
              colorScale: controller.colorScale,
              style: const PairPlotStyle(
                dotSize: 4.0,
                alpha: 0.7,
                showHistDiagonal: true,
                showCorrelation: true,
                maxPoints: 100,
              ),
            ),
            controller: controller,
          );
        },
      ),
    );
  }
}
