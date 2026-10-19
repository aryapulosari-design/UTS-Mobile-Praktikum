import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/weather.dart';
import '../utils/weather_display.dart';

class DailyDetailScreen extends StatelessWidget {
  const DailyDetailScreen({
    super.key,
    required this.city,
    required this.day,
    required this.timezone,
  });
  final City city;
  final DailyForecast day;
  final String timezone;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail prakiraan')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              city.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('${dayLabel(day.date)}, ${dateLabel(day.date)}'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF173E38),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Icon(
                    weatherIcon(day.code),
                    size: 64,
                    color: const Color(0xFFD8EBA7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weatherLabel(day.code),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maks ${day.maximum.round()}°C / Min ${day.minimum.round()}°C',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _row(
              Icons.umbrella_outlined,
              'Peluang hujan maksimum',
              '${day.rainProbability}%',
            ),
            _row(
              Icons.water_drop_outlined,
              'Total curah hujan',
              '${day.precipitation.toStringAsFixed(1)} mm',
            ),
            _row(
              Icons.air,
              'Angin maksimum',
              '${day.maximumWind.toStringAsFixed(1)} km/jam',
            ),
            _row(
              Icons.wb_sunny_outlined,
              'Indeks UV maksimum',
              day.uvIndex.toStringAsFixed(1),
            ),
            _row(
              Icons.wb_twilight_rounded,
              'Matahari terbit',
              clockLabel(day.sunrise),
            ),
            _row(
              Icons.nights_stay_outlined,
              'Matahari terbenam',
              clockLabel(day.sunset),
            ),
            const SizedBox(height: 16),
            Text(
              'Waktu mengikuti zona $timezone. Seluruh angka adalah prakiraan harian dari Open-Meteo; kondisi dapat berubah.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64766A)),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _row(IconData icon, String label, String value) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF467561)),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
    ),
  );
}
