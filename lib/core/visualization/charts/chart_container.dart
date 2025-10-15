import 'package:flutter/material.dart';

/// {@template chart_container}
/// Контейнер для стандартизированного отображения графиков и диаграмм.
/// Предоставляет общий стиль, заголовок и обработку состояний для всех визуализаций.
/// {@endtemplate}
class ChartContainer extends StatelessWidget {
  /// Заголовок графика.
  final String title;

  /// Подзаголовок графика.
  final String? subtitle;

  /// Содержимое графика.
  final Widget child;

  /// Высота контейнера.
  final double height;

  /// Флаг показа индикатора загрузки.
  final bool isLoading;

  /// Флаг показа состояния ошибки.
  final bool hasError;

  /// Сообщение об ошибке.
  final String? errorMessage;

  /// {@macro chart_container}
  const ChartContainer({
    required this.title,
    required this.child,
    this.subtitle,
    this.height = 300,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// Строит заголовок графика.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Строит содержимое графика в зависимости от состояния.
  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    return child;
  }

  /// Строит состояние загрузки.
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Загрузка графика...'),
        ],
      ),
    );
  }

  /// Строит состояние ошибки.
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 8),
          Text(
            'Ошибка построения графика',
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}