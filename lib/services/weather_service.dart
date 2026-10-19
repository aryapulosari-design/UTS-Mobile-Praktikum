import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city.dart';
import '../models/weather.dart';

class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<Weather> fetchWeather(City city) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'is_day,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,sunrise,sunset,uv_index_max,'
          'precipitation_sum,wind_speed_10m_max',
      'hourly': 'temperature_2m,precipitation_probability,weather_code,is_day',
      'forecast_hours': '24',
      'timezone': 'auto',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'forecast_days': '7',
    });
    try {
      return Weather.fromJson(await _getJson(uri));
    } on FormatException {
      throw const WeatherException(
        'Data cuaca tidak lengkap. Silakan coba lagi.',
      );
    } on TypeError {
      throw const WeatherException(
        'Format data cuaca berubah. Silakan coba lagi.',
      );
    }
  }

  Future<List<City>> searchCities(String query) async {
    if (query.trim().length < 3) return [];
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query.trim(),
      'count': '10',
      'language': 'id',
      'format': 'json',
      'countryCode': 'ID',
    });
    try {
      final json = await _getJson(uri);
      final results = json['results'];
      // Open-Meteo tidak mengirim "results" jika lokasi tidak ditemukan.
      if (results == null) return [];
      if (results is! List) throw const FormatException();
      return results
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const WeatherException(
        'Data lokasi tidak dapat dibaca. Coba lagi.',
      );
    } on TypeError {
      throw const WeatherException('Format data lokasi berubah. Coba lagi.');
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw WeatherException(
          response.statusCode == 429
              ? 'Batas permintaan tercapai. Tunggu sebentar lalu coba lagi.'
              : 'Layanan belum tersedia (HTTP ${response.statusCode}). Coba lagi.',
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['error'] == true) {
        throw const FormatException('Respons API tidak valid.');
      }
      return decoded;
    } on TimeoutException {
      throw const WeatherException(
        'Koneksi terlalu lama. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    }
  }

  void close() => _client.close();
}
