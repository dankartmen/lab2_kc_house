class InterpretationGuide {
  static String getScatterInterpretation(double? correlation) {
    if (correlation == null) return 'Не удалось вычислить корреляцию';
    
    if (correlation.abs() > 0.7) {
      return 'Сильная ${correlation > 0 ? 'положительная' : 'отрицательная'} связь';
    } else if (correlation.abs() > 0.3) {
      return 'Умеренная ${correlation > 0 ? 'положительная' : 'отрицательная'} связь';
    } else {
      return 'Слабая или отсутствующая линейная связь';
    }
  }
  
  static String getHistogramInterpretation(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    
    if (variance < 0.1) return 'Равномерное распределение';
    if (mean > values.reduce((a, b) => a > b ? a : b) * 0.8) {
      return 'Смещённое распределение (высокие значения)';
    }
    return 'Нормальное распределение';
  }
}
