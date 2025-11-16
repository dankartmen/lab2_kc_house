import '../data/csv_heart_attack_data_source.dart';
import '../data/heart_attack_data_model.dart';

import '../../../core/data/data_bloc.dart';

/// {@template heart_attack_bloc}
/// BLoC для управления данными о рисках сердечных приступов.
/// {@endtemplate}
class HeartAttackBloc extends GenericBloc<HeartAttackDataModel> {
  /// {@macro heart_attack_bloc}
  HeartAttackBloc() : super(dataSource: const CsvHeartAttackDataSource());
}