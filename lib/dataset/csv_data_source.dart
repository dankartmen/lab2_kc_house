import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import 'data_source.dart';
import 'dataset.dart';
import 'field_descriptor.dart';
import 'schema_inferer.dart';

class CsvDataSource implements DataSource {
  final String path;
  final List<FieldDescriptor>? schema;

  CsvDataSource({
    required this.path,
    this.schema,
  });

  @override
  Future<Dataset> load() async {
    final csv = await rootBundle.loadString(path);
    final rows = const CsvToListConverter(eol: '\n').convert(csv);

    final headers = rows.first.cast<String>().map(normalizeKey).toList();
    final dataRows = rows.skip(1).map((r) => r.map((e) => e.toString()).toList()).toList();

    final inferredSchema =
        schema ?? SchemaInferer.infer(headers, dataRows);

    final parsedRows = <Map<String, dynamic>>[];

    for (final row in dataRows) {
      final map = <String, dynamic>{};

      for (int i = 0; i < headers.length; i++) {
        final field = inferredSchema[i];
        map[field.key] = field.parse(row[i]);
      }

      parsedRows.add(map);
    }

    return Dataset(
      fields: inferredSchema,
      rows: parsedRows,
    );
  }

  String normalizeKey(String s) {
    return s
        .replaceAll('\ufeff', '') // BOM
        .replaceAll('\r', '')     // Windows CR
        .replaceAll('\n', '')     // LF на всякий
        .trim();
  }
}
