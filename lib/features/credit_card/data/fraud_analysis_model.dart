class FraudAnalysisModel {
  final DatasetInfo datasetInfo;
  final ModelInfo modelInfo;
  final Metrics metricsWithoutCV;
  final CrossValidationMetrics metricsWithCV;
  final RocCurve rocCurve;
  final FeatureImportance featureImportance;

  FraudAnalysisModel({
    required this.datasetInfo,
    required this.modelInfo,
    required this.metricsWithoutCV,
    required this.metricsWithCV,
    required this.rocCurve,
    required this.featureImportance,
  });

  factory FraudAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FraudAnalysisModel(
      datasetInfo: DatasetInfo.fromJson(json['dataset_info']),
      modelInfo: ModelInfo.fromJson(json['model_info']),
      metricsWithoutCV: Metrics.fromJson(json['metrics_without_cv']),
      metricsWithCV: CrossValidationMetrics.fromJson(json['metrics_with_cv']),
      rocCurve: RocCurve.fromJson(json['roc_curve']),
      featureImportance: FeatureImportance.fromJson(json['feature_importance']),
    );
  }
}

class DatasetInfo {
  final int totalSamples;
  final int normalTransactions;
  final int fraudTransactions;
  final double fraudPercentage;
  final int featuresUsed;
  final List<String> featureNames;

  DatasetInfo({
    required this.totalSamples,
    required this.normalTransactions,
    required this.fraudTransactions,
    required this.fraudPercentage,
    required this.featuresUsed,
    required this.featureNames,
  });

  factory DatasetInfo.fromJson(Map<String, dynamic>? json) {  
    if (json == null) {
      throw ArgumentError('JSON для DatasetInfo is null');
    }
    return DatasetInfo(
      totalSamples: json['total_samples'] ?? 0,  
      normalTransactions: json['normal_transactions'] ?? 0,
      fraudTransactions: json['fraud_transactions'] ?? 0,
      fraudPercentage: json['fraud_percentage'].toDouble() ?? 0,
      featuresUsed: json['features_used'] ?? 0,
      featureNames: List<String>.from(json['feature_names']),
    );
  }
}

class ModelInfo {
  final String modelType;
  final String standardization;
  final double testSize;
  final int randomState;

  ModelInfo({
    required this.modelType,
    required this.standardization,
    required this.testSize,
    required this.randomState,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelType: json['model_type'],
      standardization: json['standardization'],
      testSize: json['test_size'].toDouble(),
      randomState: json['random_state'],
    );
  }
}

class Metrics {
  final double precision;
  final double recall;
  final double f1Score;
  final double rocAuc;

  Metrics({
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.rocAuc,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      precision: json['precision'].toDouble(),
      recall: json['recall'].toDouble(),
      f1Score: json['f1_score'].toDouble(),
      rocAuc: json['roc_auc'].toDouble(),
    );
  }
}

class CrossValidationMetrics {
  final CVMetric precision;
  final CVMetric recall;
  final CVMetric f1Score;
  final CVMetric rocAuc;

  CrossValidationMetrics({
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.rocAuc,
  });

  factory CrossValidationMetrics.fromJson(Map<String, dynamic> json) {
    return CrossValidationMetrics(
      precision: CVMetric.fromJson(json['precision']),
      recall: CVMetric.fromJson(json['recall']),
      f1Score: CVMetric.fromJson(json['f1_score']),
      rocAuc: CVMetric.fromJson(json['roc_auc']),
    );
  }
}

class CVMetric {
  final double mean;
  final double std;
  final List<double> values;

  CVMetric({
    required this.mean,
    required this.std,
    required this.values,
  });

  factory CVMetric.fromJson(Map<String, dynamic> json) {
    return CVMetric(
      mean: json['mean'].toDouble(),
      std: json['std'].toDouble(),
      values: List<double>.from(json['values']),
    );
  }
}

class RocCurve {
  final List<double> fpr;
  final List<double> tpr;
  final List<double> thresholds;

  RocCurve({
    required this.fpr,
    required this.tpr,
    required this.thresholds,
  });

  factory RocCurve.fromJson(Map<String, dynamic> json) {
    return RocCurve(
      fpr: List<double>.from(json['fpr']),
      tpr: List<double>.from(json['tpr']),
      thresholds: List<double>.from(json['thresholds']),
    );
  }
}

class FeatureImportance {
  final Map<String, double> topFeatures;
  final List<List<dynamic>> mostImportant;

  FeatureImportance({
    required this.topFeatures,
    required this.mostImportant,
  });

  factory FeatureImportance.fromJson(Map<String, dynamic> json) {
    return FeatureImportance(
      topFeatures: Map<String, double>.from(json['top_features']),
      mostImportant: List<List<dynamic>>.from(json['most_important']),
    );
  }
}