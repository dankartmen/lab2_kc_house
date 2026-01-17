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
        Uri.parse('http://0.0.0.0:8000/api/diabetes-analysis'),
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
            
            _buildMetricsCard(),
            const SizedBox(height: 16),
            
            _buildROCCurve(),
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
            'Анализ модели логистической регрессии...',
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
        const Icon(Icons.linear_scale, color: Colors.green, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Анализ логистической регрессии для диабета',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Модель классификации с оценкой метрик precision, recall, F1-score и ROC-кривой',
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Модель: Logistic Regression',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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

  Widget _buildMetricsCard() {
    final modelResults = _analysisData?['models_results']?['Logistic Regression'];
    if (modelResults == null) return Container();
    
    final trainMetrics = modelResults['train_metrics'] ?? {};
    final testMetrics = modelResults['test_metrics'] ?? {};
    final aucScore = modelResults['auc_score'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Метрики производительности',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            
            // Тренировочная выборка
            _buildMetricsSection('Тренировочная выборка', trainMetrics),
            const SizedBox(height: 16),
            
            // Тестовая выборка
            _buildMetricsSection('Тестовая выборка', testMetrics),
            const SizedBox(height: 16),
            
            // AUC Score
            if (aucScore != null)
              _buildAUCScore(aucScore),
            
            // Кросс-валидация
            _buildCrossValidation(modelResults['cross_validation']),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(String title, Map<String, dynamic> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildMetricCard('Accuracy', metrics['accuracy'], 'Доля верных предсказаний'),
            _buildMetricCard('Precision', metrics['precision'], 'Точность положительных предсказаний'),
            _buildMetricCard('Recall', metrics['recall'], 'Полнота выявления положительных случаев'),
            _buildMetricCard('F1-Score', metrics['f1_score'], 'Сбалансированная метрика'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, dynamic value, String description) {
    final numValue = (value as num?)?.toDouble();
    final formatted = numValue?.toStringAsFixed(3) ?? 'N/A';
    
    Color color = Colors.black;
    if (numValue != null) {
      if (numValue >= 0.9) {
        color = Colors.green;
      } else if (numValue >= 0.8) {
        color = Colors.blue.shade700;
      } else if (numValue >= 0.7) {
        color = Colors.orange;
      } else {
        color = Colors.red;
      }
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              formatted,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAUCScore(double aucScore) {
    Color color = Colors.black;
    String quality = '';
    
    if (aucScore >= 0.9) {
      color = Colors.green;
      quality = 'Отлично';
    } else if (aucScore >= 0.8) {
      color = Colors.blue.shade700;
      quality = 'Хорошо';
    } else if (aucScore >= 0.7) {
      color = Colors.orange;
      quality = 'Удовлетворительно';
    } else {
      color = Colors.red;
      quality = 'Плохо';
    }
    
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.trending_up, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AUC-ROC Score',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    'Площадь под ROC-кривой',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  aucScore.toStringAsFixed(4),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  quality,
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrossValidation(Map<String, dynamic>? cvData) {
    if (cvData == null) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Кросс-валидация (5 folds)',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            _buildCVCard('Accuracy', cvData['accuracy']),
            const SizedBox(width: 12),
            _buildCVCard('F1-Score', cvData['f1_score']),
          ],
        ),
      ],
    );
  }

  Widget _buildCVCard(String label, Map<String, dynamic> data) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Mean: ${data['mean']?.toStringAsFixed(3) ?? 'N/A'}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Std: ${data['std']?.toStringAsFixed(3) ?? 'N/A'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildROCCurve() {
    final modelResults = _analysisData?['models_results']?['Logistic Regression'];
    final rocData = modelResults?['roc_curve'];
    final aucScore = modelResults?['auc_score'];
    
    if (rocData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('ROC-кривая недоступна', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Невозможно построить ROC-кривую для текущей модели'),
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
            const Text(
              'ROC-кривая (Logistic Regression)',
              style: TextStyle(fontWeight: FontWeight.bold),
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
            
            const SizedBox(height: 16),
            
            _buildROCLegend(),
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
          // ROC-кривая модели
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

  Widget _buildROCLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Logistic Regression', Colors.blue),
        const SizedBox(width: 20),
        _buildLegendItem('Случайный классификатор', Colors.grey),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFeatureImportance() {
    final modelResults = _analysisData?['models_results']?['Logistic Regression'];
    final featureImportance = modelResults?['feature_importance'];
    
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
            const Text(
              'Важность признаков (Logistic Regression)',
              style: TextStyle(fontWeight: FontWeight.bold),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            
            // Производительность модели
            if (interpretation['model_performance'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Производительность модели:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...(interpretation['model_performance'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),
            
            // Качество данных
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
            
            // Рекомендации
            if (interpretation['recommendation'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Рекомендации:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ...(interpretation['recommendation'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),
            
            // Ключевые признаки
            if (interpretation['key_features'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ключевые признаки:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ...(interpretation['key_features'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              ),
            
            // Интерпретация коэффициентов
            if (interpretation['model_interpretation'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Интерпретация коэффициентов:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ...(interpretation['model_interpretation'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(item),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}