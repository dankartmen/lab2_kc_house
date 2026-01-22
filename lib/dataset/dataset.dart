import 'field_descriptor.dart';

class Dataset {
  final List<FieldDescriptor> fields;
  final List<Map<String, dynamic>> rows;

  Dataset({
    required this.fields,
    required this.rows,
  });

  List<dynamic> column(String key) =>
      rows.map((row) => row[key]).toList();
}
