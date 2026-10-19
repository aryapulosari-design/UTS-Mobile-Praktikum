import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langit_kita/app.dart';
import 'package:langit_kita/services/weather_service.dart';
import 'package:langit_kita/services/favorites_store.dart';
import 'package:langit_kita/widgets/weather_content.dart';
import 'package:langit_kita/widgets/hourly_forecast_strip.dart';

import 'fixtures/weather_fixture.dart';
import 'fakes/memory_preferences.dart';

Widget testApp(WeatherService service, {FavoritesStore? store, Key? key}) =>
    LangitKitaApp(
      key: key,
      service: service,
      favoritesStore: store ?? FavoritesStore(preferences: MemoryPreferences()),
    );

void main() {
  WeatherService createService() => WeatherService(
    client: MockClient(
      (_) async => http.Response(jsonEncode(weatherFixture()), 200),
    ),
  );

  testWidgets(
    'Detail harian menampilkan tanggal, matahari dan angka dari API',
    (tester) async {
      final service = createService();
      addTearDown(service.close);
      await tester.pumpWidget(testApp(service));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Hari ini').hitTestable(),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hari ini').hitTestable());
      await tester.pumpAndSettle();
      expect(find.text('Detail prakiraan'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Matahari terbenam').hitTestable(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('05:05'), findsOneWidget);
      expect(find.text('17:23'), findsOneWidget);
      expect(find.text('9.5'), findsOneWidget);
      expect(find.text('2.4 mm'), findsOneWidget);
    },
  );

  testWidgets('Favorit pulih setelah halaman dibuat ulang dan bisa dihapus', (
    tester,
  ) async {
    final service = createService();
    final prefs = MemoryPreferences();
    final store = FavoritesStore(preferences: prefs);
    addTearDown(service.close);
    await tester.pumpWidget(
      testApp(service, store: store, key: const ValueKey('awal')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan kota ke favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Kota favorit'), findsOneWidget);
    await tester.pumpWidget(
      testApp(
        service,
        store: FavoritesStore(preferences: prefs),
        key: const ValueKey('ulang'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kota favorit'), findsOneWidget);
    await tester.tap(find.text('Hapus dari favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Kota favorit'), findsNothing);
    expect(await store.load(), isEmpty);
  });

  testWidgets(
    'Simpan favorit gagal memberi pesan dan tidak menambah favorit semu',
    (tester) async {
      final service = createService();
      final prefs = MemoryPreferences()..failWrites = true;
      addTearDown(service.close);
      await tester.pumpWidget(
        testApp(service, store: FavoritesStore(preferences: prefs)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan kota ke favorit'));
      await tester.pumpAndSettle();
      expect(
        find.text('Favorit belum tersimpan. Silakan coba lagi.'),
        findsOneWidget,
      );
      expect(find.text('Kota favorit'), findsNothing);
    },
  );

  testWidgets('Prakiraan per jam dapat digeser hingga hari berikutnya', (
    tester,
  ) async {
    final service = createService();
    addTearDown(service.close);
    await tester.pumpWidget(testApp(service));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(HourlyForecastStrip).hitTestable(),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(HourlyForecastStrip), const Offset(-1800, 0));
    await tester.pumpAndSettle();
    expect(find.text('Hujan 60%'), findsWidgets);
    expect(find.text('20/10'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FutureBuilder menampilkan loading kemudian data sukses', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final service = WeatherService(client: MockClient((_) => pending.future));
    addTearDown(service.close);
    await tester.pumpWidget(testApp(service));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Memuat cuaca Jakarta...'), findsOneWidget);
    pending.complete(http.Response(jsonEncode(weatherFixture()), 200));
    await tester.pumpAndSettle();
    expect(find.text('32°').first, findsOneWidget);
    expect(find.text('CUACA SAAT INI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Error dapat dicoba ulang dan berhasil mengambil data baru', (
    tester,
  ) async {
    var requests = 0;
    final service = WeatherService(
      client: MockClient((_) async {
        requests++;
        return requests == 1
            ? http.Response('{}', 500)
            : http.Response(jsonEncode(weatherFixture()), 200);
      }),
    );
    addTearDown(service.close);
    await tester.pumpWidget(testApp(service));
    await tester.pumpAndSettle();
    expect(find.text('Cuaca belum dapat dimuat'), findsOneWidget);
    await tester.ensureVisible(find.text('Coba lagi'));
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('CUACA SAAT INI'), findsOneWidget);
    expect(requests, 2);
  });

  testWidgets(
    'Ganti kota mengambil koordinat baru tanpa request akibat rebuild',
    (tester) async {
      final latitudes = <String?>[];
      final service = WeatherService(
        client: MockClient((request) async {
          latitudes.add(request.url.queryParameters['latitude']);
          return http.Response(jsonEncode(weatherFixture()), 200);
        }),
      );
      addTearDown(service.close);
      await tester.pumpWidget(testApp(service));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bandung').first);
      await tester.pumpAndSettle();
      expect(latitudes, ['-6.2', '-6.9222']);
      await tester.pump();
      expect(latitudes, hasLength(2));
      expect(find.text('Jawa Barat, Indonesia'), findsOneWidget);
    },
  );

  testWidgets('Pencarian memvalidasi input dan menangani hasil kosong', (
    tester,
  ) async {
    final service = WeatherService(
      client: MockClient(
        (request) async => http.Response(
          jsonEncode(
            request.url.host.startsWith('geocoding') ? {} : weatherFixture(),
          ),
          200,
        ),
      ),
    );
    addTearDown(service.close);
    await tester.pumpWidget(testApp(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cari kota di Indonesia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cari lokasi'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan minimal 3 karakter.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'zzzzzz');
    await tester.tap(find.text('Cari lokasi'));
    await tester.pumpAndSettle();
    expect(find.text('Lokasi tidak ditemukan'), findsOneWidget);
  });

  testWidgets('Memilih hasil pencarian menampilkan cuaca kota yang dipilih', (
    tester,
  ) async {
    final service = WeatherService(
      client: MockClient(
        (request) async => http.Response(
          jsonEncode(
            request.url.host.startsWith('geocoding')
                ? {
                    'results': [
                      {
                        'name': 'Malang',
                        'admin1': 'Jawa Timur',
                        'latitude': -7.98,
                        'longitude': 112.63,
                      },
                    ],
                  }
                : weatherFixture(),
          ),
          200,
        ),
      ),
    );
    addTearDown(service.close);
    await tester.pumpWidget(testApp(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cari kota di Indonesia'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Malang');
    await tester.tap(find.text('Cari lokasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Malang'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(WeatherContent),
        matching: find.text('Malang'),
      ),
      findsOneWidget,
    );
    expect(find.text('Jawa Timur, Indonesia'), findsOneWidget);
  });

  testWidgets('Layar kecil tetap dapat digulir tanpa overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = WeatherService(
      client: MockClient(
        (_) async => http.Response(jsonEncode(weatherFixture()), 200),
      ),
    );
    addTearDown(service.close);
    await tester.pumpWidget(testApp(service));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Prakiraan 7 hari'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Minggu'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Minggu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
