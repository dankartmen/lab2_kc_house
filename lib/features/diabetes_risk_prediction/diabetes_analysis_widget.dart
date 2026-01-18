import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class DiabetesAnalysisWidget extends StatefulWidget {
  const DiabetesAnalysisWidget({Key? key}) : super(key: key);

  @override
  State<DiabetesAnalysisWidget> createState() => _DiabetesAnalysisWidgetState();
}

class _DiabetesAnalysisWidgetState extends State<DiabetesAnalysisWidget> {
  Map<String, dynamic>? _analysisData;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _analysisData = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/diabetes-analysis'),
      );

      if (response.statusCode == 200) {
        final jsonString = utf8.decode(response.bodyBytes);
        final decoded = json.decode(jsonString);
        if (decoded['success'] == false) {
          throw Exception(decoded['error'] ?? 'Ошибка загрузки анализа');
        }
        
        setState(() {
          _analysisData = decoded;
          _isLoading = false;
        });
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки анализа: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoading();
    }
    
    if (_error.isNotEmpty) {
      return _buildError();
    }
    
    if (_analysisData == null) {
      return _buildEmpty();
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            
            _buildDatasetInfo(),
            const SizedBox(height: 16),
            
            _buildRegressionMetrics(),
            const SizedBox(height: 16),
            
            _buildPredictionStats(),
            const SizedBox(height: 16),
            
            _buildCrossValidation(),
            const SizedBox(height: 16),
            
            _buildFeatureImportance(),
            const SizedBox(height: 16),
            
            _buildCoefficients(),
            const SizedBox(height: 16),
            
            _buildInterpretation(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Анализ Linear Regression модели...'),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          const Text(
            'Ошибка',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Text(_error),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAnalysisData,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 40),
            SizedBox(height: 10),
            Text('Нет данных анализа'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.trending_up, color: Colors.blue, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Linear Regression Анализ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Метрики регрессии для предсказания риска диабета',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadAnalysisData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Обновить анализ',
        ),
      ],
    );
  }

  Widget _buildDatasetInfo() {
    final datasetInfo = _analysisData?['dataset_info'] ?? {};
    final targetStats = datasetInfo['target_statistics'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о данных',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Всего образцов:', datasetInfo['total_samples']?.toString() ?? '0'),
            _buildInfoRow('Признаков:', datasetInfo['features_used']?.toString() ?? '0'),
            _buildInfoRow('Целевая переменная:', datasetInfo['target_variable']?.toString() ?? ''),
            _buildInfoRow('Train/Test:', '${datasetInfo['train_samples'] ?? 0}/${datasetInfo['test_samples'] ?? 0}'),
            const SizedBox(height: 8),
            const Text(
              'Статистика целевой переменной:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            _buildInfoRow('  Среднее:', targetStats['mean']?.toStringAsFixed(3) ?? '0'),
            _buildInfoRow('  Стандартное отклонение:', targetStats['std']?.toStringAsFixed(3) ?? '0'),
            _buildInfoRow('  Диапазон:', '[${targetStats['min']?.toStringAsFixed(1) ?? '0'}, ${targetStats['max']?.toStringAsFixed(1) ?? '0'}]'),
            _buildInfoRow('  Положительных случаев:', '${targetStats['positive_count'] ?? 0} (${targetStats['positive_percentage']?.toStringAsFixed(1) ?? '0'}%)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRegressionMetrics() {
    final modelResults = _analysisData?['model_results'] ?? {};
    final trainMetrics = modelResults['train_metrics'] ?? {};
    final testMetrics = modelResults['test_metrics'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Метрики регрессии',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Оценка качества Linear Regression модели',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            // График метрик регрессии
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final metrics = ['R²', 'MSE', 'RMSE', 'MAE', 'EV'];
                          if (value.toInt() >= 0 && value.toInt() < metrics.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                metrics[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(2));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: (trainMetrics['r2'] ?? 0).toDouble(),
                          color: Colors.blue.shade300,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: (testMetrics['r2'] ?? 0).toDouble(),
                          color: Colors.blue,
                          width: 12,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: (trainMetrics['mse'] ?? 0).toDouble(),
                          color: Colors.red.shade300,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: (testMetrics['mse'] ?? 0).toDouble(),
                          color: Colors.red,
                          width: 12,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: (trainMetrics['rmse'] ?? 0).toDouble(),
                          color: Colors.orange.shade300,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: (testMetrics['rmse'] ?? 0).toDouble(),
                          color: Colors.orange,
                          width: 12,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: (trainMetrics['mae'] ?? 0).toDouble(),
                          color: Colors.purple.shade300,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: (testMetrics['mae'] ?? 0).toDouble(),
                          color: Colors.purple,
                          width: 12,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: (trainMetrics['explained_variance'] ?? 0).toDouble(),
                          color: Colors.green.shade300,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: (testMetrics['explained_variance'] ?? 0).toDouble(),
                          color: Colors.green,
                          width: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Легенда
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Train', Colors.grey[300]!),
                const SizedBox(width: 20),
                _buildLegendItem('Test', Colors.grey[600]!),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Таблица метрик
            DataTable(
              columns: const [
                DataColumn(label: Text('Метрика', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Описание', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Train', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Test', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                _buildRegressionRow(
                  'R²',
                  'Коэффициент детерминации (чем ближе к 1, тем лучше)',
                  trainMetrics['r2'],
                  testMetrics['r2'],
                  isR2: true
                ),
                _buildRegressionRow(
                  'MSE',
                  'Среднеквадратичная ошибка (чем ближе к 0, тем лучше)',
                  trainMetrics['mse'],
                  testMetrics['mse']
                ),
                _buildRegressionRow(
                  'RMSE',
                  'Корень из MSE (в тех же единицах, что и целевая переменная)',
                  trainMetrics['rmse'],
                  testMetrics['rmse']
                ),
                _buildRegressionRow(
                  'MAE',
                  'Средняя абсолютная ошибка (чем ближе к 0, тем лучше)',
                  trainMetrics['mae'],
                  testMetrics['mae']
                ),
                _buildRegressionRow(
                  'Explained Variance',
                  'Объясненная дисперсия (чем ближе к 1, тем лучше)',
                  trainMetrics['explained_variance'],
                  testMetrics['explained_variance'],
                  isR2: true
                ),
                _buildRegressionRow(
                  'MAPE',
                  'Средняя абсолютная процентная ошибка (чем меньше, тем лучше)',
                  trainMetrics['mape'],
                  testMetrics['mape'],
                  isPercentage: true
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildRegressionRow(String metric, String description, dynamic trainValue, dynamic testValue, 
                             {bool isR2 = false, bool isPercentage = false}) {
    return DataRow(cells: [
      DataCell(Text(metric)),
      DataCell(Text(description, style: const TextStyle(fontSize: 12))),
      DataCell(_buildMetricCell(trainValue, isR2: isR2, isPercentage: isPercentage)),
      DataCell(_buildMetricCell(testValue, isR2: isR2, isPercentage: isPercentage)),
    ]);
  }

  Widget _buildMetricCell(dynamic value, {bool isR2 = false, bool isPercentage = false}) {
    final numValue = (value as num?)?.toDouble() ?? 0.0;
    final formatted = isPercentage ? 
        '${numValue.toStringAsFixed(1)}%' : 
        numValue.toStringAsFixed(isR2 ? 3 : 4);
    
    Color color = Colors.black;
    
    if (isR2 || isPercentage) {
      // Для R² и процентов - зеленый лучше
      if (isR2) {
        if (numValue >= 0.7) color = Colors.green;
        else if (numValue >= 0.5) color = Colors.blue;
        else if (numValue >= 0.3) color = Colors.orange;
        else color = Colors.red;
      } else if (isPercentage) {
        // Для MAPE - чем меньше, тем лучше
        if (numValue <= 10) color = Colors.green;
        else if (numValue <= 20) color = Colors.blue;
        else if (numValue <= 30) color = Colors.orange;
        else color = Colors.red;
      }
    } else {
      // Для ошибок - красный хуже
      if (numValue <= 0.05) color = Colors.green;
      else if (numValue <= 0.1) color = Colors.blue;
      else if (numValue <= 0.2) color = Colors.orange;
      else color = Colors.red;
    }
    
    return Text(
      formatted,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildPredictionStats() {
    final predStats = _analysisData?['model_results']?['prediction_stats'];
    if (predStats == null) return Container();
    
    final trainStats = predStats['train'] ?? {};
    final testStats = predStats['test'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика предсказаний',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Распределение предсказанных значений модели',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            DataTable(
              columns: const [
                DataColumn(label: Text('Статистика')),
                DataColumn(label: Text('Train')),
                DataColumn(label: Text('Test')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Минимум')),
                  DataCell(Text(trainStats['min']?.toStringAsFixed(3) ?? '0')),
                  DataCell(Text(testStats['min']?.toStringAsFixed(3) ?? '0')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Максимум')),
                  DataCell(Text(trainStats['max']?.toStringAsFixed(3) ?? '0')),
                  DataCell(Text(testStats['max']?.toStringAsFixed(3) ?? '0')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Среднее')),
                  DataCell(Text(trainStats['mean']?.toStringAsFixed(3) ?? '0')),
                  DataCell(Text(testStats['mean']?.toStringAsFixed(3) ?? '0')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Стандартное отклонение')),
                  DataCell(Text(trainStats['std']?.toStringAsFixed(3) ?? '0')),
                  DataCell(Text(testStats['std']?.toStringAsFixed(3) ?? '0')),
                ]),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Визуализация диапазона предсказаний
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Диапазон предсказаний:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildRangeBar('Train', trainStats['min'], trainStats['max']),
                  const SizedBox(height: 8),
                  _buildRangeBar('Test', testStats['min'], testStats['max']),
                  const SizedBox(height: 8),
                  Text(
                    'Идеальные предсказания должны быть в диапазоне [0, 1]',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeBar(String label, dynamic min, dynamic max) {
    final minVal = (min as num?)?.toDouble() ?? 0.0;
    final maxVal = (max as num?)?.toDouble() ?? 0.0;
    final range = maxVal - minVal;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label:'),
            Text('[${minVal.toStringAsFixed(2)}, ${maxVal.toStringAsFixed(2)}]'),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Маркер 0
              Container(
                width: 2,
                height: 12,
                color: Colors.grey,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final zeroPosition = 0.5 * constraints.maxWidth; // 0 в середине
                    final minPosition = zeroPosition + (minVal * constraints.maxWidth / 2);
                    final maxPosition = zeroPosition + (maxVal * constraints.maxWidth / 2);
                    
                    return Stack(
                      children: [
                        // Линия диапазона
                        Positioned(
                          left: minPosition,
                          width: maxPosition - minPosition,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getRangeColor(minVal, maxVal),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Маркер минимума
                        Positioned(
                          left: minPosition - 4,
                          child: Container(
                            width: 8,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Маркер максимума
                        Positioned(
                          left: maxPosition - 4,
                          child: Container(
                            width: 8,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Маркер 1
              Container(
                width: 2,
                height: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('-1', style: TextStyle(fontSize: 10)),
            Text('0', style: TextStyle(fontSize: 10)),
            Text('1', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Color _getRangeColor(double min, double max) {
    if (min >= 0 && max <= 1) return Colors.green;
    if (min >= -0.5 && max <= 1.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCrossValidation() {
    final cvData = _analysisData?['model_results']?['cross_validation'];
    if (cvData == null) return Container();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Кросс-валидация (5 фолдов)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Стабильность модели на разных подвыборках данных',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            DataTable(
              columns: const [
                DataColumn(label: Text('Метрика')),
                DataColumn(label: Text('Среднее', textAlign: TextAlign.center)),
                DataColumn(label: Text('Стд. отклонение', textAlign: TextAlign.center)),
                DataColumn(label: Text('Значения', textAlign: TextAlign.center)),
              ],
              rows: [
                _buildCVRow('R²', cvData['r2']),
                _buildCVRow('MSE', cvData['mse']),
                _buildCVRow('MAE', cvData['mae']),
                _buildCVRow('Explained Variance', cvData['explained_variance']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildCVRow(String name, Map<String, dynamic>? data) {
    if (data == null) {
      return DataRow(cells: [
        DataCell(Text(name)),
        const DataCell(Text('-')),
        const DataCell(Text('-')),
        const DataCell(Text('-')),
      ]);
    }
    
    final values = List<double>.from(data['values'] ?? []);
    final valuesStr = values.map((v) => v.toStringAsFixed(4)).join(', ');
    
    return DataRow(cells: [
      DataCell(Text(name)),
      DataCell(Text(data['mean']?.toStringAsFixed(4) ?? '-')),
      DataCell(Text(data['std']?.toStringAsFixed(4) ?? '-')),
      DataCell(
        Tooltip(
          message: valuesStr,
          child: Text(
            '${values.length} значений',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ),
    ]);
  }

  Widget _buildFeatureImportance() {
    final featureImportance = _analysisData?['model_results']?['feature_importance'];
    if (featureImportance == null || featureImportance.isEmpty) return Container();
    
    final sortedFeatures = (featureImportance as Map<String, dynamic>).entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
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
            const SizedBox(height: 8),
            Text(
              'Абсолютные значения коэффициентов Linear Regression',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            ...sortedFeatures.take(10).map((entry) {
              final feature = entry.key;
              final importance = (entry.value as num).toDouble();
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _getFeatureDescription(feature),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          importance.toStringAsFixed(3),
                          style: TextStyle(
                            color: importance > 0.5 ? Colors.green : 
                                  importance > 0.2 ? Colors.blue : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: importance,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        importance > 0.5 ? Colors.green : 
                        importance > 0.2 ? Colors.blue : Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoefficients() {
    final coefficients = _analysisData?['model_results']?['coefficients'];
    if (coefficients == null || coefficients.isEmpty) return Container();
    
    final sortedCoefficients = (coefficients as Map<String, dynamic>).entries.toList()
      ..sort((a, b) => (b.value as num).abs().compareTo((a.value as num).abs()));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Коэффициенты модели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Влияние признаков на целевую переменную',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            ...sortedCoefficients.take(10).map((entry) {
              final feature = entry.key;
              final coef = (entry.value as num).toDouble();
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getFeatureDescription(feature),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Chip(
                      label: Text(
                        coef.toStringAsFixed(3),
                        style: TextStyle(
                          color: coef > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: coef > 0 ? Colors.red.shade50 : Colors.green.shade50,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      coef > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: coef > 0 ? Colors.red : Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      coef > 0 ? '↑ увеличивает' : '↓ уменьшает',
                      style: TextStyle(
                        fontSize: 12,
                        color: coef > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getFeatureDescription(String feature) {
    final descriptions = {
      'Polyuria': 'Полиурия',
      'Polydipsia': 'Полидипсия',
      'sudden weight loss': 'Внезапная потеря веса',
      'weakness': 'Слабость',
      'Polyphagia': 'Полифагия',
      'Genital thrush': 'Молочница',
      'visual blurring': 'Нечеткое зрение',
      'Itching': 'Зуд',
      'Irritability': 'Раздражительность',
      'delayed healing': 'Замедленное заживление',
      'partial paresis': 'Частичный паралич',
      'muscle stiffness': 'Мышечная скованность',
      'Alopecia': 'Алопеция',
      'Obesity': 'Ожирение',
      'Age': 'Возраст',
      'Gender': 'Пол',
      'sex': 'Пол'
    };
    
    return descriptions[feature] ?? feature;
  }

  Widget _buildInterpretation() {
    final interpretation = _analysisData?['interpretation'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Интерпретация результатов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (interpretation['r2_quality'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  interpretation['r2_quality'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            
            if (interpretation['explained_variance'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(interpretation['explained_variance']),
              ),
            
            if (interpretation['error_interpretation'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(interpretation['error_interpretation']),
              ),
            
            if (interpretation['feature_interpretation'] != null)
              ...(interpretation['feature_interpretation'] as List).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(item),
                );
              }).toList(),
            
            const SizedBox(height: 16),
            
            if (interpretation['recommendations'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Рекомендации:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...(interpretation['recommendations'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    );
                  }).toList(),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Предупреждения
            Column(
              children: [
                if (interpretation['warning'] != null)
                  _buildWarningWidget(interpretation['warning']!),
                
                if (interpretation['data_warning'] != null)
                  _buildWarningWidget(interpretation['data_warning']!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningWidget(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}