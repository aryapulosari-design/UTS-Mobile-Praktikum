import 'package:flutter/material.dart';

String weatherLabel(int code) => switch (code) {
  0 => 'Cerah',
  1 => 'Cerah berawan',
  2 => 'Berawan sebagian',
  3 => 'Berawan',
  45 || 48 => 'Berkabut',
  51 || 53 || 55 => 'Gerimis',
  56 || 57 => 'Gerimis beku',
  61 || 63 || 65 => 'Hujan',
  66 || 67 => 'Hujan beku',
  71 || 73 || 75 || 77 => 'Bersalju',
  80 || 81 || 82 => 'Hujan lokal',
  85 || 86 => 'Hujan salju',
  95 || 96 || 99 => 'Hujan petir',
  _ => 'Kondisi belum dikenali',
};

IconData weatherIcon(int code, {bool isDay = true}) => switch (code) {
  0 => isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
  1 || 2 => isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded,
  3 => Icons.cloud_rounded,
  45 || 48 => Icons.foggy,
  71 || 73 || 75 || 77 || 85 || 86 => Icons.ac_unit_rounded,
  95 || 96 || 99 => Icons.thunderstorm_rounded,
  51 ||
  53 ||
  55 ||
  56 ||
  57 ||
  61 ||
  63 ||
  65 ||
  66 ||
  67 ||
  80 ||
  81 ||
  82 => Icons.water_drop_rounded,
  _ => Icons.cloud_queue_rounded,
};

String dayLabel(DateTime date) => const [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
][date.weekday - 1];

String dateLabel(DateTime date) =>
    '${date.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][date.month - 1]} ${date.year}';

String clockLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
