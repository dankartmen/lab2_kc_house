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

  factory PopulationData.fromCsv(List<dynamic> row) {
    return PopulationData(
      rank: int.tryParse(row[0].toString()),
      cca3: row[1].toString(),
      country: row[2].toString(), 
      capital: row[3].toString(),
      continent: row[4].toString(), 
      population2022: double.tryParse(row[5].toString()), 
      population2020: double.tryParse(row[6].toString()), 
      population2015: double.tryParse(row[7].toString()),
      population2010: double.tryParse(row[8].toString()), 
      population2000: double.tryParse(row[9].toString()),
      population1990: double.tryParse(row[10].toString()),
      population1980: double.tryParse(row[11].toString()),
      population1970: double.tryParse(row[12].toString()), 
      area: double.tryParse(row[13].toString()), 
      density: double.tryParse(row[14].toString()),
      growthRate: double.tryParse(row[15].toString()), 
      worldPopulationPercentage: double.tryParse(row[16].toString())
    );
  }

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
  List<String> getNumericFields() => [
    'rank', 'population2022', 'population2020', 'population2015', 'population2010',
    'population2000', 'population1990', 'population1980', 'population1970', 'area',
    'density', 'growthRate', 'worldPopulationPercentage'
  ];

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
}
