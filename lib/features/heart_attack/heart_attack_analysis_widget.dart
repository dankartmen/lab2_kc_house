import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/data_event.dart';
import '../../core/data/data_state.dart';
import 'bloc/heart_attack_bloc.dart';
import 'data/heart_attack_data_model.dart';


class HeartAttackAnalysisWidget extends StatelessWidget {
  const HeartAttackAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeartAttackBloc, DataState>(
      builder: (context, state) {
        // Автоматически загружаем анализ при первой загрузке данных
        if (state is DataLoaded<HeartAttackDataModel> && 
            !state.metadata.containsKey('heart_attack_analysis') &&
            !state.metadata.containsKey('analysisError')) {
          // Загружаем анализ пост-фактум
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HeartAttackBloc>().add(const LoadAnalysisEvent());
          });
        }

        if (state is DataLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DataError) {
          return Center(child: Text(state.message));
        } else if (state is DataLoaded<HeartAttackDataModel>) {
          if (state.metadata.containsKey('heart_attack_analysis')) {
            return _buildAnalysisContent(state.metadata['heart_attack_analysis'], context);
          } else if (state.metadata.containsKey('analysisError')) {
            return _buildErrorState(state.metadata['analysisError'], context);
          }
        }

        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка анализа...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки анализа',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<HeartAttackBloc>().add(LoadAnalysisEvent());
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(Map<String, dynamic> analysis, BuildContext context) {
    // Защитная проверка структуры данных
    if (analysis.containsKey('error')) {
      return _buildErrorState(analysis['error'], context);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Анализ риска сердечных приступов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Безопасное построение компонентов с проверками
            if (analysis['dataset_info'] != null) 
              _buildDatasetInfo(analysis['dataset_info']),
            
            const SizedBox(height: 16),
            
            if (analysis['preprocessing_info'] != null) 
              _buildPreprocessingInfo(analysis['preprocessing_info']),
            
            const SizedBox(height: 16),
            
            if (analysis['models_results'] != null) 
              _buildModelsResults(analysis['models_results']),
            
            const SizedBox(height: 16),
            
            if (analysis['models_results'] != null) 
              _buildFeatureImportance(analysis['models_results']),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetInfo(Map<String, dynamic> info) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о наборе данных',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Всего пациентов: ${info['total_samples']}'),
            Text('С риском сердечного приступа: ${info['positive_cases']}'),
            Text('Без риска: ${info['negative_cases']}'),
            Text('Доля пациентов с риском: ${info['positive_percentage']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreprocessingInfo(Map<String, dynamic> info) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Предобработка данных',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Исходное количество признаков: ${info['original_features']}'),
            Text('После отбора признаков: ${info['features_after_selection']}'),
            Text('Использованный скейлер: ${info['scaler_used']}'),
            Text('Размер тестовой выборки: ${(info['test_size'] * 100).toInt()}%'),
            const SizedBox(height: 8),
            if (info['removed_features'] != null && info['removed_features'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Удаленные признаки (низкая корреляция):',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(info['removed_features'].join(', '), style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsResults(Map<String, dynamic> results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Результаты моделей (Accuracy)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Модель', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Train Accuracy', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Test Accuracy', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Разница', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...results.entries.map((entry) {
                  final modelName = entry.key;
                  final result = entry.value;
                  final trainAcc = result['train_accuracy'];
                  final testAcc = result['test_accuracy'];
                  final difference = (trainAcc - testAcc).abs();
                  
                  Color getDifferenceColor(double diff) {
                    if (diff < 0.05) return Colors.green;
                    if (diff < 0.1) return Colors.orange;
                    return Colors.red;
                  }

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(modelName),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(trainAcc.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(testAcc.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          difference.toStringAsFixed(4),
                          style: TextStyle(color: getDifferenceColor(difference)),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Интерпретация:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _buildInterpretationItem('Маленькая разница (< 0.05)', 'Хорошее обобщение'),
            _buildInterpretationItem('Средняя разница (0.05-0.1)', 'Возможное переобучение'),
            _buildInterpretationItem('Большая разница (> 0.1)', 'Переобучение'),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 3,
            child: Text(description, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureImportance(Map<String, dynamic> results) {
    // Берем важность признаков из Random Forest как наиболее репрезентативной
    final randomForestResults = results['Random Forest'];
    if (randomForestResults == null || randomForestResults['feature_importance'] == null) {
      return Container();
    }

    final featureImportance = Map<String, dynamic>.from(randomForestResults['feature_importance']);
    final sortedFeatures = featureImportance.entries.toList()
      ..sort((a, b) => (b.value as double).compareTo(a.value as double));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Важность признаков (Random Forest)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sortedFeatures.take(8).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(entry.key),
                    ),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: entry.value as double,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text((entry.value as double).toStringAsFixed(4)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}