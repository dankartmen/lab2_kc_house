import 'dart:math';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lab2_kc_house/features/credit_card/data/credit_card_fraud_data_model.dart';
import '../../../features/ROC/roc_chart_widget.dart';
import '../../../features/credit_card/bloc/credit_card_fraud_bloc.dart';
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
import 'package:lab2_kc_house/features/credit_card/data/fraud_analysis_model.dart';


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

  /// Дополнительный виджет, который можно вставить в контент анализа.
  /// Используется для встраивания специализированных панелей внутрь общего экрана анализа.
  final Widget? extraAnalysisWidget;

  /// Специфичный виджет для fraud-анализа (интегрирован вместо отдельного экрана).
  /// Использует bloc для состояния; отображается если T == CreditCardFraudDataModel.
  final Widget? extraFraudAnalysisWidget;
  
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
    this.extraAnalysisWidget,
    this.extraFraudAnalysisWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Инициируем загрузку данных при создании экрана
    if (autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bloc.add(const LoadDataEvent());
        // Если это fraud-экран, автоматически загружаем анализ
        if (extraFraudAnalysisWidget != null && bloc is CreditCardFraudBloc) {
          bloc.add(const LoadFraudAnalysisEvent());
        }
      });
    }

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(context),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => bloc.add(const LoadDataEvent()),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GenericBloc<T>, DataState>(
      builder: (context, state) {
        if (state is DataLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DataError) {
          return Center(child: Text(state.message));
        }
        if (state is! DataLoaded<T>) {
          return const Center(child: Text('Нет данных для отображения'));
        }

        final loadedState = state;
        List<Widget> children = [];

        // Карточка с общим обзором данных
        children.add(_buildDataSummary(loadedState));

        const SizedBox(height: 16);

        // Тепловая карта корреляции
        children.add(CorrelationHeatmap(
          correlationMatrix: loadedState.correlationMatrix,
        ));

        const SizedBox(height: 16);

        // Гистограммы, если конфиг предоставлен
        if (histogramConfig != null && histogramTitle != null) {
          children.add(
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(histogramTitle!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                  ],
                ),
              ),
            ),
          );
          children.add(const SizedBox(height: 16));
        }

        // Box plot, если конфиг предоставлен
        if (boxPlotConfig != null && boxPlotTitle != null) {
          children.add(
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(boxPlotTitle!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                  ],
                ),
              ),
            ),
          );
          children.add(const SizedBox(height: 16));
        }

        // Дополнительный виджет анализа (общий)
        if (extraAnalysisWidget != null) {
          children.add(extraAnalysisWidget!);
          children.add(const SizedBox(height: 16));
        }

        // Регрессионный анализ для house data (если метаданные содержат)
        if (T == HouseDataModel && loadedState.metadata.containsKey('regression_analysis')) {
          children.add(_buildRegressionAnalysis(loadedState.metadata['regression_analysis']));
        }

        // Интеграция fraud-виджета (если предоставлен)
        if (extraFraudAnalysisWidget != null && T == CreditCardFraudDataModel) {
          children.add(const SizedBox(height: 20));
          children.add(extraFraudAnalysisWidget!);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        );
      },
    );
  }

  Widget _buildDataSummary(DataLoaded<T> state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Обзор данных', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Всего записей: ${state.metadata['totalRecords']}'),
            Text('Числовых полей: ${state.metadata['numericFieldsCount']}'),
            Text('Источник: ${state.metadata['dataSource']}'),
            Text('Анализ выполнен: ${DateFormat('dd.MM.yyyy HH:mm').format(state.metadata['analysisTimestamp'])}'),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => bloc.add(AnalyzeDataEvent(fields: [])),
      child: const Icon(Icons.analytics),
    );
  }

  Widget _buildRegressionAnalysis(Map<String, dynamic> regressionData) {
    final metrics = List<RegressionMetrics>.from(
      regressionData['metrics'].map((m) => RegressionMetrics.fromJson(m)),
    );
    final conclusions = regressionData['conclusions'] as Map<String, dynamic>;
    final chartsData = ChartsData.fromJson(regressionData);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Регрессионный анализ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Таблица метрик
            _buildMetricsTable(metrics),
            const SizedBox(height: 16),
            // Графики
            _buildCharts(chartsData),
            const SizedBox(height: 16),
            // Выводы
            _buildConclusions(conclusions),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsTable(List<RegressionMetrics> metrics) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Модель')),
        DataColumn(label: Text('R² Train')),
        DataColumn(label: Text('R² Test')),
        DataColumn(label: Text('MSE Train')),
        DataColumn(label: Text('MSE Test')),
      ],
      rows: metrics.map((metric) => DataRow(cells: [
        DataCell(Text(metric.model)),
        DataCell(Text(metric.train['R2']!.toStringAsFixed(4))),
        DataCell(Text(metric.test['R2']!.toStringAsFixed(4))),
        DataCell(Text(metric.train['MSE']!.toStringAsFixed(2))),
        DataCell(Text(metric.test['MSE']!.toStringAsFixed(2))),
      ])).toList(),
    );
  }

  Widget _buildCharts(ChartsData data) {
    return Column(
      children: [
        // Bar chart для R²
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                for (int i = 0; i < data.models.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: data.r2Train[i], color: Colors.blue, width: 16),
                    BarChartRodData(toY: data.r2Test[i], color: Colors.red, width: 16),
                  ]),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(data.models[value.toInt()]),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Bar chart для MSE
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                for (int i = 0; i < data.models.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: data.mseTrain[i], color: Colors.blue, width: 16),
                    BarChartRodData(toY: data.mseTest[i], color: Colors.red, width: 16),
                  ]),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(data.models[value.toInt()]),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Scatter Actual vs Predicted
        SizedBox(
          height: 200,
          child: ScatterChart(
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
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Scatter Residuals с dashed линией y=0
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              ScatterChart(
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
                  marginBottom: 25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

class FraudAnalysisContentWidget extends StatelessWidget {
  const FraudAnalysisContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreditCardFraudBloc, DataState>(
      builder: (context, state) {
        if (state is DataLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DataError) {
          return Center(child: Text(state.message));
        } else if (state is DataLoaded<CreditCardFraudDataModel> && state.fraudAnalysis != null) {
          return _buildAnalysisContent(state.fraudAnalysis!);
        }
        return Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<CreditCardFraudBloc>().add(const LoadFraudAnalysisEvent());
            },
            child: const Text('Загрузить анализ мошенничества'),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisContent(FraudAnalysisModel analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatasetInfo(analysis.datasetInfo),
          const SizedBox(height: 20),
          _buildModelInfo(analysis.modelInfo),
          const SizedBox(height: 20),
          _buildMetricsComparison(analysis),
          const SizedBox(height: 20),
          _buildFeatureImportance(analysis.featureImportance),
          const SizedBox(height: 20),
          RocChartWidget(
            rocCurve: analysis.rocCurve,
            aucValue: analysis.metricsWithoutCV.rocAuc,
          ),
          const SizedBox(height: 20),
          _buildInterpretationGuide(),
        ],
      ),
    );
  }

  Widget _buildDatasetInfo(DatasetInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о наборе данных',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Всего транзакций: ${info.totalSamples}'),
            Text('Нормальные транзакции: ${info.normalTransactions}'),
            Text('Мошеннические транзакции: ${info.fraudTransactions}'),
            Text('Доля мошенничества: ${info.fraudPercentage}%'),
            Text('Используемые признаки: ${info.featuresUsed}'),
          ],
        ),
      ),
    );
  }

  Widget _buildModelInfo(ModelInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о модели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Тип модели: ${info.modelType}'),
            Text('Предобработка: ${info.standardization}'),
            Text('Размер тестовой выборки: ${info.testSize * 100}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsComparison(FraudAnalysisModel analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Метрики качества',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMetricTable('Без кросс-валидации', analysis.metricsWithoutCV),
            const SizedBox(height: 15),
            _buildCrossValidationMetrics(analysis.metricsWithCV),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTable(String title, Metrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: [
            _buildTableRow('Precision', metrics.precision),
            _buildTableRow('Recall', metrics.recall),
            _buildTableRow('F1-Score', metrics.f1Score),
            _buildTableRow('ROC-AUC', metrics.rocAuc),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String metric, double value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(metric),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value.toStringAsFixed(4)),
        ),
      ],
    );
  }

  Widget _buildCrossValidationMetrics(CrossValidationMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('С кросс-валидацией (5 folds)', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Метрика', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Среднее', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Стд.', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            _buildCVTableRow('Precision', metrics.precision),
            _buildCVTableRow('Recall', metrics.recall),
            _buildCVTableRow('F1-Score', metrics.f1Score),
            _buildCVTableRow('ROC-AUC', metrics.rocAuc),
          ],
        ),
      ],
    );
  }

  TableRow _buildCVTableRow(String metric, CVMetric cvMetric) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(metric),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(cvMetric.mean.toStringAsFixed(4)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(cvMetric.std.toStringAsFixed(4)),
        ),
      ],
    );
  }

  Widget _buildFeatureImportance(FeatureImportance importance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Важность признаков',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...importance.mostImportant.take(5).map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${feature[0]}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(feature[1].toStringAsFixed(4)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretationGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Интерпретация ROC-кривой',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildGuideItem('• Идеальный классификатор', 'Левый верхний угол (AUC = 1.0)'),
            _buildGuideItem('• Хороший классификатор', 'Кривая близка к левому верхнему углу'),
            _buildGuideItem('• Случайный классификатор', 'Диагональная линия (AUC = 0.5)'),
            _buildGuideItem('• Плохой классификатор', 'Кривая ниже диагонали (AUC < 0.5)'),
            const SizedBox(height: 10),
            const Text(
              'AUC (Area Under Curve) - площадь под кривой:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildGuideItem('0.9-1.0', 'Отличное качество'),
            _buildGuideItem('0.8-0.9', 'Очень хорошее'),
            _buildGuideItem('0.7-0.8', 'Хорошее'),
            _buildGuideItem('0.6-0.7', 'Посредственное'),
            _buildGuideItem('0.5-0.6', 'Плохое'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(description),
          ),
        ],
      ),
    );
  }
}