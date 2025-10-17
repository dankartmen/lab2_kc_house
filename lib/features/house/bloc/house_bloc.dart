import '../data/csv_house_data_source.dart';
import '../data/house_data_model.dart';

import '../../../core/data/data_bloc.dart';



/// {@template population_bloc}
/// BLoC для управления данными о населении стран.
/// Наследует общую логику GenericBloc и специализируется для работы с PopulationData.
/// {@endtemplate}
class HouseDataBloc extends GenericBloc<HouseDataModel> {
  /// {@macro population_bloc}
  HouseDataBloc() : super(dataSource: const CsvHouseDataSource());
}