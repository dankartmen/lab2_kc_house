import 'dart:math';

class StatisticsUtils {
  static double pearsonCorrelation(
    List<double> x,
    List<double> y, {
    int? sample,
  }) {
    final n = min(x.length, y.length);
    if (n < 2) return 0.0;

    final effectiveN = sample != null ? min(sample, n) : n;
    final step = n / effectiveN;

    double sumX = 0, sumY = 0, sumXY = 0;
    double sumX2 = 0, sumY2 = 0;

    for (int i = 0; i < effectiveN; i++) {
      final index = (i * step).round().clamp(0, n - 1);
      final xi = x[index];
      final yi = y[index];

      sumX += xi;
      sumY += yi;
      sumXY += xi * yi;
      sumX2 += xi * xi;
      sumY2 += yi * yi;
    }

    final numerator = effectiveN * sumXY - sumX * sumY;
    final denominator = sqrt(
      (effectiveN * sumX2 - sumX * sumX) *
      (effectiveN * sumY2 - sumY * sumY),
    );

    return denominator == 0 ? 0.0 : numerator / denominator;
  }
}
