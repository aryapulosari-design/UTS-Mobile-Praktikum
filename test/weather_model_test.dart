import 'package:flutter_test/flutter_test.dart';
import 'package:langit_kita/models/city.dart';
import 'package:langit_kita/models/weather.dart';
import 'package:langit_kita/utils/weather_display.dart';

import 'fixtures/weather_fixture.dart';

void main() {
  test('Prakiraan per jam dan detail harian mempertahankan data API', () {
    final weather = Weather.fromJson(weatherFixture());
    expect(weather.hourly, hasLength(24));
    expect(weather.hourly.first.time.hour, 9);
    expect(weather.hourly.last.time.day, 20);
    expect(weather.hourly[10].isDay, isFalse);
    expect(weather.daily.first.uvIndex, 9.5);
    expect(weather.daily.first.precipitation, 2.4);
    expect(clockLabel(weather.daily.first.sunrise), '05:05');
  });

  test(
    'Array per jam rusak tidak ditampilkan sebagai prakiraan yang salah',
    () {
      final json = weatherFixture();
      (json['hourly'] as Map)['weather_code'] = [3];
      expect(() => Weather.fromJson(json), throwsFormatException);
    },
  );

  test('JSON diparsing menjadi cuaca dan tujuh prakiraan berurutan', () {
    final weather = Weather.fromJson(weatherFixture());
    expect(weather.temperature, 31.5);
    expect(weather.humidity, 59);
    expect(weather.daily, hasLength(7));
    expect(weather.daily.first.rainProbability, 59);
    expect(weather.daily.last.date.day, 25);
    expect(weather.time.hour, 9);
    expect(weather.timezone, 'Asia/Jakarta');
  });

  test('Nilai angka integer juga diterima tanpa cast double yang gagal', () {
    final json = weatherFixture();
    (json['current'] as Map)['temperature_2m'] = 30;
    expect(Weather.fromJson(json).temperature, 30.0);
  });

  test(
    'Data kosong, null, tanggal rusak dan panjang array berbeda ditolak',
    () {
      expect(() => Weather.fromJson({}), throwsFormatException);
      final missing = weatherFixture();
      (missing['current'] as Map)['temperature_2m'] = null;
      expect(() => Weather.fromJson(missing), throwsFormatException);
      final mismatch = weatherFixture();
      (mismatch['daily'] as Map)['weather_code'] = [3];
      expect(() => Weather.fromJson(mismatch), throwsFormatException);
      final empty = weatherFixture();
      (empty['daily'] as Map)['time'] = [];
      expect(() => Weather.fromJson(empty), throwsFormatException);
      final invalidDate = weatherFixture();
      (invalidDate['current'] as Map)['time'] = 'bukan-tanggal';
      expect(() => Weather.fromJson(invalidDate), throwsFormatException);
    },
  );

  test('Lokasi memvalidasi koordinat dan memberi region cadangan', () {
    final city = City.fromJson({
      'name': 'Malang',
      'latitude': -7.98,
      'longitude': 112.63,
    });
    expect(city.region, 'Indonesia');
    expect(
      () => City.fromJson({'name': 'X', 'latitude': 100, 'longitude': 0}),
      throwsFormatException,
    );
  });

  test('Kode WMO dan format tanggal diterjemahkan ke bahasa Indonesia', () {
    expect(weatherLabel(95), 'Hujan petir');
    expect(weatherLabel(999), 'Kondisi belum dikenali');
    expect(dayLabel(DateTime(2026, 10, 19)), 'Senin');
    expect(clockLabel(DateTime(2026, 10, 19, 9, 5)), '09:05');
  });
}
