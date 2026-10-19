import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../utils/weather_display.dart';

class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({super.key, required this.hours});
  final List<HourlyForecast> hours;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final hour in hours)
          Container(
            width: 102,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE1E7DE)),
            ),
            child: Column(
              children: [
                Text(
                  clockLabel(hour.time),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${hour.time.day}/${hour.time.month}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64766A),
                  ),
                ),
                const SizedBox(height: 14),
                Icon(
                  weatherIcon(hour.code, isDay: hour.isDay),
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                  semanticLabel: weatherLabel(hour.code),
                ),
                const SizedBox(height: 12),
                Text(
                  '${hour.temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hujan ${hour.rainProbability}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64766A),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
