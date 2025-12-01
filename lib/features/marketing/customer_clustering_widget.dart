// customer_clustering_widget.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerClusteringWidget extends StatefulWidget {
  final String apiUrl; // URL вашего API

  const CustomerClusteringWidget({super.key, required this.apiUrl});

  @override
  _CustomerClusteringWidgetState createState() => _CustomerClusteringWidgetState();
}

class _CustomerClusteringWidgetState extends State<CustomerClusteringWidget> {
  Map<String, dynamic>? _clusteringData;
  bool _isLoading = false;
  String _error = '';
  int _selectedModel = 0; // 0: K-Means, 1: Agglomerative, 2: DBSCAN
  int _selectedView = 0; // 0: 2D Scatter, 1: Elbow, 2: Silhouette, 3: Distribution

  @override
  void initState() {
    super.initState();
    _loadClusteringData();
  }

  Future<void> _loadClusteringData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(Uri.parse(widget.apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('error')) {
          setState(() {
            _error = data['error'];
            _isLoading = false;
          });
          return;
        }
        
        setState(() {
          _clusteringData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Ошибка загрузки данных: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }
    
    if (_error.isNotEmpty) {
      return _buildError();
    }
    
    if (_clusteringData == null) {
      return _buildEmpty();
    }
    
    return _buildContent();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка данных кластеризации...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            _error,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadClusteringData,
            child: Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text('Нет данных для отображения'),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            _buildHeader(),
            SizedBox(height: 16),
            
            // Информация о датасете
            _buildDatasetInfo(),
            SizedBox(height: 16),
            
            // Выбор модели и вида
            _buildControlPanel(),
            SizedBox(height: 16),
            
            // Визуализации
            _buildVisualizations(),
            SizedBox(height: 16),
            
            // Метрики моделей
            _buildMetricsTable(),
            SizedBox(height: 16),
            
            // Анализ кластеров
            _buildClusterAnalysis(),
            SizedBox(height: 16),
            
            // Интерпретация
            _buildInterpretation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.group, color: Colors.blue, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Анализ кластеризации клиентов',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Используются методы: K-Means, Agglomerative Clustering, DBSCAN',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadClusteringData,
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetInfo() {
    final datasetInfo = _clusteringData?['dataset_info'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Информация о данных',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Образцов: ${datasetInfo['total_samples'] ?? 0}'),
            Text('Признаков: ${datasetInfo['total_features'] ?? 0}'),
            Text('Числовых признаков: ${(datasetInfo['numeric_features'] as List?)?.length ?? 0}'),
            SizedBox(height: 8),
            if (datasetInfo['optimal_k'] != null)
              Text(
                'Оптимальное число кластеров: ${datasetInfo['optimal_k']}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки отображения',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            // Выбор модели
            Row(
              children: [
                Text('Модель:'),
                SizedBox(width: 12),
                ...['K-Means', 'Agglomerative', 'DBSCAN'].asMap().entries.map((entry) {
                  final index = entry.key;
                  final name = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(name),
                      selected: _selectedModel == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedModel = index;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 12),
            
            // Выбор вида визуализации
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('2D Scatter'),
                  selected: _selectedView == 0,
                  onSelected: (selected) => setState(() => _selectedView = 0),
                ),
                FilterChip(
                  label: Text('Elbow Method'),
                  selected: _selectedView == 1,
                  onSelected: (selected) => setState(() => _selectedView = 1),
                ),
                FilterChip(
                  label: Text('Silhouette'),
                  selected: _selectedView == 2,
                  onSelected: (selected) => setState(() => _selectedView = 2),
                ),
                FilterChip(
                  label: Text('Distribution'),
                  selected: _selectedView == 3,
                  onSelected: (selected) => setState(() => _selectedView = 3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizations() {
    if (_selectedView == 0) {
      return _buildScatterPlot();
    } else if (_selectedView == 1) {
      return _buildElbowChart();
    } else if (_selectedView == 2) {
      return _buildSilhouetteChart();
    } else {
      return _buildDistributionChart();
    }
  }

  Widget _buildScatterPlot() {
    final vizData = _clusteringData?['visualization_data']?['scatter_2d'];
    if (vizData == null || vizData['data'] == null) {
      return Container(
        height: 300,
        child: Center(child: Text('Нет данных для 2D визуализации')),
      );
    }
    
    final List<dynamic> points = vizData['data'];
    final List<String> features = List<String>.from(vizData['feature_names'] ?? []);
    
    // Группируем точки по кластерам
    Map<int, List<FlSpot>> clusters = {};
    String clusterKey = '';
    
    if (_selectedModel == 0) {
      clusterKey = 'kmeans_cluster';
    } else if (_selectedModel == 1) {
      clusterKey = 'agglomerative_cluster';
    } else {
      clusterKey = 'dbscan_cluster';
    }
    
    for (var point in points) {
      final x = point['x']?.toDouble() ?? 0.0;
      final y = point['y']?.toDouble() ?? 0.0;
      final cluster = point[clusterKey] ?? 0;
      
      clusters.putIfAbsent(cluster, () => []);
      clusters[cluster]!.add(FlSpot(x, y));
    }
    
    // Цвета для кластеров
    final List<Color> clusterColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.teal,
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2D Визуализация кластеров (${_getModelName(_selectedModel)})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Признаки: ${features.length >= 2 ? '${features[0]} vs ${features[1]}' : 'Недостаточно признаков'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Container(
              height: 400,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              features.isNotEmpty ? features[0] : 'X',
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            features.length >= 2 ? features[1] : 'Y',
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: clusters.entries.map((entry) {
                    final clusterIndex = entry.key;
                    final spots = entry.value;
                    
                    return LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: clusterColors[clusterIndex % clusterColors.length],
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: clusters.keys.map((cluster) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: clusterColors[cluster % clusterColors.length],
                    ),
                    SizedBox(width: 4),
                    Text('Кластер $cluster'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElbowChart() {
    final elbowData = _clusteringData?['clustering_results']?['elbow_method_data'];
    if (elbowData == null || elbowData.isEmpty) {
      return Container(
        height: 300,
        child: Center(child: Text('Нет данных для графика метода локтя')),
      );
    }
    
    final List<FlSpot> spots = [];
    for (var item in elbowData) {
      final k = item['k']?.toDouble() ?? 0.0;
      final wcss = item['wcss']?.toDouble() ?? 0.0;
      spots.add(FlSpot(k, wcss));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Метод локтя для определения оптимального k',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'WCSS (Within-Cluster Sum of Squares)',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilhouetteChart() {
    final silhouetteData = _clusteringData?['clustering_results']?['silhouette_method_data'];
    if (silhouetteData == null || silhouetteData.isEmpty) {
      return Container(
        height: 300,
        child: Center(child: Text('Нет данных для графика silhouette scores')),
      );
    }
    
    final List<FlSpot> spots = [];
    for (var item in silhouetteData) {
      final k = item['k']?.toDouble() ?? 0.0;
      final silhouette = item['silhouette']?.toDouble() ?? 0.0;
      spots.add(FlSpot(k, silhouette));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Silhouette Scores',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Чем выше значение, тем лучше качество кластеризации',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart() {
    final distributions = _clusteringData?['visualization_data']?['cluster_distributions'];
    final modelKey = _getModelKey(_selectedModel);
    
    if (distributions == null || distributions[modelKey] == null) {
      return Container(
        height: 300,
        child: Center(child: Text('Нет данных для распределения кластеров')),
      );
    }
    
    final distribution = distributions[modelKey]['distribution'] as List;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Распределение по кластерам (${_getModelName(_selectedModel)})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
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
                          final index = value.toInt();
                          if (index >= 0 && index < distribution.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                distribution[index]['label'],
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: distribution.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['count']?.toDouble() ?? 0.0,
                          color: _getClusterColor(index),
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: distribution.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return Chip(
                  backgroundColor: _getClusterColor(index),
                  label: Text(
                    '${data['label']}: ${data['count']} (${data['percentage']?.toStringAsFixed(1)}%)',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsTable() {
    final models = _clusteringData?['clustering_results']?['models'];
    if (models == null) return SizedBox();
    
    final modelNames = ['K-Means', 'Agglomerative', 'DBSCAN'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Метрики качества кластеризации',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Модель')),
                  DataColumn(label: Text('Кластеры')),
                  DataColumn(label: Text('Silhouette')),
                  DataColumn(label: Text('Calinski-Harabasz')),
                  DataColumn(label: Text('Davies-Bouldin')),
                ],
                rows: modelNames.asMap().entries.map((entry) {
                  final index = entry.key;
                  final name = entry.value;
                  final modelKey = _getModelKey(index);
                  final metrics = models[modelKey]?['metrics'] ?? {};
                  
                  return DataRow(cells: [
                    DataCell(Text(name)),
                    DataCell(Text('${metrics['n_clusters'] ?? 0}')),
                    DataCell(Text(metrics['silhouette_score']?.toStringAsFixed(3) ?? 'N/A')),
                    DataCell(Text(metrics['calinski_harabasz_score']?.toStringAsFixed(1) ?? 'N/A')),
                    DataCell(Text(metrics['davies_bouldin_score']?.toStringAsFixed(3) ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterAnalysis() {
    final analysis = _clusteringData?['cluster_analysis'];
    if (analysis == null || analysis.isEmpty) return SizedBox();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Анализ кластеров (K-Means)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...analysis.entries.map((entry) {
              final clusterKey = entry.key;
              final clusterInfo = entry.value as Map<String, dynamic>;
              
              return ExpansionTile(
                title: Text(
                  '$clusterKey: ${clusterInfo['size']} клиентов (${clusterInfo['percentage']?.toStringAsFixed(1)}%)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Средние значения:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        ...(clusterInfo['mean_values'] as Map<String, dynamic>).entries.map((metric) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(metric.key),
                                Text(metric.value.toStringAsFixed(2)),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretation() {
    final interpretation = _clusteringData?['interpretation'];
    if (interpretation == null) return SizedBox();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Интерпретация результатов',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            if (interpretation['summary'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сводка:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  ...(interpretation['summary'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• $item'),
                    );
                  }).toList(),
                  SizedBox(height: 16),
                ],
              ),
            
            if (interpretation['recommendations'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Рекомендации:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  ...(interpretation['recommendations'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
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

  // Вспомогательные методы
  String _getModelName(int index) {
    switch (index) {
      case 0: return 'K-Means';
      case 1: return 'Agglomerative';
      case 2: return 'DBSCAN';
      default: return '';
    }
  }

  String _getModelKey(int index) {
    switch (index) {
      case 0: return 'kmeans';
      case 1: return 'agglomerative';
      case 2: return 'dbscan';
      default: return '';
    }
  }

  Color _getClusterColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}