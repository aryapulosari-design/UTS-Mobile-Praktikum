import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../services/favorites_store.dart';
import '../widgets/status_panel.dart';
import '../widgets/weather_content.dart';
import 'city_search_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key, this.service, this.favoritesStore});
  final WeatherService? service;
  final FavoritesStore? favoritesStore;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final WeatherService _service;
  late Future<Weather> _weather;
  City _city = City.presets.first;
  late final FavoritesStore _favoritesStore;
  List<City> _favorites = [];
  bool _favoritesReady = false;
  bool _favoritesError = false;
  bool _savingFavorite = false;
  bool get _isFavorite => _favorites.any((city) => city.id == _city.id);

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WeatherService();
    // Future disimpan di state agar rebuild tidak mengirim request berulang.
    _weather = _service.fetchWeather(_city);
    _favoritesStore = widget.favoritesStore ?? FavoritesStore();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final cities = await _favoritesStore.load();
      if (mounted) {
        setState(() {
          _favorites = cities;
          _favoritesReady = true;
          _favoritesError = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _favoritesError = true);
    }
  }

  Future<void> _toggleFavorite() async {
    if (!_favoritesReady || _savingFavorite) return;
    final city = _city;
    final removing = _isFavorite;
    final next = removing
        ? _favorites.where((item) => item.id != city.id).toList()
        : [..._favorites, city];
    setState(() => _savingFavorite = true);
    try {
      await _favoritesStore.save(next);
      if (mounted) {
        setState(() => _favorites = next);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${city.name} ${removing ? 'dihapus dari' : 'ditambahkan ke'} favorit.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorit belum tersimpan. Silakan coba lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingFavorite = false);
    }
  }

  Future<void> _reload([City? city]) async {
    setState(() {
      if (city != null) _city = city;
      _weather = _service.fetchWeather(_city);
    });
    try {
      await _weather;
    } catch (_) {
      // Pesan error ditampilkan FutureBuilder; RefreshIndicator tetap selesai.
    }
  }

  Future<void> _search() async {
    final city = await Navigator.of(context).push<City>(
      MaterialPageRoute(builder: (_) => CitySearchScreen(service: _service)),
    );
    if (mounted && city != null) await _reload(city);
  }

  @override
  void dispose() {
    if (widget.service == null) _service.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_cloudy_outlined, size: 26),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'LangitKita',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _reload(),
          tooltip: 'Perbarui cuaca',
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'LangitKita',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.wb_cloudy_rounded, size: 36),
            children: const [
              Text(
                'Aplikasi cuaca Indonesia untuk UTS Praktikum Mobile Programming G.\n\n'
                'Data cuaca: Open-Meteo (open-meteo.com). Data lokasi: GeoNames melalui Open-Meteo. '
                'Lisensi data CC BY 4.0 (creativecommons.org/licenses/by/4.0/).\n\n'
                'Cuaca saat ini merupakan estimasi model. Prakiraan dapat berubah.',
              ),
            ],
          ),
          tooltip: 'Tentang aplikasi',
          icon: const Icon(Icons.info_outline_rounded),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _reload,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              const Text(
                'Kenali langit,\nrencanakan harimu.',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF173E38),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cuaca di sekitarmu, dalam satu pandangan.',
                style: TextStyle(color: Color(0xFF64766A)),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _search,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  side: const BorderSide(color: Color(0xFFDAE2D8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Cari kota di Indonesia'),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final city in City.presets)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(city.name),
                          showCheckmark: false,
                          selected:
                              _city.name == city.name &&
                              _city.latitude == city.latitude,
                          onSelected: (_) => _reload(city),
                        ),
                      ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _favoritesReady && !_savingFavorite
                      ? _toggleFavorite
                      : null,
                  icon: Icon(
                    _isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
                  label: Text(
                    _isFavorite
                        ? 'Hapus dari favorit'
                        : 'Simpan kota ke favorit',
                  ),
                ),
              ),
              if (_favoritesError)
                TextButton.icon(
                  onPressed: _loadFavorites,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat ulang kota favorit'),
                ),
              if (_favorites.isNotEmpty) ...[
                const Text(
                  'Kota favorit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final city in _favorites)
                      InputChip(
                        avatar: const Icon(Icons.star_rounded, size: 16),
                        label: Text(city.name),
                        selected: city.id == _city.id,
                        onPressed: () => _reload(city),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              FutureBuilder<Weather>(
                future: _weather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return StatusPanel(
                      icon: Icons.cloud_sync_outlined,
                      loading: true,
                      title: 'Memuat cuaca ${_city.name}...',
                      message: 'Menyiapkan prakiraan terbaru untukmu.',
                    );
                  }
                  if (snapshot.hasError) {
                    return StatusPanel(
                      icon: Icons.cloud_off_outlined,
                      title: 'Cuaca belum dapat dimuat',
                      message: snapshot.error is WeatherException
                          ? snapshot.error.toString()
                          : 'Terjadi kesalahan. Silakan coba lagi.',
                      onRetry: () => _reload(),
                    );
                  }
                  final data = snapshot.data;
                  if (data == null || data.daily.isEmpty) {
                    return StatusPanel(
                      icon: Icons.cloud_queue_rounded,
                      title: 'Data cuaca belum tersedia',
                      message:
                          'Coba kota lain atau muat ulang beberapa saat lagi.',
                      onRetry: () => _reload(),
                    );
                  }
                  return WeatherContent(city: _city, weather: data);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
