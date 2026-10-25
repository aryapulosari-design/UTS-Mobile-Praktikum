# Pemeriksaan terhadap naskah UTS asli

Acuan: UJIAN TENGAH SEMESTER (UTS), Matakuliah Pemrograman Mobile, Senin 19 Oktober 2026, Praktikum Mobile Programming G. Batas pengumpulan: 26 Oktober 2026, 23.59 WIB.

**Status:** implementasi teknis, dokumentasi, dan repositori GitHub Public telah disiapkan. Pengumpulan belum lengkap sampai cover dan tautan Google Drive diselesaikan. Nilai akhir tetap merupakan penilaian dosen.

| Ketentuan soal | Bukti di proyek | Status |
| --- | --- | --- |
| B.1.1 Flutter dan Dart | `pubspec.yaml`, `lib/main.dart`, `lib/app.dart` | Terpenuhi |
| B.1.2 Minimal satu halaman GUI | Beranda, pencarian kota, detail prakiraan harian | Terpenuhi |
| B.1.3 Data dinamis melalui API | `WeatherService` mengakses Open-Meteo Forecast dan Geocoding | Terpenuhi berdasarkan asumsi API di bawah |
| B.1.4–5 Penyajian dan fungsi sesuai ide | Cuaca saat ini, 24 jam, tujuh hari, detail harian, pencarian, refresh, favorit | Terpenuhi pada pengujian lokal |
| Pemeriksaan atribut sebelum implementasi | Respons API asli diperiksa; parameter, struktur dan seleksi atribut dijelaskan dalam README dan BAB II | Terdokumentasi |
| B.1.1 Pengambilan/pengolahan: HTTP request | `lib/services/weather_service.dart` | Terpenuhi |
| Validasi respons server | Pemeriksaan HTTP 200, pesan 429/status lain, timeout, error jaringan | Terpenuhi |
| JSON menjadi class model | `City.fromJson`, `Weather.fromJson`, `DailyForecast`, `HourlyForecast` | Terpenuhi |
| Penyajian data ke UI | `WeatherContent`, `HourlyForecastStrip`, `DailyDetailScreen` | Terpenuhi |
| B.1.2 Asynchronous programming | `FutureBuilder<Weather>` dan `FutureBuilder<List<City>>`; Future disimpan pada state | Terpenuhi |
| Loading, success, error | `StatusPanel`, data cuaca, pesan dan tombol coba lagi | Terpenuhi |
| B.2 Source lengkap dan struktur rapi | Folder platform Flutter, model, services, screens, widgets, utils, test, docs; `pubspec.lock` | Siap diunggah |
| B.2 README wajib | Nama, deskripsi, fitur, teknologi/package dan langkah menjalankan ada di `README.md` | Terpenuhi |
| B.2 GitHub Public dan link | [aryapulosari-design/UTS-Mobile-Praktikum](https://github.com/aryapulosari-design/UTS-Mobile-Praktikum), branch main | Selesai; README publik HTTP 200 tanpa login |
| B.3 Cover | Judul, matakuliah, nama/NIM, jurusan dan tahun terisi; kampus serta logo fakultas belum tersedia | Perlu dilengkapi |
| BAB I 1.1–1.2 | Latar belakang, tujuan, sasaran, gambaran aplikasi, fitur dan manfaat | Tersedia |
| BAB II 2.1 | Persiapan proyek, struktur, package serta fungsi/alasan pemakaian | Tersedia |
| BAB II 2.2 | Penjelasan UI dan screenshot bernomor, judul serta keterangan | Tersedia |
| BAB II 2.3 | URL/jenis data, HTTP, JSON/model, async, penyajian dan status UI; potongan kode disertai penjelasan | Tersedia |
| BAB III 3.1–3.2 | Kesimpulan pengembangan/pengujian dan saran | Tersedia |
| Daftar pustaka | Dokumentasi Flutter, Dart, HTTP, Shared Preferences dan API | Tersedia |
| B.4 Laporan PDF | Sumber edit `docs/laporan.html`; PDF ekspor disimpan lokal dan tidak diunggah ke GitHub | PDF perlu diekspor setelah cover dilengkapi |
| B.4 Google Drive Anyone with the link, Viewer | Belum diunggah ke Drive | Belum selesai |
| B.5 Dua tautan tanpa login | GitHub sudah terverifikasi publik tanpa login; tautan Drive belum tersedia | Perlu menyelesaikan Drive dan pemeriksaan akhir kedua tautan |

## Penjelasan API

Naskah asli menyebut “URL yang telah disediakan”, tetapi teks lampiran tidak memuat URL. Pengguna sebelumnya mengonfirmasi tidak ada URL khusus. Open-Meteo digunakan sebagai pilihan API untuk proyek ini. Hal ini tidak berarti dosen telah menyetujui penyedia API tersebut; jika dosen menetapkan URL tersendiri, implementasi dan laporan harus menyesuaikannya.

## Bukti pengujian dan batasnya

- Analisis Flutter tanpa masalah dan 34 pengujian otomatis lulus.
- Model/helper: 7 tes; layanan HTTP: 13 tes; penyimpanan favorit: 4 tes; interaksi widget: 10 tes.
- Request asli API telah diperiksa, termasuk 24 data per jam dan tujuh hari.
- Screenshot sukses menggunakan data asli; loading/error diuji melalui intersepsi jaringan browser.
- Penyimpanan favorit setelah reload diverifikasi dalam browser pada profil pengujian tersendiri.
- Build APK release dan web disiapkan. Keberhasilan build tidak dianggap sebagai bukti instalasi di ponsel.
- Android fisik/emulator belum diuji dalam sesi ini; panduan pengujian tersedia di README dan laporan.

## Langkah akhir yang masih diperlukan

1. Lengkapi nama perguruan tinggi dan logo fakultas pada cover; ekspor ulang PDF.
2. Uji pemasangan dan fungsi APK di perangkat/emulator Android, lalu catat hasil aktual.
3. Pertahankan proyek akhir di [GitHub Public](https://github.com/aryapulosari-design/UTS-Mobile-Praktikum) dan unggah perubahan lanjutan jika ada.
4. Unggah PDF final ke Google Drive sebagai Anyone with the link — Viewer.
5. Uji kedua tautan melalui Incognito tanpa login dan kumpulkan sebelum tenggat.
