/// Respons contoh untuk pengujian deterministik; bukan data cuaca aplikasi.
Map<String, dynamic> weatherFixture({double temperature = 31.5}) => {
  'timezone': 'Asia/Jakarta',
  'current': <String, dynamic>{
    'time': '2026-10-19T09:15',
    'temperature_2m': temperature,
    'relative_humidity_2m': 59,
    'apparent_temperature': 37.5,
    'is_day': 1,
    'weather_code': 3,
    'wind_speed_10m': 0.9,
  },
  'daily': <String, dynamic>{
    'sunrise': List.generate(7, (i) => '2026-10-${19 + i}T05:05'),
    'sunset': List.generate(7, (i) => '2026-10-${19 + i}T17:23'),
    'uv_index_max': List.filled(7, 9.5),
    'precipitation_sum': List.filled(7, 2.4),
    'wind_speed_10m_max': List.filled(7, 12.9),
    'time': [
      '2026-10-19',
      '2026-10-20',
      '2026-10-21',
      '2026-10-22',
      '2026-10-23',
      '2026-10-24',
      '2026-10-25',
    ],
    'weather_code': [53, 51, 81, 95, 53, 80, 53],
    'temperature_2m_max': [35.3, 34.9, 34.7, 34.2, 33.2, 32.7, 31.6],
    'temperature_2m_min': [25.9, 26.5, 26.4, 25.7, 25.3, 24.4, 24.9],
    'precipitation_probability_max': [59, 61, 90, 95, 100, 100, 94],
  },
  'hourly': <String, dynamic>{
    'time': List.generate(
      24,
      (i) => DateTime(2026, 10, 19, 9 + i).toIso8601String(),
    ),
    'temperature_2m': List.generate(24, (i) => 28 + i % 6),
    'precipitation_probability': List.filled(24, 60),
    'weather_code': List.filled(24, 3),
    'is_day': List.generate(
      24,
      (i) => (9 + i) % 24 >= 6 && (9 + i) % 24 < 18 ? 1 : 0,
    ),
  },
};
