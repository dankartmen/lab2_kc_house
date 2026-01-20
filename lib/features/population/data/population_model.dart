import 'package:lab2_kc_house/core/data/field_descriptor.dart';

import '../../../core/data/data_model.dart';

class PopulationData implements DataModel{
  final int? rank;
  final String? cca3;
  final String? country;
  final String? capital;
  final String? continent;
  final double? population2022;
  final double? population2020;
  final double? population2015;
  final double? population2010;
  final double? population2000;
  final double? population1990;
  final double? population1980;
  final double? population1970;
  final double? area;
  final double? density;
  final double? growthRate;
  final double? worldPopulationPercentage;

  PopulationData({
    this.rank,
    this.cca3,
    this.country,
    this.capital,
    this.continent,
    this.population2022,
    this.population2020,
    this.population2015,
    this.population2010,
    this.population2000,
    this.population1990,
    this.population1980,
    this.population1970,
    this.area,
    this.density,
    this.growthRate,
    this.worldPopulationPercentage
  });

  @override
  PopulationData.fromMap(Map<String, dynamic> map)
      : rank = map['rank'] != null ? int.tryParse(map['rank'].toString()) : null,
        cca3 = map['cca3'],
        country = map['country'],
        capital = map['capital'],
        continent = map['continent'],
        population2022 = map['population2022'] != null ? double.tryParse(map['population2022'].toString()) : null,
        population2020 = map['population2020'] != null ? double.tryParse(map['population2020'].toString()) : null,
        population2015 = map['population2015'] != null ? double.tryParse(map['population2015'].toString()) : null,
        population2010 = map['population2010'] != null ? double.tryParse(map['population2010'].toString()) : null,
        population2000 = map['population2000'] != null ? double.tryParse(map['population2000'].toString()) : null,
        population1990 = map['population1990'] != null ? double.tryParse(map['population1990'].toString()) : null,
        population1980 = map['population1980'] != null ? double.tryParse(map['population1980'].toString()) : null,
        population1970 = map['population1970'] != null ? double.tryParse(map['population1970'].toString()) : null,
        area = map['area'] != null ? double.tryParse(map['area'].toString()) : null,
        density = map['density'] != null ? double.tryParse(map['density'].toString()) : null,
        growthRate = map['growthRate'] != null ? double.tryParse(map['growthRate'].toString()) : null,
        worldPopulationPercentage = map['worldPopulationPercentage'] != null ? double.tryParse(map['worldPopulationPercentage'].toString()) : null;

  @override
  Map<String, dynamic> toJson() => {
    'rank': rank,
    'cca3': cca3,
    'country': country,
    'capital': capital,
    'continent': continent,
    'population2022': population2022,
    'population2020': population2020,
    'population2015': population2015,
    'population2010': population2010,
    'population2000': population2000,
    'population1990': population1990,
    'population1980': population1980,
    'population1970': population1970,
    'area': area,
    'density': density,
    'growthRate':growthRate, 
    'worldPopulationPercentage': worldPopulationPercentage
  };
  
  

  @override
  double? getNumericValue(String field) {
    switch (field) {
      case 'rank': return rank?.toDouble();
      case 'population2022': return population2022;
      case 'population2020': return population2020;
      case 'population2015': return population2015;
      case 'population2010': return population2010;
      case 'population2000': return population2000;
      case 'population1990': return population1990;
      case 'population1980': return population1980;
      case 'population1970': return population1970;
      case 'area': return area;
      case 'density': return density;
      case 'growthRate': return growthRate;
      case 'worldPopulationPercentage': return worldPopulationPercentage;

      default: return null;
    }
  }
  @override
  String getDisplayName() => country ?? 'Unknown';

  @override
  List<FieldDescriptor> get fieldDescriptors => [
    FieldDescriptor.numeric(
      key: 'rank',
      label: 'Ранг',
    ),
    FieldDescriptor.categorical(
      key: 'cca3',
      label: 'CCA3',
    ),
    FieldDescriptor.categorical(
      key: 'country',
      label: 'Страна',
    ),
    FieldDescriptor.categorical(
      key: 'capital',
      label: 'Столица',
    ),
    FieldDescriptor.categorical(
      key: 'continent',
      label: 'Континент',
    ),
    FieldDescriptor.numeric(
      key: 'population2022',
      label: 'Население 2022',
    ),
    FieldDescriptor.numeric(
      key: 'population2020',
      label: 'Население 2020',
    ),
    FieldDescriptor.numeric(
      key: 'population2015',
      label: 'Население 2015',
    ),
    FieldDescriptor.numeric(
      key: 'population2010',
      label: 'Население 2010',
    ),
    FieldDescriptor.numeric(
      key: 'population2000',
      label: 'Население 2000',
    ),
    FieldDescriptor.numeric(
      key: 'population1990',
      label: 'Население 1990',
    ),
    FieldDescriptor.numeric(
      key: 'population1980',
      label: 'Население 1980',
    ),
    FieldDescriptor.numeric(
      key: 'population1970',
      label: 'Население 1970',
    ),
    FieldDescriptor.numeric(
      key: 'area',
      label: 'Площадь',
    ),
    FieldDescriptor.numeric(
      key: 'density',
      label: 'Плотность',
    ),
    FieldDescriptor.numeric(
      key: 'growthRate',
      label: 'Темп роста',
    ),
    FieldDescriptor.numeric(
      key: 'worldPopulationPercentage',
      label: '% от мирового населения',
    ),
  ];

  @override
  String? getCategoricalValue(String key) {
    switch (key) {
      case 'cca3': return cca3;
      case 'country': return country;
      case 'capital': return capital;
      case 'continent': return continent;
      default: return null;
    }
  }
}
