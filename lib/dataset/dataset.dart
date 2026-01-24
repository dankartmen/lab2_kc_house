import 'field_descriptor.dart';

class Dataset {
  final List<FieldDescriptor> fields;
  final List<Map<String, dynamic>> rows;

  Dataset({
    required this.fields,
    required this.rows,
  });

  Map<String, dynamic> rowAt(int i) => rows[i];

  List<dynamic> column(String key) =>
      rows.map((row) => row[key]).toList();

  /// Создает пустой датасет с заданными полями
  static Dataset empty({List<FieldDescriptor>? fields}) {
    return Dataset(
      fields: fields ?? [],
      rows: [],
    );
  }
}
