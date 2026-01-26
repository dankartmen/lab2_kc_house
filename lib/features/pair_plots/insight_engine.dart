class InsightEngine {
  static String buildInsight({
    required String xLabel,
    required String yLabel,
    required double? correlation,
  }) {
    if (correlation == null) {
      return 'Недостаточно данных для анализа связи.';
    }

    final abs = correlation.abs();

    if (abs < 0.3) {
      return 'Между "$xLabel" и "$yLabel" не наблюдается выраженной связи.';
    }

    if (abs < 0.7) {
      return 'Между "$xLabel" и "$yLabel" существует умеренная зависимость.';
    }

    return correlation > 0
        ? 'Рост "$xLabel" сопровождается ростом "$yLabel".'
        : 'Рост "$xLabel" сопровождается снижением "$yLabel".';
  }
}
