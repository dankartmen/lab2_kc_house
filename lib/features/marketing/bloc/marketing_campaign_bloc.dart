import 'dart:convert';

import '../../../core/data/data_bloc.dart';
import '../data/csv_marketing_campaign_data_source.dart';
import '../data/marketing_campaign_model.dart';
import 'package:http/http.dart' as http;

/// {@template marketing_campaign_bloc}
/// BLoC для управления данными маркетинговой кампании.
/// {@endtemplate}
class MarketingCampaignBloc extends GenericBloc<MarketingCampaignDataModel> {
  MarketingCampaignBloc() : super(dataSource: const CsvMarketingCampaignDataSource());

  @override
  Future<Map<String, dynamic>> loadAnalysisData() async {
    try {
      final response = await http.get(Uri.parse('http://195.225.111.85:8000/api/marketing-campaign-analysis'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load marketing campaign analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading marketing campaign analysis: $e');
    }
  }
}