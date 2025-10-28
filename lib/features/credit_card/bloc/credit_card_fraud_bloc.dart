import '../data/csv_credit_card_fraud_data_source.dart';
import '../data/credit_card_fraud_data_model.dart';

import '../../../core/data/data_bloc.dart';

/// {@template credit_card_fraud_bloc}
/// BLoC для управления данными о мошенничестве с кредитными картами.
/// {@endtemplate}
class CreditCardFraudBloc extends GenericBloc<CreditCardFraudDataModel> {
  /// {@macro credit_card_fraud_bloc}
  CreditCardFraudBloc() : super(dataSource: const CsvCreditCardFraudDataSource());
}