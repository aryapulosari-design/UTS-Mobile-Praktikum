import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:langit_kita/models/city.dart';
import 'package:langit_kita/services/favorites_store.dart';

import 'fakes/memory_preferences.dart';

void main() {
  test('Favorit terbaca kembali dari instance penyimpanan baru', () async {
    final prefs = MemoryPreferences();
    await FavoritesStore(preferences: prefs).save([City.presets[4]]);
    final restored = await FavoritesStore(preferences: prefs).load();
    expect(restored.single.name, 'Malang');
    expect(restored.single.region, 'Jawa Timur');
    expect(restored.single.id, City.presets[4].id);
  });

  test('Entri rusak diabaikan dan lokasi duplikat digabungkan', () async {
    final prefs = MemoryPreferences();
    prefs.values[FavoritesStore.key] = [
      'rusak',
      'null',
      jsonEncode(City.presets.first.toJson()),
      jsonEncode(City.presets.first.toJson()),
    ];
    expect(await FavoritesStore(preferences: prefs).load(), hasLength(1));
  });

  test('Simpan daftar kosong benar-benar menghapus semua favorit', () async {
    final prefs = MemoryPreferences();
    final store = FavoritesStore(preferences: prefs);
    await store.save([City.presets.first, City.presets.first]);
    expect(await store.load(), hasLength(1));
    await store.save([]);
    expect(await FavoritesStore(preferences: prefs).load(), isEmpty);
  });

  test('Kegagalan penyimpanan diteruskan tanpa mengganti data lama', () async {
    final prefs = MemoryPreferences();
    final store = FavoritesStore(preferences: prefs);
    await store.save([City.presets.first]);
    prefs.failWrites = true;
    await expectLater(store.save([]), throwsStateError);
    expect(await store.load(), hasLength(1));
  });
}
