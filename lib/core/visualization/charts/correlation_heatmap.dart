import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

/// {@template correlation_heatmap}
/// Виджет для отображения тепловой карты корреляции.
/// Визуализирует матрицу корреляции между различными полями данных.
/// Поддерживает масштабирование с помощью Ctrl + колесико мыши.
/// {@endtemplate}
class CorrelationHeatmap extends StatefulWidget {
  /// Матрица корреляции для отображения.
  /// Ключи внешнего Map - названия строк, внутреннего - названия столбцов.
  final Map<String, Map<String, double>> correlationMatrix;

  /// {@macro correlation_heatmap}
  const CorrelationHeatmap({
    required this.correlationMatrix,
    super.key,
  });

  @override
  State<CorrelationHeatmap> createState() => _CorrelationHeatmapState();
}

class _CorrelationHeatmapState extends State<CorrelationHeatmap> {
  // Контроллер для трансформации (масштабирования и панорамирования)
  final TransformationController _transformationController =
      TransformationController();
  
  // Масштабирование
  double _scale = 1.0;
  static const double _minScale = 0.35;
  static const double _maxScale = 3.0;
  static const double _scaleStep = 0.1;
  
  // Размер ячейки (базовый, без масштабирования)
  static const double _baseCellWidth = 60.0;
  static const double _baseCellHeight = 40.0;
  static const double _baseRowHeaderWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Обработка прокрутки колесика мыши
  void _handleMouseWheel(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Проверяем, зажат ли Ctrl
      final bool isCtrlPressed = 
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed; // для Mac
      
      if (isCtrlPressed) {
        // Получаем позицию мыши относительно виджета
        final RenderBox? renderBox = 
            context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final localPosition = renderBox.globalToLocal(event.position);
          
          setState(() {
            final double oldScale = _scale;
            if (event.scrollDelta.dy < 0) {
              // Колесико вверх - увеличение
              _scale = (_scale + _scaleStep).clamp(_minScale, _maxScale);
            } else {
              // Колесико вниз - уменьшение
              _scale = (_scale - _scaleStep).clamp(_minScale, _maxScale);
            }
            
            // Применяем масштабирование относительно точки курсора
            final double scaleFactor = _scale / oldScale;
            final Offset focalPoint = localPosition;
            
            // Обновляем матрицу трансформации
            final Matrix4 matrix = _transformationController.value.clone();
            
            // Смещаем точку фокуса в начало координат
            matrix.translate(-focalPoint.dx, -focalPoint.dy);
            // Применяем масштабирование
            matrix.scale(scaleFactor, scaleFactor);
            // Возвращаем обратно
            matrix.translate(focalPoint.dx, focalPoint.dy);
            
            _transformationController.value = matrix;
          });
        }
      }
    }
  }

  /// Сброс масштабирования и позиции
  void _resetTransform() {
    setState(() {
      _scale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  /// Получение фактического размера ячейки с учетом масштаба
  double get _cellWidth => _baseCellWidth * _scale;
  double get _cellHeight => _baseCellHeight * _scale;
  double get _rowHeaderWidth => _baseRowHeaderWidth * _scale;

  @override
  Widget build(BuildContext context) {
    if (widget.correlationMatrix.isEmpty) {
      return _buildEmptyState();
    }

    final labels = widget.correlationMatrix.keys.toList();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: _buildInteractiveHeatmap(labels),
            ),
            const SizedBox(height: 16),
            _buildLegendAndControls(),
          ],
        ),
      ),
    );
  }

  /// Строит заголовок тепловой карты.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 4),
        Text(
          'Используйте Ctrl + колесико мыши для масштабирования', // Исправлено
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Строит интерактивную тепловую карту с поддержкой масштабирования
  Widget _buildInteractiveHeatmap(List<String> labels) {
    final totalWidth = _rowHeaderWidth + (labels.length * _cellWidth);
    final totalHeight = labels.length * _cellHeight;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Listener(
        onPointerSignal: _handleMouseWheel,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: _minScale,
          maxScale: _maxScale,
          boundaryMargin: EdgeInsets.all(20),
          constrained: true,
          onInteractionUpdate: (ScaleUpdateDetails details) {
            // Обновляем текущий масштаб при ручном масштабировании (pinch)
            if (details.scale != 1.0) {
              _scale = (_scale * details.scale).clamp(_minScale, _maxScale);
            }
          },
          child: SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
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
          ),
        ),
      ),
    );
  }

  /// Строит заголовки столбцов тепловой карты.
  Widget _buildColumnHeaders(List<String> labels) {
    return Row(
      children: [
        SizedBox(width: _rowHeaderWidth),
        ...labels.map((label) => 
          Container(
            width: _cellWidth,
            height: 30 * _scale,
            padding: EdgeInsets.symmetric(vertical: 4 * _scale),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _shortenLabel(label),
                style: TextStyle(
                  fontSize: 10 * _scale,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
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
            final correlation = widget.correlationMatrix[rowLabel]![colLabel] ?? 0.0;
            
            return _buildHeatmapCell(correlation, rowIndex, colIndex);
          }),
        ],
      );
    }).toList();
  }

  /// Строит заголовок строки.
  Widget _buildRowHeader(String label) {
    return Container(
      width: _rowHeaderWidth,
      height: _cellHeight,
      padding: EdgeInsets.symmetric(vertical: 4 * _scale),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _shortenLabel(label),
          style: TextStyle(
            fontSize: 10 * _scale,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
          maxLines: 2,
        ),
      ),
    );
  }

  /// Строит ячейку тепловой карты.
  Widget _buildHeatmapCell(double correlation, int row, int col) {
    final color = _getColorForCorrelation(correlation);
    final textColor = correlation.abs() > 0.3 ? Colors.white : Colors.black;

    return Container(
      width: _cellWidth,
      height: _cellHeight,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey[300]!, width: 0.5 * _scale),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            correlation.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 9 * _scale,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Строит легенду и элементы управления
  Widget _buildLegendAndControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildLegend(),
            ),
            _buildControls(),
          ],
        ),
      ],
    );
  }

  /// Строит легенду для тепловой карты.
  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Легенда корреляции',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 2,
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

  /// Строит элементы управления
  Widget _buildControls() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.zoom_out, size: 20),
              onPressed: () {
                setState(() {
                  _scale = (_scale - _scaleStep).clamp(_minScale, _maxScale);
                  _applyScaleToMatrix();
                });
              },
              tooltip: 'Уменьшить (Ctrl+колесико вниз)',
            ),
            Text(
              '${(_scale * 100).toInt()}%',
              style: TextStyle(fontSize: 12),
            ),
            IconButton(
              icon: Icon(Icons.zoom_in, size: 20),
              onPressed: () {
                setState(() {
                  _scale = (_scale + _scaleStep).clamp(_minScale, _maxScale);
                  _applyScaleToMatrix();
                });
              },
              tooltip: 'Увеличить (Ctrl+колесико вверх)',
            ),
            IconButton(
              icon: Icon(Icons.restore, size: 20),
              onPressed: _resetTransform,
              tooltip: 'Сбросить масштаб',
            ),
          ],
        ),
        Text(
          'Масштаб: ${_scale.toStringAsFixed(1)}x',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Применяет текущий масштаб к матрице трансформации
  void _applyScaleToMatrix() {
    final Matrix4 matrix = Matrix4.identity();
    matrix.scale(_scale, _scale);
    _transformationController.value = matrix;
  }

  /// Определяет цвет ячейки на основе значения корреляции.
  Color _getColorForCorrelation(double correlation) {
    // Яркие, насыщенные цвета для лучшей видимости
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
    if (label.length <= 10) return label;
    return '${label.substring(0, 9)}...';
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