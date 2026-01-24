import 'package:flutter/material.dart';
import 'features/bi_model/bi_page.dart';
import 'dataset/csv_data_source.dart';
import 'dataset/dataset.dart';
import 'dataset/field_descriptor.dart';
import 'features/bi_model/bi_model.dart';
import 'features/pair_plots/pair_plot_controller.dart';

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
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
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
  late final BIModel model;
  late final PairPlotController controller;

  @override
  void initState() {
    super.initState();

    model = BIModel(Dataset.empty());
    controller = PairPlotController(model);
  }

  Future<Dataset> _loadDataset() async {
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
      ),
      body: FutureBuilder<Dataset>(
        future: _loadDataset(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Ошибка загрузки: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Нет данных'));
          }

          final dataset = snapshot.data!;

          // 🔑 Один раз обновляем model
          model.setDataset(dataset);

          // 🔑 Hue задаётся через BIModel
          model.setHueField('cp');

          return BIPage(
            model: model,
            controller: controller,
          );
        },
      ),
    );
  }
}
