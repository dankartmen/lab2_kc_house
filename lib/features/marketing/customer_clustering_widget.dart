
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerClusteringWidget extends StatefulWidget {
  final String apiUrl;

  const CustomerClusteringWidget({super.key, required this.apiUrl});

  @override
  _CustomerClusteringWidgetState createState() => _CustomerClusteringWidgetState();
}

class _CustomerClusteringWidgetState extends State<CustomerClusteringWidget> {
  Map<String, dynamic>? _clusteringData;
  bool _isLoading = false;
  String _error = '';
  int _selectedModel = 0;
  int _selectedView = 0;
  final List<Color> _clusterColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClusteringData();
    });
  }

  Future<void> _loadClusteringData() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _clusteringData = null;
    });

    try {
      log('Загрузка данных кластеризации из: ${widget.apiUrl}');
      final response = await http.get(
        Uri.parse(widget.apiUrl),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(const Duration(seconds: 30));

      log('Статус ответа: ${response.statusCode}');
      log('Длина ответа: ${response.body.length}');

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(utf8.decode(response.bodyBytes));
          log('Данные успешно декодированы');
          
          if (decoded is Map && decoded.containsKey('success')) {
            if (decoded['success'] == true) {
              setState(() {
                _clusteringData = decoded as Map<String, dynamic>;
                _isLoading = false;
              });
            } else {
              setState(() {
                _error = decoded['error'] ?? 'Неизвестная ошибка';
                _isLoading = false;
              });
            }
          } else if (decoded is Map && decoded.containsKey('error')) {
            setState(() {
              _error = decoded['error'];
              _isLoading = false;
            });
          } else {
            setState(() {
              _clusteringData = decoded;
              _isLoading = false;
            });
          }
        } catch (e) {
          log('Ошибка декодирования JSON: $e');
          setState(() {
            _error = 'Ошибка формата данных: $e';
            _isLoading = false;
          });
        }
      } else {
        String errorMsg = 'Ошибка сервера: ${response.statusCode}';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson is Map && errorJson.containsKey('error')) {
            errorMsg = errorJson['error'];
          } else if (errorJson is Map && errorJson.containsKey('detail')) {
            errorMsg = errorJson['detail'];
          }
        } catch (_) {}
        
        setState(() {
          _error = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Ошибка сети: $e');
      setState(() {
        _error = 'Ошибка сети: $e';
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
    
    if (_clusteringData == null) {
      return _buildEmpty();
    }
    
    // Проверяем успешность ответа
    if (_clusteringData!['success'] == false) {
      return _buildErrorWidget(_clusteringData!['error'] ?? 'Неизвестная ошибка');
    }
    
    return _buildMainContent();
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Анализ кластеризации...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            'Обработка данных...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text(
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
            onPressed: _loadClusteringData,
            icon: Icon(Icons.refresh),
            label: Text('Повторить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 40),
          const SizedBox(height: 10),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadClusteringData,
            child: Text('Попробовать снова'),
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
          Icon(Icons.info_outline, color: Colors.blue, size: 40),
          const SizedBox(height: 10),
          Text(
            'Нет данных для отображения',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadClusteringData,
            child: Text('Загрузить данные'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и кнопка обновления
            _buildHeader(),
            const SizedBox(height: 16),
            
            // Информация о датасете
            _buildDatasetInfo(),
            const SizedBox(height: 16),
            
            // Выбор модели и вида визуализации
            _buildControlPanel(),
            const SizedBox(height: 16),
            
            // Основная визуализация
            _buildMainVisualization(),
            const SizedBox(height: 16),
            
            // Метрики моделей
            _buildMetricsSection(),
            const SizedBox(height: 16),
            
            // Анализ кластеров
            _buildClusterAnalysis(),
            const SizedBox(height: 16),
            
            // Интерпретация
            _buildInterpretation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, color: Colors.blue, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Кластеризация клиентов',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Анализ сегментов клиентов с использованием методов машинного обучения',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadClusteringData,
          icon: Icon(Icons.refresh),
          tooltip: 'Обновить анализ',
        ),
      ],
    );
  }

  Widget _buildDatasetInfo() {
    final datasetInfo = _clusteringData?['dataset_info'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.data_array, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Данные для анализа',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Образцов: ${datasetInfo['total_samples'] ?? 0}'),
                  if (datasetInfo['samples_after_clean'] != null)
                    Text('После очистки: ${datasetInfo['samples_after_clean']}'),
                  Text('Признаков: ${datasetInfo['total_features'] ?? 0}'),
                  if (datasetInfo['optimal_k'] != null)
                    Text(
                      'Оптимальных кластеров: ${datasetInfo['optimal_k']}',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Настройки отображения', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Выбор модели
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('K-Means'),
                  selected: _selectedModel == 0,
                  onSelected: (selected) => setState(() => _selectedModel = 0),
                ),
                FilterChip(
                  label: Text('Agglomerative'),
                  selected: _selectedModel == 1,
                  onSelected: (selected) => setState(() => _selectedModel = 1),
                ),
                FilterChip(
                  label: Text('DBSCAN'),
                  selected: _selectedModel == 2,
                  onSelected: (selected) => setState(() => _selectedModel = 2),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Выбор вида визуализации
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: Text('Кластеры'),
                    avatar: Icon(Icons.scatter_plot, size: 16),
                    onPressed: () => setState(() => _selectedView = 0),
                    backgroundColor: _selectedView == 0 ? Colors.blue.shade100 : null,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text('Метод локтя'),
                    avatar: Icon(Icons.trending_down, size: 16),
                    onPressed: () => setState(() => _selectedView = 1),
                    backgroundColor: _selectedView == 1 ? Colors.blue.shade100 : null,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text('Silhouette'),
                    avatar: Icon(Icons.assessment, size: 16),
                    onPressed: () => setState(() => _selectedView = 2),
                    backgroundColor: _selectedView == 2 ? Colors.blue.shade100 : null,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text('Распределение'),
                    avatar: Icon(Icons.pie_chart, size: 16),
                    onPressed: () => setState(() => _selectedView = 3),
                    backgroundColor: _selectedView == 3 ? Colors.blue.shade100 : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVisualization() {
    switch (_selectedView) {
      case 0:
        return _buildScatterPlot();
      case 1:
        return _buildElbowChart();
      case 2:
        return _buildSilhouetteChart();
      case 3:
        return _buildDistributionChart();
      default:
        return Container();
    }
  }

  Widget _buildScatterPlot() {
    final vizData = _clusteringData?['visualization_data']?['scatter_2d'];
    if (vizData == null || (vizData as List).isEmpty) {
      return _buildNoDataCard('Нет данных для 2D визуализации');
    }
    
    final List<dynamic> points = vizData;
    
    // Группируем точки по кластерам выбранной модели
    String clusterKey = _getClusterKey();
    Map<int, List<FlSpot>> clusters = {};
    
    for (var point in points) {
      final x = (point['x'] as num?)?.toDouble() ?? 0.0;
      final y = (point['y'] as num?)?.toDouble() ?? 0.0;
      final cluster = (point[clusterKey] as num?)?.toInt() ?? 0;
      
      clusters.putIfAbsent(cluster, () => []);
      clusters[cluster]!.add(FlSpot(x, y));
    }
    
    // Находим границы для осей
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    
    for (var clusterPoints in clusters.values) {
      for (var point in clusterPoints) {
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y < minY) minY = point.y;
        if (point.y > maxY) maxY = point.y;
      }
    }
    
    // Добавляем отступы
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    final padding = 0.1;
    
    minX -= xRange * padding;
    maxX += xRange * padding;
    minY -= yRange * padding;
    maxY += yRange * padding;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Визуализация кластеров (${_getModelName()})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: clusters.entries.expand((entry) {
                    final clusterId = entry.key;
                    final points = entry.value;
                    return points.map((point) => ScatterSpot(
                      point.x,
                      point.y,
                      dotPainter: FlDotCirclePainter(
                        color: _getClusterColor(clusterId),
                        radius: 5,
                      ),
                    ));
                  }).toList(),
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
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
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: clusters.keys.map((clusterId) {
                final count = clusters[clusterId]?.length ?? 0;
                return Chip(
                  label: Text('Кластер $clusterId: $count точек'),
                  backgroundColor: _getClusterColor(clusterId),
                  labelStyle: TextStyle(color: Colors.white),
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
    if (elbowData == null || (elbowData as List).isEmpty) {
      return _buildNoDataCard('Нет данных для метода локтя');
    }
    
    final List<FlSpot> spots = [];
    for (var item in elbowData) {
      final k = (item['k'] as num).toDouble();
      final wcss = (item['wcss'] as num).toDouble();
      spots.add(FlSpot(k, wcss));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Метод локтя для определения оптимального числа кластеров',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('WCSS (Within-Cluster Sum of Squares)',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                        reservedSize: 50
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
    if (silhouetteData == null || (silhouetteData as List).isEmpty) {
      return _buildNoDataCard('Нет данных для silhouette scores');
    }
    
    final List<FlSpot> spots = [];
    for (var item in silhouetteData) {
      final k = (item['k'] as num).toDouble();
      final silhouette = (item['silhouette'] as num).toDouble();
      spots.add(FlSpot(k, silhouette));
    }
    
    double maxSilhouette = spots.map((spot) => spot.y).reduce((a,b) => a > b ? a : b);
    int bestK = spots.where((spot) => spot.y == maxSilhouette).first.x.toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Анализ качества кластеризации',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Карточка с пояснениями
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Что такое Silhouette Score?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Это метрика, которая показывает, насколько хорошо каждый объект отнесен к своему кластеру.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text('Значения от -1 до 1'),
                          backgroundColor: Colors.blue.shade100,
                          labelStyle: TextStyle(fontSize: 11),
                        ),
                        Chip(
                          label: Text('Выше = лучше'),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: TextStyle(fontSize: 11),
                        ),
                        Chip(
                          label: Text('Лучший k: $bestK'),
                          backgroundColor: Colors.orange.shade100,
                          labelStyle: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Интерпретация значений
            Row(
              children: [
                _buildScoreIndicator('Плохо', Colors.red, -1.0, 0.2),
                const SizedBox(width: 4),
                _buildScoreIndicator('Слабо', Colors.orange, 0.2, 0.4),
                const SizedBox(width: 4),
                _buildScoreIndicator('Средне', Colors.yellow.shade700, 0.4, 0.6),
                const SizedBox(width: 4),
                _buildScoreIndicator('Хорошо', Colors.lightGreen, 0.6, 0.8),
                const SizedBox(width: 4),
                _buildScoreIndicator('Отлично', Colors.green, 0.8, 1.0),
              ],
            ),
          const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine:(value) {
                      if (value == 0.2 || value == 0.4 || value == 0.6 || value == 0.8) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.5),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      }
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(2));
                        },
                        reservedSize: 35,
                        maxIncluded: false
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                    )
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

  // Вспомогательные методы для визуализации
Widget _buildScoreIndicator(String label, Color color, double min, double max) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 9,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDistributionChart() {
    final models = _clusteringData?['clustering_results']?['models'];
    final modelKey = _getModelKey();
    
    if (models == null || models[modelKey] == null) {
      return _buildNoDataCard('Нет данных для распределения кластеров');
    }
    
    final metrics = models[modelKey]['metrics'];
    final clusterSizes = metrics['cluster_sizes'] as Map<String, dynamic>?;
    
    if (clusterSizes == null || clusterSizes.isEmpty) {
      return _buildNoDataCard('Нет данных о размерах кластеров');
    }
    
    final List<MapEntry<String, dynamic>> entries = clusterSizes.entries.toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Распределение по кластерам (${_getModelName()})',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
                          if (value.toInt() >= 0 && value.toInt() < entries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                entries[value.toInt()].key,
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
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final clusterEntry = entry.value;
                    final count = (clusterEntry.value as num).toDouble();
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: count,
                          color: _getClusterColor(index),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final clusterEntry = entry.value;
                final count = clusterEntry.value as int;
                final total = metrics['n_clusters_total'] ?? entries.fold(0, (sum, e) => sum + (e.value as int));
                final percentage = total > 0 ? (count / total * 100) : 0;
                
                return Chip(
                  backgroundColor: _getClusterColor(index),
                  label: Text(
                    '${clusterEntry.key}: $count (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    final models = _clusteringData?['clustering_results']?['models'];
    if (models == null) return Container();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Метрики качества кластеризации',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
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
                rows: [
                  _buildMetricsRow('K-Means', models['kmeans']?['metrics']),
                  _buildMetricsRow('Agglomerative', models['agglomerative']?['metrics']),
                  _buildMetricsRow('DBSCAN', models['dbscan']?['metrics']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildMetricsRow(String modelName, Map<String, dynamic>? metrics) {
    if (metrics == null) {
      return DataRow(cells: [
        DataCell(Text(modelName)),
        const DataCell(Text('N/A')),
        const DataCell(Text('N/A')),
        const DataCell(Text('N/A')),
        const DataCell(Text('N/A')),
      ]);
    }
    
    return DataRow(cells: [
      DataCell(Text(modelName)),
      DataCell(Text('${metrics['n_clusters'] ?? 'N/A'}')),
      DataCell(_buildMetricCell(metrics['silhouette_score'])),
      DataCell(_buildMetricCell(metrics['calinski_harabasz_score'])),
      DataCell(_buildMetricCell(metrics['davies_bouldin_score'])),
    ]);
  }

  Widget _buildMetricCell(dynamic value) {
    if (value == null) return const Text('N/A');
    
    final numValue = (value as num).toDouble();
    String formatted = numValue.toStringAsFixed(3);
    
    // Добавляем цветовую индикацию для silhouette score
    if (value is double) {
      Color color = Colors.black;
      if (numValue > 0.7) {
        color = Colors.green;
      } else if (numValue > 0.5) {color = Colors.blue;}
      else if (numValue > 0.3) {color = Colors.orange;}
      else {color = Colors.red;}
      
      return Text(formatted, style: TextStyle(color: color, fontWeight: FontWeight.bold));
    }
    
    return Text(formatted);
  }

  Widget _buildClusterAnalysis() {
    final analysis = _clusteringData?['cluster_analysis'];
    if (analysis == null || analysis.isEmpty) {
      return _buildNoDataCard('Нет данных для анализа кластеров');
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Анализ кластеров (K-Means)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...analysis.entries.map((entry) {
              final clusterId = entry.key;
              final info = entry.value as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getClusterColor(int.tryParse(clusterId) ?? 0),
                    child: Text(clusterId, style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    'Кластер $clusterId: ${info['size']} клиентов (${info['percentage']?.toStringAsFixed(1)}%)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info['mean_values'] != null)
                            ...(info['mean_values'] as Map<String, dynamic>).entries.map((metric) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(metric.key, style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text(metric.value.toStringAsFixed(2)),
                                  ],
                                ),
                              );
                            }),
                        ],
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

  Widget _buildInterpretation() {
    final interpretation = _clusteringData?['interpretation'];
    if (interpretation == null) return Container();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Интерпретация результатов',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            
            if (interpretation['best_model'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Лучшая модель:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(interpretation['best_model']),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            if (interpretation['cluster_summary'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Сводка по кластерам:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ...(interpretation['cluster_summary'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.data_exploration, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательные методы
  String _getModelName() {
    switch (_selectedModel) {
      case 0: return 'K-Means';
      case 1: return 'Agglomerative';
      case 2: return 'DBSCAN';
      default: return '';
    }
  }

  String _getModelKey() {
    switch (_selectedModel) {
      case 0: return 'kmeans';
      case 1: return 'agglomerative';
      case 2: return 'dbscan';
      default: return '';
    }
  }

  String _getClusterKey() {
    switch (_selectedModel) {
      case 0: return 'kmeans_cluster';
      case 1: return 'agglomerative_cluster';
      case 2: return 'dbscan_cluster';
      default: return 'kmeans_cluster';
    }
  }

  Color _getClusterColor(int clusterId) {
    // Для DBSCAN, кластер -1 (шум) получает особый цвет
    if (clusterId == -1) return Colors.grey;
    
    final index = clusterId.abs() % _clusterColors.length;
    return _clusterColors[index];
  }
}