import 'package:flutter/material.dart';

/// {@template correlation_heatmap}
/// Виджет для отображения тепловой карты корреляции.
/// Визуализирует матрицу корреляции между различными полями данных.
/// {@endtemplate}
class CorrelationHeatmap extends StatelessWidget {
  /// Матрица корреляции для отображения.
  /// Ключи внешнего Map - названия строк, внутреннего - названия столбцов.
  final Map<String, Map<String, double>> correlationMatrix;

  /// {@macro correlation_heatmap}
  const CorrelationHeatmap({
    required this.correlationMatrix,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (correlationMatrix.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildHeatmapContent(),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// Строит заголовок тепловой карты.
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Тепловая карта корреляции',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Корреляция Пирсона между числовыми полями',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Строит основное содержимое тепловой карты.
  Widget _buildHeatmapContent() {
    final labels = correlationMatrix.keys.toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовки столбцов
              _buildColumnHeaders(labels),
              const SizedBox(height: 8),
              // Сама тепловая карта
              ..._buildHeatmapRows(labels),
            ],
          ),
        ),
      ),
    );
  }

  /// Строит заголовки столбцов тепловой карты.
  Widget _buildColumnHeaders(List<String> labels) {
    return Row(
      children: [
        SizedBox(width: 80), // Место для заголовков строк
        ...labels.map((label) => 
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _shortenLabel(label),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ),
      ],
    );
  }

  /// Строит строки тепловой карты.
  List<Widget> _buildHeatmapRows(List<String> labels) {
    return labels.asMap().entries.map((rowEntry) {
      final rowIndex = rowEntry.key;
      final rowLabel = rowEntry.value;
      
      return Row(
        children: [
          // Заголовок строки
          _buildRowHeader(rowLabel),
          // Ячейки тепловой карты
          ...labels.asMap().entries.map((colEntry) {
            final colIndex = colEntry.key;
            final colLabel = colEntry.value;
            final correlation = correlationMatrix[rowLabel]![colLabel] ?? 0.0;
            
            return _buildHeatmapCell(correlation, rowIndex, colIndex);
          }),
        ],
      );
    }).toList();
  }

  /// Строит заголовок строки.
  Widget _buildRowHeader(String label) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        _shortenLabel(label),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Строит ячейку тепловой карты.
  Widget _buildHeatmapCell(double correlation, int row, int col) {
    final color = _getColorForCorrelation(correlation);
    final textColor = correlation.abs() > 0.3 ? Colors.white : Colors.black;

    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          correlation.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// Строит легенду для тепловой карты.
  Widget _buildLegend() {
    return Column(
      children: [
        Text(
          'Легенда корреляции',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildLegendItem('Сильная отриц.', Colors.blue[900]!),
            _buildLegendItem('Средняя отриц.', Colors.blue[400]!),
            _buildLegendItem('Слабая отриц.', Colors.blue[200]!),
            _buildLegendItem('Нет связи', Colors.grey[200]!),
            _buildLegendItem('Слабая полож.', Colors.red[200]!),
            _buildLegendItem('Средняя полож.', Colors.red[400]!),
            _buildLegendItem('Сильная полож.', Colors.red[900]!),
          ],
        ),
      ],
    );
  }

  /// Строит элемент легенды.
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  /// Определяет цвет ячейки на основе значения корреляции.
  Color _getColorForCorrelation(double correlation) {
    if (correlation > 0.7) return Colors.red[900]!;
    if (correlation > 0.5) return Colors.red[700]!;
    if (correlation > 0.3) return Colors.red[400]!;
    if (correlation > 0.1) return Colors.red[200]!;
    if (correlation > -0.1) return Colors.grey[200]!;
    if (correlation > -0.3) return Colors.blue[200]!;
    if (correlation > -0.5) return Colors.blue[400]!;
    if (correlation > -0.7) return Colors.blue[700]!;
    return Colors.blue[900]!;
  }

  /// Укорачивает длинные labels для лучшего отображения.
  String _shortenLabel(String label) {
    if (label.length <= 8) return label;
    return '${label.substring(0, 7)}...';
  }

  /// Строит состояние при отсутствии данных.
  Widget _buildEmptyState() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'Нет данных для построения тепловой карты',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}