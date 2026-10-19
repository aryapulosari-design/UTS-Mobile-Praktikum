import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan pengganti plugin; tidak menyentuh preferensi pengguna.
class MemoryPreferences implements SharedPreferencesAsync {
  final values = <String, List<String>>{};
  final _failures = <String, bool>{};
  bool get failWrites => _failures['write'] ?? false;
  set failWrites(bool value) => _failures['write'] = value;

  @override
  Future<List<String>?> getStringList(String key) async =>
      values[key]?.toList();

  @override
  Future<void> setStringList(String key, List<String> value) async {
    if (failWrites) throw StateError('Penyimpanan penuh');
    values[key] = value.toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
