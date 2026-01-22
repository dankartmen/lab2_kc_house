import 'field_descriptor.dart';

class SchemaInferer {
  static List<FieldDescriptor> infer(
    List<String> headers,
    List<List<String>> rows,
  ) {
    final descriptors = <FieldDescriptor>[];

    for (int col = 0; col < headers.length; col++) {
      final values = rows
          .map((r) => r[col])
          .where((v) => v.trim().isNotEmpty)
          .toList();

      final type = _inferType(values);

      descriptors.add(
        FieldDescriptor(
          key: headers[col],
          label: headers[col],
          type: type,
          min: _inferMin(type, values),
          max: _inferMax(type, values),
        ),
      );
    }

    return descriptors;
  }

  static FieldType _inferType(List<String> values) {
    if (values.isEmpty) return FieldType.categorical;

    final numeric = values.every((v) => double.tryParse(v) != null);
    if (numeric) {
      final unique = values.map((v) => v.trim()).toSet();
      if (unique.length <= 2 && unique.contains('0') && unique.contains('1')) {
        return FieldType.binary;
      }
      return FieldType.continuous;
    }

    return FieldType.categorical;
  }

  static double _min(List<String> values) =>
      values.map((v) => double.parse(v)).reduce((a, b) => a < b ? a : b);

  static double _max(List<String> values) =>
      values.map((v) => double.parse(v)).reduce((a, b) => a > b ? a : b);

  static double? _inferMin(FieldType type, List<String> values) {
    switch (type) {
      case FieldType.continuous:
        return _min(values);
      case FieldType.binary:
        return 0;
      case FieldType.categorical:
        return null;
    }
  }

  static double? _inferMax(FieldType type, List<String> values) {
    switch (type) {
      case FieldType.continuous:
        return _max(values);
      case FieldType.binary:
        return 1;
      case FieldType.categorical:
        return null;
    }
  }

}
