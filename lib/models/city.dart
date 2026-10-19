class City {
  const City({
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String region;
  final double latitude;
  final double longitude;

  String get id => '$latitude,$longitude';

  Map<String, dynamic> toJson() => {
    'name': name,
    'admin1': region,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory City.fromJson(Map<String, dynamic> json) {
    if (json['name'] is! String ||
        (json['name'] as String).trim().isEmpty ||
        json['latitude'] is! num ||
        json['longitude'] is! num) {
      throw const FormatException('Data lokasi tidak lengkap.');
    }
    final latitude = (json['latitude'] as num).toDouble();
    final longitude = (json['longitude'] as num).toDouble();
    if (!latitude.isFinite ||
        latitude.abs() > 90 ||
        !longitude.isFinite ||
        longitude.abs() > 180) {
      throw const FormatException('Koordinat lokasi tidak valid.');
    }
    return City(
      name: json['name'] as String,
      region: json['admin1'] as String? ?? 'Indonesia',
      latitude: latitude,
      longitude: longitude,
    );
  }

  static const presets = [
    City(
      name: 'Jakarta',
      region: 'DKI Jakarta',
      latitude: -6.2,
      longitude: 106.8167,
    ),
    City(
      name: 'Bandung',
      region: 'Jawa Barat',
      latitude: -6.9222,
      longitude: 107.6069,
    ),
    City(
      name: 'Yogyakarta',
      region: 'DI Yogyakarta',
      latitude: -7.7956,
      longitude: 110.3695,
    ),
    City(
      name: 'Surabaya',
      region: 'Jawa Timur',
      latitude: -7.2575,
      longitude: 112.7521,
    ),
    City(
      name: 'Malang',
      region: 'Jawa Timur',
      latitude: -7.9797,
      longitude: 112.6304,
    ),
    City(
      name: 'Kediri',
      region: 'Jawa Timur',
      latitude: -7.81667,
      longitude: 112.01667,
    ),
    City(
      name: 'Denpasar',
      region: 'Bali',
      latitude: -8.65,
      longitude: 115.2167,
    ),
    City(
      name: 'Makassar',
      region: 'Sulawesi Selatan',
      latitude: -5.1486,
      longitude: 119.4324,
    ),
  ];
}
