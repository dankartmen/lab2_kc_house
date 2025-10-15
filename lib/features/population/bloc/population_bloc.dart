import '../../../core/data/data_bloc.dart';
import '../data/population_data_source.dart';
import '../data/population_model.dart';

/// {@template population_bloc}
/// BLoC для управления данными о населении стран.
/// Наследует общую логику GenericBloc и специализируется для работы с PopulationData.
/// {@endtemplate}
class PopulationBloc extends GenericBloc<PopulationData> {
  /// {@macro population_bloc}
  PopulationBloc() : super(dataSource: const PopulationDataSource());
}