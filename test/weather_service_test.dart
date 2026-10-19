import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langit_kita/models/city.dart';
import 'package:langit_kita/services/weather_service.dart';

import 'fixtures/weather_fixture.dart';

void main() {
  final city = City.presets.first;

  test('GET cuaca mengirim koordinat, unit, timezone dan tujuh hari', () async {
    final service = WeatherService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.queryParameters['latitude'], '-6.2');
        expect(request.url.queryParameters['forecast_days'], '7');
        expect(request.url.queryParameters['forecast_hours'], '24');
        expect(
          request.url.queryParameters['hourly'],
          contains('precipitation_probability'),
        );
        expect(request.url.queryParameters['daily'], contains('sunrise'));
        expect(request.url.queryParameters['timezone'], 'auto');
        expect(request.url.queryParameters['wind_speed_unit'], 'kmh');
        return http.Response(jsonEncode(weatherFixture()), 200);
      }),
    );
    addTearDown(service.close);
    expect((await service.fetchWeather(city)).daily, hasLength(7));
  });

  for (final status in [429, 500]) {
    test('HTTP $status menghasilkan pesan error yang jelas', () async {
      final service = WeatherService(
        client: MockClient((_) async => http.Response('{}', status)),
      );
      addTearDown(service.close);
      await expectLater(
        service.fetchWeather(city),
        throwsA(isA<WeatherException>()),
      );
    });
  }

  for (final body in [
    'bukan json',
    '[]',
    '{}',
    '{"error":true}',
    '{"current":null}',
  ]) {
    test('Respons tidak valid ditangani: $body', () async {
      final service = WeatherService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(service.close);
      await expectLater(
        service.fetchWeather(city),
        throwsA(isA<WeatherException>()),
      );
    });
  }

  test('Gangguan koneksi ditangani', () async {
    final service = WeatherService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(service.close);
    await expectLater(
      service.fetchWeather(city),
      throwsA(isA<WeatherException>()),
    );
  });

  test('Request yang tidak selesai dibatasi timeout', () async {
    final pending = Completer<http.Response>();
    final service = WeatherService(
      client: MockClient((_) => pending.future),
      timeout: const Duration(milliseconds: 10),
    );
    addTearDown(service.close);
    await expectLater(
      service.fetchWeather(city),
      throwsA(isA<WeatherException>()),
    );
    pending.complete(http.Response('{}', 200));
  });

  test('Pencarian menggunakan filter Indonesia dan parsing region', () async {
    final service = WeatherService(
      client: MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.queryParameters['countryCode'], 'ID');
        expect(request.url.queryParameters['name'], 'Bandung');
        return http.Response(
          jsonEncode({
            'results': [
              {
                'name': 'Kota Bandung',
                'latitude': -6.92,
                'longitude': 107.6,
                'admin1': 'Jawa Barat',
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(service.close);
    expect(
      (await service.searchCities(' Bandung ')).single.region,
      'Jawa Barat',
    );
  });

  test('Hasil pencarian kosong dan query pendek ditangani', () async {
    var requests = 0;
    final service = WeatherService(
      client: MockClient((_) async {
        requests++;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(service.close);
    expect(await service.searchCities('ab'), isEmpty);
    expect(requests, 0);
    expect(await service.searchCities('zzzzzz'), isEmpty);
    expect(requests, 1);
  });

  test('Format hasil lokasi rusak ditangani', () async {
    final service = WeatherService(
      client: MockClient((_) async => http.Response('{"results":[null]}', 200)),
    );
    addTearDown(service.close);
    await expectLater(
      service.searchCities('Bandung'),
      throwsA(isA<WeatherException>()),
    );
  });
}
