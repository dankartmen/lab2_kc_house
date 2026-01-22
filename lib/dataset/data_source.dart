import 'dataset.dart';

abstract class DataSource {
  Future<Dataset> load();
}
