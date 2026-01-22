import 'field_descriptor.dart';
import 'dataset.dart';

class DatasetColumn {
  static List<double> numeric(
    Dataset dataset,
    FieldDescriptor field,
  ) {
    return dataset.rows
        .map((row) => row[field.key])
        .whereType<num>()
        .map((v) => v.toDouble())
        .toList();
  }

  static List<String> categorical(
    Dataset dataset,
    FieldDescriptor field,
  ) {
    return dataset.rows
        .map((row) => row[field.key])
        .whereType<String>()
        .toList();
  }
}
