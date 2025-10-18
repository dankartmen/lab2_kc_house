import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../features/histograms/histogram_config.dart';
import '../../../features/histograms/histogram_widget.dart';
import '../../data/data_bloc.dart';
import '../../data/data_event.dart';
import '../../data/data_model.dart';
import '../../data/data_state.dart';
import '../charts/correlation_heatmap.dart';
import '../../../features/box_plots/box_plot_config.dart';
import '../../../features/box_plots/box_plot_widget.dart';

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

  final HistogramConfig<T>? histogramConfig;
  
  final String? histogramTitle;

  final BoxPlotConfig<T>? boxPlotConfig;

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
          CorrelationHeatmap(correlationMatrix: state.correlationMatrix),
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
}