/// Waktu API sudah mengikuti timezone lokasi, tidak dikonversi ke zona perangkat.
class Weather {
  const Weather({
    required this.time,
    required this.timezone,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.code,
    required this.isDay,
    required this.daily,
    required this.hourly,
  });

  final DateTime time;
  final String timezone;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int code;
  final bool isDay;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];
    if (current is! Map<String, dynamic> ||
        daily is! Map<String, dynamic> ||
        json['timezone'] is! String) {
      throw const FormatException('Struktur data cuaca tidak valid.');
    }
    final times = daily['time'];
    const keys = [
      'weather_code',
      'temperature_2m_max',
      'temperature_2m_min',
      'precipitation_probability_max',
      'sunrise',
      'sunset',
      'uv_index_max',
      'precipitation_sum',
      'wind_speed_10m_max',
    ];
    if (times is! List ||
        times.isEmpty ||
        keys.any(
          (key) =>
              daily[key] is! List ||
              (daily[key] as List).length != times.length,
        )) {
      throw const FormatException('Data prakiraan kosong atau tidak lengkap.');
    }
    final days = List.generate(
      times.length,
      (i) => DailyForecast(
        date: _date(times[i]),
        code: _number(daily['weather_code'][i]).toInt(),
        maximum: _number(daily['temperature_2m_max'][i]),
        minimum: _number(daily['temperature_2m_min'][i]),
        rainProbability: _number(daily['precipitation_probability_max'][i])
            .toInt(),
        sunrise: _date(daily['sunrise'][i]),
        sunset: _date(daily['sunset'][i]),
        uvIndex: _number(daily['uv_index_max'][i]),
        precipitation: _number(daily['precipitation_sum'][i]),
        maximumWind: _number(daily['wind_speed_10m_max'][i]),
      ),
    );
    final hourly = json['hourly'];
    if (hourly is! Map<String, dynamic>) {
      throw const FormatException('Prakiraan per jam tidak tersedia.');
    }
    final hours = hourly['time'];
    const hourlyKeys = [
      'temperature_2m',
      'precipitation_probability',
      'weather_code',
      'is_day',
    ];
    if (hours is! List ||
        hours.isEmpty ||
        hourlyKeys.any(
          (key) =>
              hourly[key] is! List ||
              (hourly[key] as List).length != hours.length,
        )) {
      throw const FormatException('Prakiraan per jam tidak lengkap.');
    }
    final hourlyForecasts = List.generate(
      hours.length,
      (i) => HourlyForecast(
        time: _date(hours[i]),
        temperature: _number(hourly['temperature_2m'][i]),
        rainProbability: _number(hourly['precipitation_probability'][i])
            .toInt(),
        code: _number(hourly['weather_code'][i]).toInt(),
        isDay: _number(hourly['is_day'][i]) == 1,
      ),
    );
    return Weather(
      time: _date(current['time']),
      timezone: json['timezone'] as String,
      temperature: _number(current['temperature_2m']),
      feelsLike: _number(current['apparent_temperature']),
      humidity: _number(current['relative_humidity_2m']).toInt(),
      windSpeed: _number(current['wind_speed_10m']),
      code: _number(current['weather_code']).toInt(),
      isDay: _number(current['is_day']) == 1,
      daily: List.unmodifiable(days),
      hourly: List.unmodifiable(hourlyForecasts),
    );
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.code,
    required this.maximum,
    required this.minimum,
    required this.rainProbability,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.precipitation,
    required this.maximumWind,
  });

  final DateTime date;
  final int code;
  final double maximum;
  final double minimum;
  final int rainProbability;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndex;
  final double precipitation;
  final double maximumWind;
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.rainProbability,
    required this.code,
    required this.isDay,
  });
  final DateTime time;
  final double temperature;
  final int rainProbability;
  final int code;
  final bool isDay;
}

double _number(dynamic value) {
  if (value is! num || !value.isFinite) {
    throw const FormatException('Nilai cuaca tidak tersedia atau tidak valid.');
  }
  return value.toDouble();
}

DateTime _date(dynamic value) {
  if (value is! String) {
    throw const FormatException('Waktu cuaca tidak valid.');
  }
  final date = DateTime.tryParse(value);
  if (date == null) throw const FormatException('Waktu cuaca tidak valid.');
  return date;
}
