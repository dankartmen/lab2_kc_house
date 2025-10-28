import 'dart:math';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;  // Новый импорт для API
import 'package:lab2_kc_house/features/credit_card/data/credit_card_fraud_data_model.dart';
import 'dart:convert';  // Новый импорт для JSON
import '../../../features/histograms/histogram_config.dart';
import '../../../features/histograms/histogram_widget.dart';
import '../../../features/house/data/house_data_model.dart';
import '../../data/data_bloc.dart';
import '../../data/data_event.dart';
import '../../data/data_model.dart';
import '../../data/data_state.dart';
import '../charts/correlation_heatmap.dart';
import '../../../features/box_plots/box_plot_config.dart';
import '../../../features/box_plots/box_plot_widget.dart';
import '../charts/correlation_line_chart.dart';
import '../charts/year_price_line_chart.dart';

// Новый класс для парсинга метрик из JSON
class RegressionMetrics {
  final String model;
  final Map<String, double> train;
  final Map<String, double> test;
  RegressionMetrics.fromJson(Map<String, dynamic> json)
      : model = json['model'],
        train = Map<String, double>.from(json['train']),
        test = Map<String, double>.from(json['test']);
}

class DashedLinePainter extends CustomPainter {
  final Offset start;  // Data coords
  final Offset end;    // Data coords
  final double minX, maxX, minY, maxY;  // Data range
  final double marginLeft, marginBottom, marginTop, marginRight;  // Отступы для чарта (px)
  final double strokeWidth;
  final Color color;

  DashedLinePainter({
    required this.start,
    required this.end,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    this.marginLeft = 50.0,    // Для bottom titles (x-axis)
    this.marginBottom = 30.0,  // Для left titles (y-axis)
    this.marginTop = 10.0,     // Для top
    this.marginRight = 10.0,   // Для right
    this.strokeWidth = 2.0,
    this.color = Colors.red,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Эффективная область рисования (минус margins)
    final contentWidth = size.width - marginLeft - marginRight;
    final contentHeight = size.height - marginTop - marginBottom;

    // Scale (учитываем, что Y может быть отрицательным)
    final scaleX = contentWidth / (maxX - minX);
    final scaleY = contentHeight / (max(maxY, 0) - min(minY, 0));  // Abs range для Y

    // Функция dataToPixel с margins и инверсией Y
    Offset dataToPixel(Offset dataPoint) {
      final pixelX = marginLeft + (dataPoint.dx - minX) * scaleX;
      final pixelY = size.height - marginBottom - (dataPoint.dy - minY) * scaleY;  // Инверт Y
      return Offset(pixelX, pixelY);
    }

    final pixelStart = dataToPixel(start);
    final pixelEnd = dataToPixel(end);

    // Dashed drawing (как раньше)
    const dashWidth = 10.0;
    const dashSpace = 5.0;

    final dx = pixelEnd.dx - pixelStart.dx;
    final dy = pixelEnd.dy - pixelStart.dy;
    final length = sqrt(dx * dx + dy * dy);
    if (length == 0) return;

    final angle = atan2(dy, dx);

    var currentOffset = 0.0;
    while (currentOffset < length) {
      final dashStart = currentOffset;
      final dashEnd = min(currentOffset + dashWidth, length);

      final startX = pixelStart.dx + cos(angle) * dashStart;
      final startY = pixelStart.dy + sin(angle) * dashStart;
      final endX = pixelStart.dx + cos(angle) * dashEnd;
      final endY = pixelStart.dy + sin(angle) * dashEnd;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      currentOffset += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Данные для чартов
class ChartsData {
  final List<double> r2Train, r2Test, mseTrain, mseTest;
  final List<String> models;
  final List<double> scatterActual, scatterPred, residualsX, residualsY;
  ChartsData.fromJson(Map<String, dynamic> json)
      : r2Train = List<double>.from(json['charts_data']['r2_train']),
        r2Test = List<double>.from(json['charts_data']['r2_test']),
        mseTrain = List<double>.from(json['charts_data']['mse_train']),
        mseTest = List<double>.from(json['charts_data']['mse_test']),
        models = List<String>.from(json['charts_data']['models']),
        scatterActual = List<double>.from(json['charts_data']['scatter_actual']),
        scatterPred = List<double>.from(json['charts_data']['scatter_pred']),
        residualsX = List<double>.from(json['charts_data']['residuals_x']),
        residualsY = List<double>.from(json['charts_data']['residuals_y']);
}

/// {@template generic_analysis_screen}
/// Универсальный экран для анализа данных любого типа.
/// Предоставляет стандартный интерфейс для загрузки, анализа и визуализации данных.
/// {@endtemplate}
class GenericAnalysisScreen<T extends DataModel> extends StatelessWidget {
  /// BLoC для управления состоянием данных.
  final GenericBloc<T> bloc;

  /// Заголовок экрана.
  final String title;

  /// Флаг автоматической загрузки данных при инициализации.
  final bool autoLoad;

  /// Конфигурация для гистограмм
  final HistogramConfig<T>? histogramConfig;
  
  /// Заголовок для секции гистограмм
  final String? histogramTitle;

  /// Конфигурация для box plot
  final BoxPlotConfig<T>? boxPlotConfig;

  /// Заголовок для секции box plot
  final String? boxPlotTitle;
  
  
  /// {@macro generic_analysis_screen}
  const GenericAnalysisScreen({
    required this.bloc,
    required this.title,
    this.autoLoad = true,
    super.key, 
    this.histogramConfig,
    this.histogramTitle, 
    this.boxPlotConfig, 
    this.boxPlotTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Инициируем загрузку данных при создании экрана
    if (autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bloc.add(const LoadDataEvent());
      });
    }

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  /// Строит AppBar экрана анализа.
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => bloc.add(const LoadDataEvent()),
          tooltip: 'Обновить данные',
        ),
      ],
    );
  }

  /// Строит основное содержимое экрана.
  Widget _buildBody() {
    return BlocBuilder<GenericBloc<T>, DataState>(
      builder: (context, state) {
        return switch (state) {
          DataInitial() => _buildInitialState(),
          DataLoading() => _buildLoadingState(),
          DataLoaded<T>() => _buildAnalysisContent(state),
          DataError() => _buildErrorState(state),
          DataState() => throw UnimplementedError(),
        };
      },
    );
  }

  /// Строит контент анализа для загруженных данных.
  Widget _buildAnalysisContent(DataLoaded<T> state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatisticsCard(state),
          if (state is! DataLoaded<CreditCardFraudDataModel>)
            CorrelationHeatmap(correlationMatrix: state.correlationMatrix),
          // Новые линейные графики
          if (state is DataLoaded<HouseDataModel>)
            Column(
              children: [
                CorrelationLineChart(
                  correlations: state.correlationMatrix?['price'] ?? {},
                ),
                YearPriceLineChart(
                  data: state.data as List<HouseDataModel>,
                ),
                // Новая секция: Метрики регрессии (только для HouseDataModel)
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchMetrics(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      var metrics = (data['metrics'] as List).map((m) => RegressionMetrics.fromJson(m)).toList();
                      var chartsData = ChartsData.fromJson(data);
                      var conclusions = data['conclusions'];
                      return Column(
                        children: [
                          _buildRegressionDescriptions(data['descriptions']),
                          _buildMetricsTable(metrics),
                          _buildCharts(chartsData),  
                          _buildConclusions(conclusions), 
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ошибка загрузки метрик: ${snapshot.error}',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          if (histogramConfig != null)
            UniversalHistograms<T>(
              data: state.data,
              config: histogramConfig!,
              title: histogramTitle ?? 'Распределение данных по признакам',
            ),
          if (boxPlotConfig != null)
            UniversalBoxPlot<T>(
              data: state.data,
              config: boxPlotConfig!,
              title: boxPlotTitle ?? 'Ящики с усами: Распределение по признакам',
            ),
          
          _buildMetadataCard(state),
        ],
      ),
    );
  }

  /// Подготавливает данные для 3D графиков - преобразует в простой Map
  List<Map<String, dynamic>> _prepareDataFor3D(List<T> data) {
    return data.map((item) => item.toJson()).toList();
  }

  /// Строит карточку со статистикой данных.
  Widget _buildStatisticsCard(DataLoaded<T> state) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика данных',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem('Всего записей', state.data.length.toString()),
            _buildStatItem('Числовых полей', state.numericFields.length.toString()),
            _buildStatItem(
              'Источник данных', 
              state.metadata['dataSource']?.toString() ?? 'Неизвестно'
            ),
            _buildStatItem(
              'Время анализа', 
              _formatTimestamp(state.metadata['analysisTimestamp'])
            ),
            
          ],
        ),
      ),
    );
  }

  /// Строит элемент статистики.
  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Строит карточку с метаданными анализа.
  Widget _buildMetadataCard(DataLoaded<T> state) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Метаданные анализа',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Анализ выполнен: ${_formatTimestamp(state.metadata['analysisTimestamp'])}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  /// Строит состояние начальной загрузки.
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Готов к анализу данных',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите кнопку для загрузки данных',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Строит состояние загрузки.
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка и анализ данных...'),
        ],
      ),
    );
  }

  /// Строит состояние ошибки.
  Widget _buildErrorState(DataError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки данных',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => bloc.add(const LoadDataEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  /// Строит плавающую кнопку действия.
  Widget _buildFloatingActionButton() {
    return BlocBuilder<GenericBloc<T>, DataState>(
      builder: (context, state) {
        if (state is! DataLoaded<T>) {
          return const SizedBox(); // Скрываем FAB если данные не загружены
        }

        return FloatingActionButton(
          onPressed: () => _showAnalysisOptions(context, state),
          tooltip: 'Опции анализа',
          child: const Icon(Icons.tune),
        );
      },
    );
  }

  
  /// Показывает диалог с опциями анализа.
  void _showAnalysisOptions(BuildContext context, DataLoaded<T> state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Опции анализа'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Выберите поля для анализа:'),
              const SizedBox(height: 16),
              ...state.numericFields.map((field) => 
                CheckboxListTile(
                  title: Text(field),
                  value: true,
                  onChanged: (value) {
                    // Реализация выбора полей для анализа
                  },
                )
              ).toList(),
              
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  /// Форматирует timestamp для отображения.
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is DateTime) {
      return DateFormat('dd.MM.yyyy HH:mm').format(timestamp);
    }
    return 'Неизвестно';
  }

  // Асинхронный запрос метрик с FastAPI
  Future<Map<String, dynamic>> _fetchMetrics() async {
    final response = await http.get(Uri.parse('http://195.225.111.85:8000/api/metrics'),headers: {'Accept-Charset': 'utf-8'},);
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return json.decode(utf8Body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load analysis: ${response.statusCode}');
    }
  }

  // Новый метод: Карточка с описаниями моделей
  Widget _buildRegressionDescriptions(Map<String, dynamic> descriptions) {
    // Конвертируем в Map<String, String>, чтобы избежать ошибок (предполагаем, что все значения — строки)
    final Map<String, String> descMap = descriptions.map((key, value) => MapEntry(key, value.toString()));
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Описание моделей регрессии',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...descMap.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${e.key}: ${e.value}',
                style: TextStyle(
                  fontSize: 14,
                  fontFamilyFallback: ['Roboto', 'Noto Sans', 'Arial Unicode MS'],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Новый метод: Таблица метрик (только validation)
  Widget _buildMetricsTable(List<RegressionMetrics> metrics) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Метрики качества', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,  // Полная ширина для скролла
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 80.0,  // Фиксированная ширина между столбцами (увеличьте для видимости)
                  horizontalMargin: 16.0,  // Отступы слева/справа
                  dataRowHeight: 60.0,  // Высота строк для лучшего вида
                  headingRowHeight: 56.0,  // Высота заголовка
                  columns: const [
                    DataColumn(label: Text('Модель', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Train R²', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Test R²', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Train MAE', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Test MAE', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Train MSE', style: TextStyle(fontWeight: FontWeight.bold))),  // Явно
                    DataColumn(label: Text('Test MSE', style: TextStyle(fontWeight: FontWeight.bold))),  // Явно
                  ],
                  rows: metrics.map((m) {
                    // Форматирование: для MSE используем научную нотацию, если >1e6 (цены домов большие)
                    String formatLarge(double val) => val > 1e6 ? '${(val).toStringAsFixed(2)}' : val.toStringAsFixed(2);
                    
                    return DataRow(cells: [
                      DataCell(Text(m.model, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(m.train['R2']?.toStringAsFixed(4) ?? 'N/A')),
                      DataCell(Text(m.test['R2']?.toStringAsFixed(4) ?? 'N/A')),
                      DataCell(Text(m.train['MAE']?.toStringAsFixed(2) ?? 'N/A')),
                      DataCell(Text(m.test['MAE']?.toStringAsFixed(2) ?? 'N/A')),
                      DataCell(Text(formatLarge(m.train['MSE'] ?? 0))),  // MSE с форматированием
                      DataCell(Text(formatLarge(m.test['MSE'] ?? 0))),  // MSE с форматированием
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Новые графики (4 subplot как в примере; используем SizedBox для layout)
  Widget _buildCharts(ChartsData data) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Визуализация результатов', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(  // R² bar
                barGroups: [
                  for (int i = 0; i < data.models.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: data.r2Train[i], color: Colors.blue, width: 16),
                      BarChartRodData(toY: data.r2Test[i], color: Colors.red, width: 16),
                    ]),
                ],
                titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(data.models[value.toInt()])))),
              )),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(  // MSE bar
                barGroups: [
                  for (int i = 0; i < data.models.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: data.mseTrain[i], color: Colors.blue, width: 16),
                      BarChartRodData(toY: data.mseTest[i], color: Colors.red, width: 16),
                    ]),
                ],
                titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(data.models[value.toInt()])))),
              )),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  ScatterChart(  // Actual vs Predicted
                    ScatterChartData(
                      scatterSpots: [
                        for (int i = 0; i < data.scatterActual.length; i++)
                          ScatterSpot(data.scatterActual[i], data.scatterPred[i], show: true),
                      ],
                      minX: data.scatterActual.reduce(min),
                      maxX: data.scatterActual.reduce(max),
                      minY: data.scatterPred.reduce(min),
                      maxY: data.scatterPred.reduce(max),
                      titlesData: FlTitlesData(show: true),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  ScatterChart( // Residuals 
                    ScatterChartData(
                      scatterSpots: [
                        for (int i = 0; i < data.residualsX.length; i++)
                          ScatterSpot(
                            data.residualsX[i],
                            data.residualsY[i],
                            show: true,
                          ),
                      ],
                      minX: data.residualsX.reduce(min),
                      maxX: data.residualsX.reduce(max),
                      minY: data.residualsY.reduce(min),
                      maxY: data.residualsY.reduce(max),
                      titlesData: FlTitlesData(show: true),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      clipData: FlClipData.none(),
                    ),
                  ),
                  // Dashed линия y=0
                  CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: DashedLinePainter(
                      start: Offset(
                        data.residualsX.reduce(min),  // minX
                        0.0,  // y=0
                      ),
                      end: Offset(
                        data.residualsX.reduce(max),  // maxX
                        0.0,  // y=0
                      ),
                      minX: data.residualsX.reduce(min),
                      maxX: data.residualsX.reduce(max),
                      minY: data.residualsY.reduce(min),
                      maxY: data.residualsY.reduce(max),
                      marginBottom: 25
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Карточка выводов
  Widget _buildConclusions(Map<String, dynamic> conclusions) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Итоговые выводы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('1. Влияние характеристик на стоимость:'),
            ...List<String>.from(conclusions['influence']).map((s) => Text(s)),
            const SizedBox(height: 8),
            Text('2. Результаты моделирования:'),
            Text(conclusions['best_model']),
            const SizedBox(height: 8),
            const Text('3. Качество моделей:'),
            ...List<String>.from(conclusions['quality']).map((s) => Text(s)),
          ],
        ),
      ),
    );
  }
}