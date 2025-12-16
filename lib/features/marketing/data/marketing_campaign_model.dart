
import '../../../core/data/data_model.dart';

/// {@template marketing_campaign_data_model}
/// Модель данных клиента для анализа маркетинговой кампании.
/// {@endtemplate}
class MarketingCampaignDataModel extends DataModel {
  /// ID клиента.
  final String id;

  /// Год рождения.
  final int yearBirth;

  /// Образование.
  final String education;

  /// Семейное положение.
  final String maritalStatus;

  /// Доход.
  final double income;

  /// Дети дома.
  final int kidhome;

  /// Подростки дома.
  final int teenhome;

  /// Дата регистрации клиента.
  final String dtCustomer;

  /// Дней с последней покупки.
  final int recency;

  /// Сумма потраченная на вино.
  final double mntWines;

  /// Сумма потраченная на фрукты.
  final double mntFruits;

  /// Сумма потраченная на мясо.
  final double mntMeatProducts;

  /// Сумма потраченная на рыбу.
  final double mntFishProducts;

  /// Сумма потраченная на сладости.
  final double mntSweetProducts;

  /// Сумма потраченная на золото.
  final double mntGoldProds;

  /// Количество покупок со скидкой.
  final int numDealsPurchases;

  /// Количество онлайн покупок.
  final int numWebPurchases;

  /// Количество покупок по каталогу.
  final int numCatalogPurchases;

  /// Количество покупок в магазине.
  final int numStorePurchases;

  /// Количество посещений сайта в месяц.
  final int numWebVisitsMonth;

  /// Принял кампанию 3.
  final int acceptedCmp3;

  /// Принял кампанию 4.
  final int acceptedCmp4;

  /// Принял кампанию 5.
  final int acceptedCmp5;

  /// Принял кампанию 1.
  final int acceptedCmp1;

  /// Принял кампанию 2.
  final int acceptedCmp2;

  /// Жаловался ли.
  final int complain;

  /// Стоимость контакта.
  final double zCostContact;

  /// Доход.
  final double zRevenue;

  /// Ответ на кампанию.
  final int response;

  /// {@macro marketing_campaign_data_model}
  const MarketingCampaignDataModel({
    required this.id,
    required this.yearBirth,
    required this.education,
    required this.maritalStatus,
    required this.income,
    required this.kidhome,
    required this.teenhome,
    required this.dtCustomer,
    required this.recency,
    required this.mntWines,
    required this.mntFruits,
    required this.mntMeatProducts,
    required this.mntFishProducts,
    required this.mntSweetProducts,
    required this.mntGoldProds,
    required this.numDealsPurchases,
    required this.numWebPurchases,
    required this.numCatalogPurchases,
    required this.numStorePurchases,
    required this.numWebVisitsMonth,
    required this.acceptedCmp3,
    required this.acceptedCmp4,
    required this.acceptedCmp5,
    required this.acceptedCmp1,
    required this.acceptedCmp2,
    required this.complain,
    required this.zCostContact,
    required this.zRevenue,
    required this.response,
  });

  /// Создаёт модель из CSV-строки.
  factory MarketingCampaignDataModel.fromCsv(List<dynamic> row) {
    return MarketingCampaignDataModel(
      id: row[0].toString(),
      yearBirth: int.tryParse(row[1].toString()) ?? 0,
      education: row[2].toString(),
      maritalStatus: row[3].toString(),
      income: double.tryParse(row[4].toString()) ?? 0.0,
      kidhome: int.tryParse(row[5].toString()) ?? 0,
      teenhome: int.tryParse(row[6].toString()) ?? 0,
      dtCustomer: row[7].toString(),
      recency: int.tryParse(row[8].toString()) ?? 0,
      mntWines: double.tryParse(row[9].toString()) ?? 0.0,
      mntFruits: double.tryParse(row[10].toString()) ?? 0.0,
      mntMeatProducts: double.tryParse(row[11].toString()) ?? 0.0,
      mntFishProducts: double.tryParse(row[12].toString()) ?? 0.0,
      mntSweetProducts: double.tryParse(row[13].toString()) ?? 0.0,
      mntGoldProds: double.tryParse(row[14].toString()) ?? 0.0,
      numDealsPurchases: int.tryParse(row[15].toString()) ?? 0,
      numWebPurchases: int.tryParse(row[16].toString()) ?? 0,
      numCatalogPurchases: int.tryParse(row[17].toString()) ?? 0,
      numStorePurchases: int.tryParse(row[18].toString()) ?? 0,
      numWebVisitsMonth: int.tryParse(row[19].toString()) ?? 0,
      acceptedCmp3: int.tryParse(row[20].toString()) ?? 0,
      acceptedCmp4: int.tryParse(row[21].toString()) ?? 0,
      acceptedCmp5: int.tryParse(row[22].toString()) ?? 0,
      acceptedCmp1: int.tryParse(row[23].toString()) ?? 0,
      acceptedCmp2: int.tryParse(row[24].toString()) ?? 0,
      complain: int.tryParse(row[25].toString()) ?? 0,
      zCostContact: double.tryParse(row[26].toString()) ?? 0.0,
      zRevenue: double.tryParse(row[27].toString()) ?? 0.0,
      response: int.tryParse(row[28].toString()) ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'yearBirth': yearBirth,
        'education': education,
        'maritalStatus': maritalStatus,
        'income': income,
        'kidhome': kidhome,
        'teenhome': teenhome,
        'dtCustomer': dtCustomer,
        'recency': recency,
        'mntWines': mntWines,
        'mntFruits': mntFruits,
        'mntMeatProducts': mntMeatProducts,
        'mntFishProducts': mntFishProducts,
        'mntSweetProducts': mntSweetProducts,
        'mntGoldProds': mntGoldProds,
        'numDealsPurchases': numDealsPurchases,
        'numWebPurchases': numWebPurchases,
        'numCatalogPurchases': numCatalogPurchases,
        'numStorePurchases': numStorePurchases,
        'numWebVisitsMonth': numWebVisitsMonth,
        'acceptedCmp3': acceptedCmp3,
        'acceptedCmp4': acceptedCmp4,
        'acceptedCmp5': acceptedCmp5,
        'acceptedCmp1': acceptedCmp1,
        'acceptedCmp2': acceptedCmp2,
        'complain': complain,
        'zCostContact': zCostContact,
        'zRevenue': zRevenue,
        'response': response,
      };

  @override
  String getDisplayName() => 'Customer $id (Income: \$${income.toInt()})';

  @override
  List<String> getNumericFields() => [
        'yearBirth',
        'income',
        'kidhome',
        'teenhome',
        'recency',
        'mntWines',
        'mntFruits',
        'mntMeatProducts',
        'mntFishProducts',
        'mntSweetProducts',
        'mntGoldProds',
        'numDealsPurchases',
        'numWebPurchases',
        'numCatalogPurchases',
        'numStorePurchases',
        'numWebVisitsMonth',
        'acceptedCmp3',
        'acceptedCmp4',
        'acceptedCmp5',
        'acceptedCmp1',
        'acceptedCmp2',
        'complain',
        'zCostContact',
        'zRevenue',
        'response',
      ];

  @override
  double? getNumericValue(String field) {
    switch (field) {
      case 'yearBirth': return yearBirth.toDouble();
      case 'income': return income;
      case 'kidhome': return kidhome.toDouble();
      case 'teenhome': return teenhome.toDouble();
      case 'recency': return recency.toDouble();
      case 'mntWines': return mntWines;
      case 'mntFruits': return mntFruits;
      case 'mntMeatProducts': return mntMeatProducts;
      case 'mntFishProducts': return mntFishProducts;
      case 'mntSweetProducts': return mntSweetProducts;
      case 'mntGoldProds': return mntGoldProds;
      case 'numDealsPurchases': return numDealsPurchases.toDouble();
      case 'numWebPurchases': return numWebPurchases.toDouble();
      case 'numCatalogPurchases': return numCatalogPurchases.toDouble();
      case 'numStorePurchases': return numStorePurchases.toDouble();
      case 'numWebVisitsMonth': return numWebVisitsMonth.toDouble();
      case 'acceptedCmp3': return acceptedCmp3.toDouble();
      case 'acceptedCmp4': return acceptedCmp4.toDouble();
      case 'acceptedCmp5': return acceptedCmp5.toDouble();
      case 'acceptedCmp1': return acceptedCmp1.toDouble();
      case 'acceptedCmp2': return acceptedCmp2.toDouble();
      case 'complain': return complain.toDouble();
      case 'zCostContact': return zCostContact;
      case 'zRevenue': return zRevenue;
      case 'response': return response.toDouble();
      default: return null;
    }
  }
}