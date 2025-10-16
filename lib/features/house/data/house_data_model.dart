import 'dart:math';

import '../../../core/data/data_model.dart';

/// {@template house_data_model}
/// Модель данных для информации о домах из kc_house_data.csv
/// {@endtemplate}
class HouseDataModel extends DataModel {
  final String id;
  final DateTime date;
  final double price;
  final int bedrooms;
  final double bathrooms;
  final int sqftLiving;
  final int sqftLot;
  final double floors;
  final int waterfront;
  final int view;
  final int condition;
  final int grade;
  final int sqftAbove;
  final int sqftBasement;
  final int yrBuilt;
  final int yrRenovated;
  final String zipcode;
  final double lat;
  final double long;
  final int sqftLiving15;
  final int sqftLot15;

  const HouseDataModel({
    required this.id,
    required this.date,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqftLiving,
    required this.sqftLot,
    required this.floors,
    required this.waterfront,
    required this.view,
    required this.condition,
    required this.grade,
    required this.sqftAbove,
    required this.sqftBasement,
    required this.yrBuilt,
    required this.yrRenovated,
    required this.zipcode,
    required this.lat,
    required this.long,
    required this.sqftLiving15,
    required this.sqftLot15,
  });

  /// Создает объект из CSV строки
  factory HouseDataModel.fromCsv(List<dynamic> row) {
    return HouseDataModel(
      id: row[0].toString(),
      date: _parseDate(row[1].toString()),
      price: _parseDouble(row[2]),
      bedrooms: _parseInt(row[3]),
      bathrooms: _parseDouble(row[4]),
      sqftLiving: _parseInt(row[5]),
      sqftLot: _parseInt(row[6]),
      floors: _parseDouble(row[7]),
      waterfront: _parseInt(row[8]),
      view: _parseInt(row[9]),
      condition: _parseInt(row[10]),
      grade: _parseInt(row[11]),
      sqftAbove: _parseInt(row[12]),
      sqftBasement: _parseInt(row[13]),
      yrBuilt: _parseInt(row[14]),
      yrRenovated: _parseInt(row[15]),
      zipcode: row[16].toString(),
      lat: _parseDouble(row[17]),
      long: _parseDouble(row[18]),
      sqftLiving15: _parseInt(row[19]),
      sqftLot15: _parseInt(row[20]),
    );
  }

  static DateTime _parseDate(String dateStr) {
    try {
      // Формат: "20141013T000000"
      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now();
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    final str = value.toString();
    if (str.contains('e+')) {
      // Обработка научной нотации: "1.225e+006"
      final parts = str.split('e+');
      final base = double.parse(parts[0]);
      final exponent = int.parse(parts[1]);
      return base * pow(10, exponent).toDouble();
    }
    
    return double.tryParse(str) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sqft_living': sqftLiving,
      'sqft_lot': sqftLot,
      'floors': floors,
      'waterfront': waterfront,
      'view': view,
      'condition': condition,
      'grade': grade,
      'sqft_above': sqftAbove,
      'sqft_basement': sqftBasement,
      'yr_built': yrBuilt,
      'yr_renovated': yrRenovated,
      'zipcode': zipcode,
      'lat': lat,
      'long': long,
      'sqft_living15': sqftLiving15,
      'sqft_lot15': sqftLot15,
    };
  }

  @override
  String getDisplayName() {
    return 'Дом $id в $zipcode - \$${price.toStringAsFixed(0)}';
  }

  @override
  List<String> getNumericFields() {
    return [
      'price',
      'bedrooms',
      'bathrooms',
      'sqft_living',
      'sqft_lot',
      'floors',
      'waterfront',
      'view',
      'condition',
      'grade',
      'sqft_above',
      'sqft_basement',
      'yr_built',
      'yr_renovated',
      'lat',
      'long',
      'sqft_living15',
      'sqft_lot15',
    ];
  }

  @override
  double? getNumericValue(String field) {
    switch (field) {
      case 'price': return price;
      case 'bedrooms': return bedrooms.toDouble();
      case 'bathrooms': return bathrooms;
      case 'sqft_living': return sqftLiving.toDouble();
      case 'sqft_lot': return sqftLot.toDouble();
      case 'floors': return floors;
      case 'waterfront': return waterfront.toDouble();
      case 'view': return view.toDouble();
      case 'condition': return condition.toDouble();
      case 'grade': return grade.toDouble();
      case 'sqft_above': return sqftAbove.toDouble();
      case 'sqft_basement': return sqftBasement.toDouble();
      case 'yr_built': return yrBuilt.toDouble();
      case 'yr_renovated': return yrRenovated.toDouble();
      case 'lat': return lat;
      case 'long': return long;
      case 'sqft_living15': return sqftLiving15.toDouble();
      case 'sqft_lot15': return sqftLot15.toDouble();
      default: return null;
    }
  }
}