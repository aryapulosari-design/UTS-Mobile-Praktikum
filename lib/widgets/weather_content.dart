import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/weather.dart';
import '../utils/weather_display.dart';
import '../screens/daily_detail_screen.dart';
import 'hourly_forecast_strip.dart';

class WeatherContent extends StatelessWidget {
  const WeatherContent({super.key, required this.city, required this.weather});

  final City city;
  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final today = weather.daily.first;
    final ink = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF204F45), Color(0xFF123A35)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUACA SAAT INI',
                  style: TextStyle(
                    color: Color(0xFFC7DCCD),
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFD5E9A8),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${city.region}, Indonesia',
                            style: const TextStyle(color: Color(0xFFC7DCCD)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${weather.temperature.round()}°',
                          style: const TextStyle(
                            fontSize: 88,
                            height: 1,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      label: weatherLabel(weather.code),
                      child: Icon(
                        weatherIcon(weather.code, isDay: weather.isDay),
                        size: 86,
                        color: const Color(0xFFD8EBA7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  weatherLabel(weather.code),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Maks ${today.maximum.round()}° / Min ${today.minimum.round()}°  ·  Celsius',
                  style: const TextStyle(color: Color(0xFFC7DCCD)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFF4C6F62), height: 1),
                ),
                Text(
                  '${dayLabel(weather.time)}, ${dateLabel(weather.time)}',
                  style: const TextStyle(color: Color(0xFFE0E8DE)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Waktu data ${clockLabel(weather.time)} · ${weather.timezone}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC7DCCD),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _heading(
          'Prakiraan per jam',
          '24 jam mulai jam ini · ${weather.timezone}',
        ),
        const SizedBox(height: 14),
        HourlyForecastStrip(hours: weather.hourly),
        const SizedBox(height: 24),
        _heading('Lebih dekat dengan cuaca', 'Detail untuk rencana harimu.'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 560 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metric(
                  width,
                  Icons.thermostat_rounded,
                  'Terasa seperti',
                  '${weather.feelsLike.round()}°C',
                ),
                _metric(
                  width,
                  Icons.water_drop_outlined,
                  'Kelembapan',
                  '${weather.humidity}%',
                ),
                _metric(
                  width,
                  Icons.air_rounded,
                  'Angin',
                  '${weather.windSpeed.toStringAsFixed(1)} km/jam',
                ),
                _metric(
                  width,
                  Icons.umbrella_outlined,
                  'Peluang hujan',
                  '${today.rainProbability}%',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Peluang hujan adalah probabilitas maksimum harian.',
          style: TextStyle(fontSize: 12, color: ink.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEDDA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siapkan harimu',
                      style: TextStyle(color: ink, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      today.rainProbability >= 50
                          ? 'Ada peluang hujan hari ini. Bawa payung saat beraktivitas di luar.'
                          : 'Peluang hujan relatif rendah. Tetap cek prakiraan sebelum bepergian.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        _heading(
          'Prakiraan 7 hari',
          'Ketuk salah satu hari untuk melihat detailnya.',
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE1E7DE)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < weather.daily.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 18, endIndent: 18),
                _forecast(context, weather.daily[i], i),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Data cuaca: Open-Meteo · Lokasi: GeoNames\nCC BY 4.0 · Prakiraan dapat berubah.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF64766A)),
          ),
        ),
      ],
    );
  }

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF173E38),
        ),
      ),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: Color(0xFF64766A))),
    ],
  );

  Widget _metric(double width, IconData icon, String label, String value) =>
      Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E7DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF467561), size: 23),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64766A)),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF173E38),
              ),
            ),
          ],
        ),
      );

  Widget _forecast(
    BuildContext context,
    DailyForecast day,
    int index,
  ) => Semantics(
    button: true,
    label:
        'Lihat detail prakiraan ${dayLabel(day.date)} ${dateLabel(day.date)}',
    child: InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DailyDetailScreen(
            city: city,
            day: day,
            timezone: weather.timezone,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index == 0 ? 'Hari ini' : dayLabel(day.date),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.date.day}/${day.date.month} · ${weatherLabel(day.code)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64766A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Icon(
                  weatherIcon(day.code),
                  color: Theme.of(context).colorScheme.primary,
                  size: 23,
                ),
                const SizedBox(height: 4),
                Text(
                  '${day.rainProbability}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64766A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              '${day.maximum.round()}° / ${day.minimum.round()}°',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}
