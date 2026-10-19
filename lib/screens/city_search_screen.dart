import 'package:flutter/material.dart';

import '../models/city.dart';
import '../services/weather_service.dart';
import '../widgets/status_panel.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key, required this.service});
  final WeatherService service;

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<List<City>>? _results;
  String _query = '';

  void _search() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _query = _controller.text.trim();
      _results = widget.service.searchCities(_query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cari kota')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Langit di kotamu',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Temukan cuaca kota dan wilayah di Indonesia.'),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Nama kota',
                  hintText: 'Contoh: Malang',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                validator: (value) => (value?.trim().length ?? 0) < 3
                    ? 'Masukkan minimal 3 karakter.'
                    : null,
                onFieldSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Cari lokasi'),
            ),
            const SizedBox(height: 24),
            if (_results == null)
              const StatusPanel(
                icon: Icons.travel_explore_rounded,
                title: 'Mulai dari sebuah kota',
                message: 'Ketik nama kota, lalu tekan Cari lokasi.',
              )
            else
              FutureBuilder<List<City>>(
                future: _results,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const StatusPanel(
                      icon: Icons.search,
                      loading: true,
                      title: 'Mencari lokasi...',
                      message: 'Sebentar, kami carikan kotamu.',
                    );
                  }
                  if (snapshot.hasError) {
                    return StatusPanel(
                      icon: Icons.wifi_off_rounded,
                      title: 'Lokasi belum dapat dimuat',
                      message: snapshot.error is WeatherException
                          ? snapshot.error.toString()
                          : 'Terjadi kesalahan. Silakan coba lagi.',
                      onRetry: _search,
                    );
                  }
                  final cities = snapshot.data ?? [];
                  if (cities.isEmpty) {
                    return StatusPanel(
                      icon: Icons.location_off_outlined,
                      title: 'Lokasi tidak ditemukan',
                      message:
                          'Tidak ada hasil untuk "$_query". Coba nama kota lain.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cities.length} lokasi ditemukan',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      for (final city in cities)
                        Card(
                          color: Colors.white,
                          elevation: 0,
                          child: ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(city.name),
                            subtitle: Text(city.region),
                            trailing: const Icon(Icons.arrow_forward_rounded),
                            onTap: () => Navigator.of(context).pop(city),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    ),
  );
}
