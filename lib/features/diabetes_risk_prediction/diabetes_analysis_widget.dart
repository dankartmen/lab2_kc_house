import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiabetesAnalysisWidget extends StatefulWidget {
  const DiabetesAnalysisWidget({Key? key}) : super(key: key);

  @override
  State<DiabetesAnalysisWidget> createState() => _DiabetesAnalysisWidgetState();
}

class _DiabetesAnalysisWidgetState extends State<DiabetesAnalysisWidget> {
  Map<String, dynamic>? _analysisData;
  bool _isLoading = false;
  String _error = '';
  int _selectedMetric = 0; // 0: accuracy, 1: precision, 2: recall, 3: f1, 4: auc
  int _selectedModelForROC = 0;

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
        Uri.parse('http://192.168.234.193/api/diabetes-analysis'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
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
      log('Ошибка загрузки анализа диабета: $e');
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
            
            _buildComparisonCharts(),
            const SizedBox(height: 16),
            
            _buildMetricsTable(),
            const SizedBox(height: 16),
            
            _buildROCCurves(),
            const SizedBox(height: 16),
            
            _buildFeatureImportance(),
            const SizedBox(height: 16),
            
            _buildInterpretation(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Анализ моделей диабета...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAnalysisData,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 40),
          const SizedBox(height: 10),
          const Text('Нет данных для отображения'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAnalysisData,
            child: const Text('Загрузить анализ'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.monitor_heart, color: Colors.green, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Анализ моделей предсказания диабета',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Сравнение производительности алгоритмов машинного обучения',
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
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.data_array, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Информация о датасете',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Всего образцов: ${datasetInfo['total_samples'] ?? 0}'),
                  Text('Признаков: ${datasetInfo['features_used'] ?? 0}'),
                  Text('Положительных случаев: ${datasetInfo['positive_cases'] ?? 0} (${datasetInfo['positive_percentage']?.toStringAsFixed(1) ?? '0'}%)'),
                  Text('Train/Test: ${datasetInfo['train_samples'] ?? 0}/${datasetInfo['test_samples'] ?? 0}'),
                  if (_analysisData?['best_model'] != null)
                    Text(
                      'Лучшая модель: ${_analysisData?['best_model']}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCharts() {
    final comparisonData = _analysisData?['comparison_data'];
    if (comparisonData == null) return Container();
    
    final List<String> models = List<String>.from(comparisonData['models'] ?? []);
    final List<double> testAccuracy = List<double>.from(comparisonData['test_accuracy'] ?? []);
    final List<double> testPrecision = List<double>.from(comparisonData['test_precision'] ?? []);
    final List<double> testRecall = List<double>.from(comparisonData['test_recall'] ?? []);
    final List<double> testF1 = List<double>.from(comparisonData['test_f1'] ?? []);
    final List<double> aucScores = List<double>.from(comparisonData['auc_scores'] ?? []);
    
    // Выбор метрики для отображения
    List<double> selectedMetricData;
    String metricName;
    
    switch (_selectedMetric) {
      case 0:
        selectedMetricData = testAccuracy;
        metricName = 'Accuracy';
        break;
      case 1:
        selectedMetricData = testPrecision;
        metricName = 'Precision';
        break;
      case 2:
        selectedMetricData = testRecall;
        metricName = 'Recall';
        break;
      case 3:
        selectedMetricData = testF1;
        metricName = 'F1-Score';
        break;
      case 4:
        selectedMetricData = aucScores;
        metricName = 'AUC';
        break;
      default:
        selectedMetricData = testAccuracy;
        metricName = 'Accuracy';
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сравнение метрик моделей',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Выбор метрики
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricChip('Accuracy', 0),
                  const SizedBox(width: 8),
                  _buildMetricChip('Precision', 1),
                  const SizedBox(width: 8),
                  _buildMetricChip('Recall', 2),
                  const SizedBox(width: 8),
                  _buildMetricChip('F1-Score', 3),
                  const SizedBox(width: 8),
                  _buildMetricChip('AUC', 4),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // График
            SizedBox(
              height: 250,
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
                          if (value.toInt() >= 0 && value.toInt() < models.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                models[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
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
                  barGroups: List.generate(
                    models.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: selectedMetricData[index],
                          color: _getModelColor(index),
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            Text(
              'Метрика: $metricName',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, int index) {
    return ActionChip(
      label: Text(label),
      backgroundColor: _selectedMetric == index ? Colors.blue.shade100 : null,
      onPressed: () => setState(() => _selectedMetric = index),
    );
  }

  Widget _buildMetricsTable() {
    final modelsResults = _analysisData?['models_results'];
    if (modelsResults == null) return Container();
    
    final models = modelsResults.keys.toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Детальные метрики моделей',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Модель')),
                  DataColumn(label: Text('Train\nAcc', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Test\nAcc', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Test\nPrecision', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Test\nRecall', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Test\nF1', textAlign: TextAlign.center)),
                  DataColumn(label: Text('AUC', textAlign: TextAlign.center)),
                ],
                rows: models.map((modelName) {
                  final modelData = modelsResults[modelName];
                  
                  if (modelData?['test_metrics'] == null) {
                    return DataRow(cells: [
                      DataCell(Text(modelName)),
                      const DataCell(Text('N/A')),
                      const DataCell(Text('N/A')),
                      const DataCell(Text('N/A')),
                      const DataCell(Text('N/A')),
                      const DataCell(Text('N/A')),
                      const DataCell(Text('N/A')),
                    ]);
                  }
                  
                  final trainMetrics = modelData['train_metrics'] ?? {};
                  final testMetrics = modelData['test_metrics'] ?? {};
                  final aucScore = modelData['auc_score'];
                  
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (modelName == _analysisData?['best_model']) {
                          return Colors.green.withOpacity(0.1);
                        }
                        return null;
                      },
                    ),
                    cells: [
                      DataCell(
                        Text(
                          modelName,
                          style: modelName == _analysisData?['best_model']
                              ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                              : null,
                        ),
                      ),
                      DataCell(_buildMetricCell(trainMetrics['accuracy'])),
                      DataCell(_buildMetricCell(testMetrics['accuracy'])),
                      DataCell(_buildMetricCell(testMetrics['precision'])),
                      DataCell(_buildMetricCell(testMetrics['recall'])),
                      DataCell(_buildMetricCell(testMetrics['f1_score'])),
                      DataCell(_buildMetricCell(aucScore)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCell(dynamic value) {
    if (value == null) return const Text('N/A', style: TextStyle(color: Colors.grey));
    
    final numValue = (value as num).toDouble();
    final formatted = numValue.toStringAsFixed(3);
    
    // Цветовая индикация
    Color color = Colors.black;
    if (numValue >= 0.9) {
      color = Colors.green;
    } else if (numValue >= 0.7) {
      color = Colors.blue;
    } else if (numValue >= 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    
    return Text(
      formatted,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildROCCurves() {
    final modelsResults = _analysisData?['models_results'];
    if (modelsResults == null) return Container();
    
    final models = modelsResults.keys.toList();
    final selectedModel = models[_selectedModelForROC];
    final modelData = modelsResults[selectedModel];
    final rocData = modelData?['roc_curve'];
    final aucScore = modelData?['auc_score'];
    
    if (rocData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('ROC-кривые недоступны', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Некоторые модели не поддерживают вероятностные предсказания'),
            ],
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'ROC-кривые',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Выбор модели для ROC
                DropdownButton<int>(
                  value: _selectedModelForROC,
                  items: List.generate(models.length, (index) {
                    final modelName = models[index];
                    final hasROC = modelsResults[modelName]?['roc_curve'] != null;
                    return DropdownMenuItem<int>(
                      value: index,
                      enabled: hasROC,
                      child: Text(
                        modelName,
                        style: TextStyle(
                          color: hasROC ? Colors.black : Colors.grey,
                        ),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedModelForROC = value);
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (aucScore != null)
              Text(
                'AUC = ${aucScore.toStringAsFixed(4)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 300,
              child: _buildROCChart(rocData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildROCChart(Map<String, dynamic> rocData) {
    final List<dynamic> fprList = rocData['fpr'] ?? [];
    final List<dynamic> tprList = rocData['tpr'] ?? [];
    
    if (fprList.isEmpty || tprList.isEmpty) {
      return const Center(child: Text('Нет данных для ROC-кривой'));
    }
    
    final spots = List.generate(
      fprList.length,
      (index) => FlSpot(
        (fprList[index] as num).toDouble(),
        (tprList[index] as num).toDouble(),
      ),
    );
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(1));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(1));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          // ROC-кривая
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          // Диагональ случайного классификатора
          LineChartBarData(
            spots: const [FlSpot(0, 0), FlSpot(1, 1)],
            isCurved: false,
            color: Colors.grey,
            barWidth: 1,
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureImportance() {
    final modelsResults = _analysisData?['models_results'];
    if (modelsResults == null) return Container();
    
    final bestModelName = _analysisData?['best_model'];
    if (bestModelName == null) return Container();
    
    final bestModelData = modelsResults[bestModelName];
    final featureImportance = bestModelData?['feature_importance'];
    
    if (featureImportance == null || featureImportance.isEmpty) {
      return Container();
    }
    
    // Сортируем признаки по важности
    final sortedFeatures = (featureImportance as Map<String, dynamic>).entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    final topFeatures = sortedFeatures.take(10).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Важность признаков (${bestModelName})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Топ-10 наиболее важных признаков для предсказания диабета',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            
            ...topFeatures.map((entry) {
              final feature = entry.key;
              final importance = (entry.value as num).toDouble();
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                    const SizedBox(height: 8),
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
      'Polyuria': 'Полиурия (учащенное мочеиспускание)',
      'Polydipsia': 'Полидипсия (сильная жажда)',
      'sudden weight loss': 'Внезапная потеря веса',
      'weakness': 'Слабость',
      'Polyphagia': 'Полифагия (повышенный аппетит)',
      'Genital thrush': 'Молочница',
      'visual blurring': 'Нечеткое зрение',
      'Itching': 'Зуд',
      'Irritability': 'Раздражительность',
      'delayed healing': 'Замедленное заживление ран',
      'partial paresis': 'Частичный паралич',
      'muscle stiffness': 'Мышечная скованность',
      'Alopecia': 'Алопеция (выпадение волос)',
      'Obesity': 'Ожирение',
      'Age': 'Возраст',
      'Gender': 'Пол'
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (interpretation['best_model'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Лучшая модель:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      interpretation['best_model'],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            if (interpretation['data_quality'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Качество данных:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(interpretation['data_quality']),
                  const SizedBox(height: 16),
                ],
              ),
            
            if (interpretation['recommendation'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Рекомендации:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  ...(interpretation['recommendation'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    );
                  }).toList(),
                ],
              ),
            
            if (interpretation['key_features'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Ключевые признаки:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  ...(interpretation['key_features'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getModelColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}