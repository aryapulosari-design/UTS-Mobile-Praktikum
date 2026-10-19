import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';

/// Hanya menyimpan pilihan kota; data cuaca tetap diminta dari API.
class FavoritesStore {
  FavoritesStore({this.preferences});
  final SharedPreferencesAsync? preferences;
  SharedPreferencesAsync? _defaultPreferences;
  SharedPreferencesAsync get _prefs =>
      preferences ?? (_defaultPreferences ??= SharedPreferencesAsync());
  static const key = 'langit_kita.favorite_cities.v1';

  Future<List<City>> load() async {
    final values = await _prefs.getStringList(key) ?? [];
    final cities = <String, City>{};
    for (final value in values) {
      try {
        final city = City.fromJson(jsonDecode(value) as Map<String, dynamic>);
        cities[city.id] = city;
      } on FormatException {
        // Satu entri rusak tidak menghapus favorit lain yang masih valid.
      } on TypeError {
        // Format penyimpanan lama/rusak diabaikan per entri.
      }
    }
    return cities.values.toList();
  }

  Future<void> save(List<City> cities) => _prefs.setStringList(
    key,
    {for (final city in cities) city.id: city}.values
        .map((city) => jsonEncode(city.toJson()))
        .toList(),
  );
}
