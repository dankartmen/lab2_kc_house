import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lab2_kc_house/core/data/field_descriptor.dart';

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
  HouseDataModel.fromMap(Map<String, dynamic> map)
      : id = map['id'].toString(),
        date = _parseDate(map['date'].toString()),
        price = _parseDouble(map['price']),
        bedrooms = _parseInt(map['bedrooms']),
        bathrooms = _parseDouble(map['bathrooms']),
        sqftLiving = _parseInt(map['sqft_living']),
        sqftLot = _parseInt(map['sqft_lot']),
        floors = _parseDouble(map['floors']),
        waterfront = _parseInt(map['waterfront']),
        view = _parseInt(map['view']),
        condition = _parseInt(map['condition']),
        grade = _parseInt(map['grade']),
        sqftAbove = _parseInt(map['sqft_above']),
        sqftBasement = _parseInt(map['sqft_basement']),
        yrBuilt = _parseInt(map['yr_built']),
        yrRenovated = _parseInt(map['yr_renovated']),
        zipcode = map['zipcode'].toString(),
        lat = _parseDouble(map['lat']),
        long = _parseDouble(map['long']),
        sqftLiving15 = _parseInt(map['sqft_living15']),
        sqftLot15 = _parseInt(map['sqft_lot15']);

  @override
  String getDisplayName() {
    return 'Дом $id в $zipcode - \$${price.toStringAsFixed(0)}';
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
      default: 
        debugPrint('Unknown field: $field');  // Лог для отладки
        return 0.0;  // Фикс: Fallback вместо null
    }
  }

  @override
  List<FieldDescriptor> get fieldDescriptors => [
    FieldDescriptor.numeric( 
      key: 'price', 
      label: 'Цена', 
      min: 75000, 
      max: 7700000,
    ),
    FieldDescriptor.numeric( 
      key: 'bedrooms', 
      label: 'Спальни', 
      min: 0, 
      max: 33,
    ),
    FieldDescriptor.numeric( 
      key: 'bathrooms', 
      label: 'Ванные', 
      min: 0.0, 
      max: 8.0,
    ),
    FieldDescriptor.numeric( 
      key: 'sqft_living', 
      label: 'Жилая площадь (кв.футы)', 
      min: 290, 
      max: 13540,
    ),
    FieldDescriptor.numeric( 
      key: 'sqft_lot', 
      label: 'Площадь участка (кв.футы)', 
      min: 520, 
      max: 1651359,
    ),
    FieldDescriptor.numeric( 
      key: 'floors', 
      label: 'Этажи', 
      min: 1.0, 
      max: 3.5,
    ),
    FieldDescriptor.numeric( 
      key: 'waterfront', 
      label: 'Вид на воду', 
      min: 0, 
      max: 1,
    ),
    FieldDescriptor.numeric( 
      key: 'view', 
      label: 'Вид', 
      min: 0, 
      max: 4,
    ),
    FieldDescriptor.numeric( 
      key: 'condition', 
      label: 'Состояние', 
      min: 1, 
      max: 5,
    ),
    FieldDescriptor.numeric( 
      key: 'grade', 
      label: 'Класс', 
      min: 1, 
      max: 13,
    ),
    FieldDescriptor.numeric( 
      key: 'sqft_above', 
      label: 'Площадь над землей (кв.футы)', 
      min: 290, 
      max: 9410,
    ),
    FieldDescriptor.numeric( 
      key: 'sqft_basement', 
      label: 'Площадь подвала (кв.футы)', 
      min: 0, 
      max: 4820,
    ),
    FieldDescriptor.numeric( 
      key: 'yr_built', 
      label: 'Год постройки', 
      min: 1900, 
      max: 2015,
    ),
    FieldDescriptor.numeric( 
      key: 'yr_renovated', 
      label: 'Год ремонта', 
      min: 0, 
      max: 2015,
    ),
    FieldDescriptor.numeric( 
      key: 'lat', 
      label: 'Широта', 
      min: 47.1559, 
      max: 47.7776,
    ),
    FieldDescriptor.numeric( 
      key: 'long', 
      label: 'Долгота', 
      min: -122.5190, 
      max: -121.3153,
    ),
    FieldDescriptor.numeric( 
      key: 'sqft_living15', 
      label: 'Жилая площадь соседей (кв.футы)', 
      min: 399, 
      max: 6210,
    ),
    FieldDescriptor.numeric( 
      key: 'sqft_lot15', 
      label: 'Площадь участка соседей (кв.футы)', 
      min: 651, 
      max: 871200,
    ),
  ];

  @override
  String? getCategoricalValue(String key) {
    throw UnimplementedError();
  }
}