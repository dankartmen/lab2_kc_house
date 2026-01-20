
import 'package:lab2_kc_house/core/data/field_descriptor.dart';

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

  MarketingCampaignDataModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        yearBirth = int.parse(map['yearBirth'].toString()),
        education = map['education'],
        maritalStatus = map['maritalStatus'],
        income = double.parse(map['income'].toString()),
        kidhome = int.parse(map['kidhome'].toString()),
        teenhome = int.parse(map['teenhome'].toString()),
        dtCustomer = map['dtCustomer'],
        recency = int.parse(map['recency'].toString()),
        mntWines = double.parse(map['mntWines'].toString()),
        mntFruits = double.parse(map['mntFruits'].toString()),
        mntMeatProducts = double.parse(map['mntMeatProducts'].toString()),
        mntFishProducts = double.parse(map['mntFishProducts'].toString()),
        mntSweetProducts = double.parse(map['mntSweetProducts'].toString()),
        mntGoldProds = double.parse(map['mntGoldProds'].toString()),
        numDealsPurchases = int.parse(map['numDealsPurchases'].toString()),
        numWebPurchases = int.parse(map['numWebPurchases'].toString()),
        numCatalogPurchases = int.parse(map['numCatalogPurchases'].toString()),
        numStorePurchases = int.parse(map['numStorePurchases'].toString()),
        numWebVisitsMonth = int.parse(map['numWebVisitsMonth'].toString()),
        acceptedCmp3 = int.parse(map['acceptedCmp3'].toString()),
        acceptedCmp4 = int.parse(map['acceptedCmp4'].toString()),
        acceptedCmp5 = int.parse(map['acceptedCmp5'].toString()),
        acceptedCmp1 = int.parse(map['acceptedCmp1'].toString()),
        acceptedCmp2 = int.parse(map['acceptedCmp2'].toString()),
        complain = int.parse(map['complain'].toString()),
        zCostContact = double.parse(map['zCostContact'].toString()),
        zRevenue = double.parse(map['zRevenue'].toString()),
        response = int.parse(map['response'].toString());

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

  @override
  List<FieldDescriptor> get fieldDescriptors => [
    FieldDescriptor.numeric(
      key: 'yearBirth',
      label: 'Год рождения',
    ),
    FieldDescriptor.numeric(
      key: 'income',
      label: 'Доход',
    ),
    FieldDescriptor.numeric(
      key: 'recency',
      label: 'Дней с последней покупки',
    ),
    FieldDescriptor.numeric(
      key: 'mntWines',
      label: 'Потрачено на вино',
    ),
    FieldDescriptor.numeric(
      key: 'mntFruits',
      label: 'Потрачено на фрукты',
    ),
    FieldDescriptor.numeric(
      key: 'mntMeatProducts',
      label: 'Потрачено на мясо',
    ),
    FieldDescriptor.numeric(
      key: 'mntFishProducts',
      label: 'Потрачено на рыбу',
    ),
    FieldDescriptor.numeric(
      key: 'mntSweetProducts',
      label: 'Потрачено на сладости',
    ),
    FieldDescriptor.numeric(
      key: 'mntGoldProds',
      label: 'Потрачено на золото',
    ),
    FieldDescriptor.numeric(
      key: 'zCostContact',
      label: 'Стоимость контакта',
    ),
    FieldDescriptor.numeric(
      key: 'zRevenue',
      label: 'Доход',
    ),
    FieldDescriptor.binary(
      key: 'response',
      label: 'Ответ на кампанию',
    ),
    FieldDescriptor.categorical(
      key: 'education',
      label: 'Образование',
    ),
  ];

  @override
  String? getCategoricalValue(String key) {
    switch (key) {
      case 'education': return education;
      case 'maritalStatus': return maritalStatus;
      default: return null;
    }
  }
}