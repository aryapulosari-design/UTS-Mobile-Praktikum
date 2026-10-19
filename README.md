# UTS-Mobile-Praktikum — LangitKita

Repositori GitHub Public: [aryapulosari-design/UTS-Mobile-Praktikum](https://github.com/aryapulosari-design/UTS-Mobile-Praktikum).

Aplikasi Flutter untuk melihat cuaca kota-kota di Indonesia, mencari lokasi, dan membaca prakiraan tujuh hari. Data diambil secara langsung melalui HTTP dari Open-Meteo, diparsing menjadi objek Dart, lalu ditampilkan menggunakan `FutureBuilder`.

| Identitas | Keterangan |
| --- | --- |
| Nama | Arya Kharisudin Irfani |
| NIM | 240605110227 |
| Program studi | Teknik Informatika |
| Mata kuliah | Pemrograman Mobile |
| Kelas | Praktikum Mobile Programming G |
| Nama aplikasi / paket | LangitKita / `langit_kita` |
| Batas pengumpulan | Senin, 26 Oktober 2026, pukul 23.59 WIB |

## Fitur utama

- Cuaca saat ini: suhu, kondisi cuaca berbahasa Indonesia, serta ikon siang/malam.
- Detail kelembapan, suhu terasa, kecepatan angin, dan peluang hujan maksimum harian.
- Prakiraan tujuh hari: kondisi cuaca, suhu maksimum/minimum, dan peluang hujan.
- Prakiraan 24 jam mulai jam berjalan: suhu, ikon siang/malam, tanggal/jam, dan peluang hujan; geser kartu ke samping.
- Detail prakiraan harian: ketuk hari pada daftar tujuh hari untuk melihat UV maksimum, total curah hujan, angin maksimum, serta waktu matahari terbit dan terbenam.
- Kota favorit: simpan/hapus kota pilihan dan pilih kembali dari daftar favorit. Pilihan tersimpan secara lokal setelah aplikasi ditutup; data cuaca tetap berasal dari API.
- Delapan pilihan kota cepat: Jakarta, Bandung, Yogyakarta, Surabaya, Malang, Kediri, Denpasar, Makassar. Kota Jawa Timur yang tersedia langsung adalah Surabaya, Malang, dan Kediri; geser daftar kota ke samping untuk melihat semuanya.
- Pencarian kota/wilayah Indonesia menggunakan Geocoding API dan pemilihan hasil pencarian.
- Pembaruan data melalui tombol refresh atau tarik layar ke bawah.
- Penanganan loading, sukses, data kosong, error HTTP, JSON rusak, jaringan terputus, dan timeout 15 detik, dengan tombol coba lagi.
- Tata letak dapat digulir dan menyesuaikan lebar layar; halaman informasi aplikasi dan atribusi sumber data.

## API yang dipilih dan alasan pemilihan

**Open-Meteo Forecast API + Geocoding API** dipilih karena cocok untuk proyek akademik: respons JSON jelas, data dinamis, mendukung koordinat Indonesia, dan tidak memerlukan API key untuk penggunaan nonkomersial. Akses gratis mengikuti [ketentuan Open-Meteo](https://open-meteo.com/en/terms). Data cuaca berlisensi CC BY 4.0; data lokasi berasal dari GeoNames. Atribusi dicantumkan dalam aplikasi dan dokumentasi.

**Asumsi tugas:** teks soal menyebut URL API yang disediakan, tetapi lampiran tidak mencantumkan URL tersebut dan pengguna mengonfirmasi tidak ada URL khusus. Proyek ini menggunakan Open-Meteo. Apabila dosen kemudian menetapkan API tertentu, layanan dan model perlu disesuaikan terlebih dahulu.

Dokumentasi resmi:

- [Weather Forecast API](https://open-meteo.com/en/docs)
- [Geocoding API](https://open-meteo.com/en/docs/geocoding-api)
- [Lisensi CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- [GeoNames](https://www.geonames.org/)

### Endpoint cuaca

```text
GET https://api.open-meteo.com/v1/forecast
```

| Parameter | Nilai / fungsi |
| --- | --- |
| `latitude`, `longitude` | Koordinat kota pilihan |
| `current` | `temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m` |
| `daily` | `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset,uv_index_max,precipitation_sum,wind_speed_10m_max` |
| `hourly` | `temperature_2m,precipitation_probability,weather_code,is_day` |
| `forecast_hours` | `24`, dimulai dari jam berjalan pada lokasi kota |
| `timezone` | `auto`, mengikuti lokasi kota |
| `temperature_unit` | `celsius` |
| `wind_speed_unit` | `kmh` |
| `forecast_days` | `7` |

[Contoh request Jakarta yang dapat dibuka di browser](https://api.open-meteo.com/v1/forecast?latitude=-6.2&longitude=106.8167&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset,uv_index_max,precipitation_sum,wind_speed_10m_max&hourly=temperature_2m,precipitation_probability,weather_code,is_day&forecast_hours=24&timezone=auto&temperature_unit=celsius&wind_speed_unit=kmh&forecast_days=7).

### Endpoint pencarian

```text
GET https://geocoding-api.open-meteo.com/v1/search?name=Bandung&count=10&language=id&format=json&countryCode=ID
```

Input minimal tiga karakter. Pencarian hanya dikirim setelah tombol Cari lokasi atau tombol cari pada keyboard ditekan. Jika `results` tidak ada, aplikasi menampilkan lokasi tidak ditemukan. Koordinat kota pilihan diteruskan ke endpoint cuaca.

### Pemeriksaan struktur respons sebelum implementasi

Pengembangan fitur tambahan juga diawali pemeriksaan endpoint asli. Respons untuk Malang mengandung **24 entri `hourly` dan tujuh entri `daily`**, termasuk `sunrise`, `sunset`, `uv_index_max`, `precipitation_sum`, dan `wind_speed_10m_max`. Contoh JSON di bawah hanya memperlihatkan sebagian atribut current/daily. Model lengkap juga memvalidasi array per jam; timestamp dipertahankan sesuai zona lokasi dari API.

Pada 19 Oktober 2026, kedua endpoint diperiksa langsung. Forecast mengembalikan **HTTP 200** dengan objek `current`, objek `daily`, dan `timezone`; pencarian Bandung mengembalikan array `results` dengan nama, region, latitude, dan longitude. Contoh ringkas berikut merupakan ilustrasi struktur, bukan data cuaca terkini:

```json
{
  "timezone": "Asia/Jakarta",
  "current": {
    "time": "2026-10-19T09:15",
    "temperature_2m": 31.5,
    "relative_humidity_2m": 59,
    "apparent_temperature": 37.5,
    "is_day": 1,
    "weather_code": 3,
    "wind_speed_10m": 0.9
  },
  "daily": {
    "time": ["2026-10-19", "2026-10-20"],
    "weather_code": [53, 51],
    "temperature_2m_max": [35.3, 34.9],
    "temperature_2m_min": [25.9, 26.5],
    "precipitation_probability_max": [59, 61]
  }
}
```

Contoh dipersingkat menjadi dua hari; aplikasi meminta tujuh hari. Array harian dipasangkan berdasarkan indeks yang sama, dan panjang seluruh array divalidasi. Angka `null`, nilai bukan angka, tanggal tidak valid, atau data harian kosong menghasilkan pesan error, bukan angka 0 yang menyesatkan. Atribut lain seperti elevasi dan waktu pemrosesan server tidak ditampilkan karena tidak diperlukan pengguna.

Cuaca saat ini adalah estimasi model Open-Meteo. Waktu pada UI mengikuti zona lokasi dari API, bukan jam perangkat. Peluang hujan adalah nilai maksimum harian, bukan peluang tepat pada saat aplikasi dibuka.

## Teknologi

| Teknologi | Fungsi |
| --- | --- |
| Flutter 3.47.2 / Dart 3.13.2 | Versi SDK yang digunakan saat pengembangan dan pengujian |
| Material 3 | Komponen UI, navigasi, formulir, dan tema |
| `http: ^1.6.0` | HTTP GET lintas Android, iOS, desktop, dan web |
| `cupertino_icons: ^1.0.8` | Font ikon Cupertino untuk komponen adaptif bawaan Flutter |
| `shared_preferences: ^2.5.6` | Penyimpanan kota favorit dengan `SharedPreferencesAsync` |
| `dart:convert` | Dekode UTF-8 dan parsing JSON |
| `FutureBuilder` + `setState` | State asinkron dan pergantian kota |
| `flutter_test`, `http/testing.dart` | Pengujian model, layanan HTTP, dan interaksi widget tanpa internet |
| `flutter_lints: ^6.0.0` | Analisis kualitas kode |
| Node.js 22+ dan Chrome (opsional) | Server preview, screenshot browser, dan ekspor PDF; bukan dependensi aplikasi |

Versi paket yang terpasang dikunci dalam `pubspec.lock`.

Kota favorit memakai `SharedPreferencesAsync` dan hanya menyimpan nama, region, serta koordinat. Penyimpanan memakai kunci khusus `langit_kita.favorite_cities.v1`; kota dengan koordinat yang sama digabungkan. Aplikasi menunggu hasil simpan sebelum menampilkan keberhasilan. Favorit di web tersimpan pada origin browser yang sama; mengubah alamat/port preview menggunakan ruang penyimpanan yang berbeda. Fitur ini tidak menyimpan data cuaca untuk mode offline.

## Struktur proyek

```text
uts mobile praktikum/
├── lib/
│   ├── main.dart                     # Entry point
│   ├── app.dart                      # MaterialApp dan tema
│   ├── models/
│   │   ├── city.dart                 # Model lokasi dan kota cepat
│   │   └── weather.dart              # Model cuaca serta validasi JSON
│   ├── services/weather_service.dart # Request, status HTTP, timeout, error
│   ├── services/favorites_store.dart # Simpan, muat, deduplikasi kota favorit
│   ├── screens/
│   │   ├── weather_screen.dart       # Beranda dan FutureBuilder cuaca
│   │   ├── city_search_screen.dart   # Form, FutureBuilder hasil, navigasi
│   │   └── daily_detail_screen.dart  # Halaman detail prakiraan harian
│   ├── widgets/
│   │   ├── status_panel.dart         # Komponen loading / kosong / error
│   │   ├── weather_content.dart      # Kartu cuaca, metrik, prakiraan
│   │   └── hourly_forecast_strip.dart # Kartu prakiraan 24 jam
│   └── utils/weather_display.dart   # Kode WMO, ikon, tanggal Indonesia
├── test/                             # 34 pengujian deterministik
├── docs/
│   ├── laporan.html                  # Sumber laporan yang dapat diedit
│   ├── Laporan_UTS_LangitKita.pdf     # Ekspor laporan; lengkapi cover
│   └── screenshots/                  # Bukti tampilan browser asli
├── tools/                            # Preview dan pembuatan dokumentasi
├── android/ ios/ web/ windows/ linux/ macos/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

Folder kerja tetap bernama `uts mobile praktikum`. Nama paket Dart, kelas utama, Kotlin package, identitas platform, judul aplikasi, dan berkas IDE telah disesuaikan dari demo `row_and_column` ke LangitKita. Izin internet Android ada pada manifest utama agar berlaku untuk build release; macOS menggunakan entitlement network client. Berkas lokal hasil generate tidak perlu diedit manual atau diunggah.

## Menjalankan aplikasi di folder ini

Prasyarat: Flutter tersedia di PATH, Dart sesuai `pubspec.yaml`, internet aktif, serta Android SDK dan perangkat/emulator jika menjalankan Android.

```powershell
Set-Location -LiteralPath 'C:\File Arya\uin S1\Uin Semester 5\Mobile\Praktikum\project\row_and_column\uts mobile praktikum'
flutter pub get
flutter devices
```

Android (aktifkan USB debugging atau mulai emulator):

```powershell
flutter run -d <ID_PERANGKAT_ANDROID>
```

Ganti `<ID_PERANGKAT_ANDROID>` dengan ID dari `flutter devices`, tanpa tanda `< >`.

Chrome:

```powershell
flutter run -d chrome
```

Windows (memerlukan Visual Studio dengan workload Desktop development with C++):

```powershell
flutter run -d windows
```

Gunakan `q` pada terminal untuk menghentikan aplikasi. Tidak perlu `.env` atau API key.

### Build APK dan web

```powershell
flutter build apk --release
flutter build web --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`. Hasil web: `build/web/`. APK tugas masih menggunakan debug signing dari template Flutter; distribusi toko aplikasi memerlukan konfigurasi signing sendiri.

Untuk preview hasil build web tanpa package tambahan (opsional, Node.js 22+):

```powershell
node tools/preview.mjs
```

Buka `http://127.0.0.1:8787`. Gunakan Ctrl+C untuk menghentikan server. Hasil web harus disajikan melalui HTTP, bukan dibuka langsung sebagai file HTML.

## Alur implementasi API dan FutureBuilder

```text
Pilih kota → simpan Future di state → HTTP GET → validasi status 200
→ decode JSON → validasi model Weather → FutureBuilder → tampilan cuaca
```

`_weather` dibuat pada `initState` dan diperbarui saat pengguna mengganti kota atau meminta refresh. Request tidak dibuat di dalam `build`, sehingga rebuild tidak memanggil API berulang. Pencarian menggunakan Future tersendiri; hasil pilihan dikembalikan dengan `Navigator.pop(city)`.

```dart
final response = await _client.get(uri).timeout(timeout);
if (response.statusCode != 200) {
  throw WeatherException('Layanan belum tersedia (HTTP ${response.statusCode}). Coba lagi.');
}
final decoded = jsonDecode(utf8.decode(response.bodyBytes));
```

Potongan di atas merangkum pemeriksaan respons; kode lengkap juga memberikan pesan khusus HTTP 429 dan memvalidasi tipe objek JSON.

```dart
FutureBuilder<Weather>(
  future: _weather,
  builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      // Tampilkan StatusPanel loading.
    }
    if (snapshot.hasError) {
      // Tampilkan pesan error dan tombol coba lagi.
    }
    // Validasi data tersedia, lalu tampilkan WeatherContent.
  },
)
```

Potongan kedua adalah skema penjelasan, bukan kode yang disalin untuk dijalankan. Implementasi lengkap ada di `lib/screens/weather_screen.dart`.

## Pengujian

```powershell
flutter analyze
flutter test --reporter expanded
```

Hasil yang telah terverifikasi pada 19 Oktober 2026: **analisis tanpa masalah dan 34 tes lulus**. Build web dan APK Android release juga berhasil. APK tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

| Kelompok | Jumlah | Cakupan |
| --- | ---: | --- |
| Model dan helper | 7 | Parsing tujuh hari, angka integer/double, null, tanggal rusak, array tidak sama, koordinat, label WMO |
| Layanan API | 13 | Query request, HTTP 429/500, JSON/struktur tidak valid, koneksi gagal, timeout, pencarian dan hasil kosong |
| Favorit | 4 | Persistensi antar-instance, deduplikasi, entri rusak, penghapusan dan kegagalan penyimpanan |
| Widget | 10 | Loading/sukses/error, pilihan dan pencarian kota, layar kecil, detail harian, gulir per jam, favorit tersimpan/hapus/gagal |

Tes otomatis menggunakan `MockClient` agar hasilnya stabil dan tidak membebani API. Data fixture hanya dipakai pengujian; aplikasi tetap mengakses API asli. Pemeriksaan endpoint asli dilakukan terpisah.

### Skenario pemeriksaan manual

| Skenario | Langkah | Hasil yang diharapkan |
| --- | --- | --- |
| Cuaca awal | Buka aplikasi dengan internet | Loading lalu cuaca Jakarta dan tujuh prakiraan |
| Ganti kota | Tekan Bandung | Nama wilayah dan koordinat request berubah |
| Cari kota | Cari Malang lalu pilih hasil | Kembali ke beranda dengan cuaca Malang |
| Input pendek | Masukkan dua karakter lalu Cari lokasi | Pesan minimal tiga karakter |
| Lokasi kosong | Cari nama tidak dikenal | Tampilan lokasi tidak ditemukan |
| Refresh | Tekan ikon refresh atau tarik ke bawah | Data dimuat ulang tanpa membuat halaman baru |
| Offline | Putus koneksi, kemudian refresh | Pesan error dan tombol coba lagi |
| Pemulihan | Aktifkan koneksi lalu Coba lagi | Data cuaca berhasil ditampilkan |
| Respons server rusak | Simulasikan melalui MockClient | Pesan error tanpa crash |
| Layar kecil | Jalankan dengan lebar 320 piksel | Konten dapat digulir tanpa overflow |
| Favorit | Simpan kota, tutup/buka aplikasi, lalu pilih favorit | Pilihan kota tetap tersimpan dan cuaca dimuat dari API |
| Hapus favorit | Pilih kota favorit lalu Hapus dari favorit | Kota hilang dari daftar dan penyimpanan lokal |
| Per jam | Gulir kartu prakiraan hingga melewati tengah malam | Tanggal/jam, suhu, dan peluang hujan sesuai data API |
| Detail harian | Ketuk salah satu hari pada prakiraan | Halaman detail menampilkan tanggal, UV, hujan, angin, terbit/terbenam |

Tabel manual adalah panduan verifikasi, bukan klaim semua skenario telah diuji di ponsel. Belum ada perangkat Android yang terhubung saat pemeriksaan awal; pengujian Android fisik tetap perlu dilakukan.

## Screenshot dan laporan

Screenshot diambil dari aplikasi Flutter web pada viewport ponsel 430 × 932. Loading dan error disimulasikan melalui intersepsi jaringan browser; tampilan sukses menggunakan API cuaca asli. Waktu dan hasil tangkapan dicatat dalam `docs/capture_evidence.json` setelah skrip berhasil dijalankan.

| Gambar | Berkas | Keterangan |
| --- | --- | --- |
| 1 | [Loading](docs/screenshots/01-loading.png) | Future menunggu respons |
| 2 | [Cuaca Jakarta](docs/screenshots/02-cuaca-jakarta.png) | Data cuaca dari API asli |
| 3 | [Prakiraan](docs/screenshots/03-prakiraan.png) | Detail dan prakiraan tujuh hari |
| 4 | [Pencarian kota](docs/screenshots/04-pencarian.png) | Halaman pencarian lokasi Indonesia |
| 5 | [Error](docs/screenshots/05-error.png) | Koneksi gagal dan tombol coba lagi |
| 6 | [Kota favorit](docs/screenshots/06-favorit.png) | Kota tersimpan dan dapat dipilih kembali |
| 7 | [Prakiraan per jam](docs/screenshots/07-per-jam.png) | Data 24 jam dengan ikon siang/malam |
| 8 | [Detail harian](docs/screenshots/08-detail-harian.png) | UV, total hujan, angin, matahari terbit/terbenam |

[Laporan PDF](docs/Laporan_UTS_LangitKita.pdf) dan [sumber HTML laporan](docs/laporan.html) tersedia di `docs/`. Struktur: cover, BAB I Pendahuluan, BAB II Pembahasan, BAB III Penutup, dan daftar pustaka. Nama, NIM, serta jurusan telah diisi. **Nama perguruan tinggi dan logo fakultas masih perlu dilengkapi pada cover.** Setelah mengedit, ekspor ulang PDF dari browser dengan ukuran A4 dan Background graphics aktif.

Untuk membuat ulang screenshot dan PDF secara otomatis pada Windows (Chrome dan Node.js 22+, internet aktif):

```powershell
flutter build web --release
node tools/capture_documentation.mjs
```

`CHROME_PATH` dapat diatur ke lokasi executable Chrome lain. Skrip menyimpan profil sementara di `build/`, yang diabaikan Git. PDF hasil ekspor tetap perlu diperiksa sebelum dikumpulkan.

## Kesesuaian dengan tugas

Pemeriksaan mengacu pada naskah asli **UJIAN TENGAH SEMESTER (UTS), Pemrograman Mobile, 19 Oktober 2026** yang dilampirkan pengguna. [Rincian pencocokan per ketentuan](docs/KESESUAIAN_UTS.md) membedakan implementasi teknis yang selesai dan persyaratan pengumpulan yang masih perlu dilengkapi.

| Ketentuan | Implementasi |
| --- | --- |
| Flutter dan Dart | Seluruh aplikasi di `lib/` |
| Minimal satu halaman GUI | Beranda, pencarian kota, dan detail prakiraan harian |
| Pemeriksaan atribut API | Dokumentasi respons dan seleksi atribut di README |
| HTTP request dan validasi status | `WeatherService._getJson` |
| JSON menjadi objek Dart | `Weather.fromJson` dan `City.fromJson` |
| FutureBuilder loading/success/error | Beranda dan halaman pencarian |
| Struktur rapi | Model, service, screen, widget, utility, test, docs |
| Pengujian sistematis | 34 tes serta panduan pemeriksaan manual |
| README | Identitas, fitur, API, teknologi, cara menjalankan, pengujian |
| Laporan PDF | `docs/Laporan_UTS_LangitKita.pdf`, cover perlu dilengkapi |
| GitHub Public dan Drive Viewer | Belum diunggah; perlu akun dan tujuan publikasi |

## Sebelum pengumpulan

- [x] Implementasi Flutter berbasis API, JSON model, dan FutureBuilder.
- [x] Pisahkan struktur kode dan sesuaikan identitas proyek.
- [x] Verifikasi respons API asli.
- [x] Jalankan analisis dan seluruh tes otomatis.
- [x] Tulis README dan sumber laporan.
- [x] Build APK Android release dan web; simpan screenshot serta laporan PDF.
- [ ] Lengkapi nama perguruan tinggi dan logo fakultas pada cover, lalu ekspor ulang PDF.
- [ ] Uji APK pada perangkat/emulator Android dan catat hasilnya.
- [ ] Unggah source code versi akhir ke repositori GitHub **Public**.
- [ ] Unggah laporan PDF final ke Google Drive dengan akses **Anyone with the link — Viewer**.
- [ ] Uji kedua tautan melalui Incognito tanpa login.
- [ ] Kumpulkan kedua tautan sebelum **26 Oktober 2026 pukul 23.59 WIB**.

Folder ini memiliki repositori Git sendiri yang terhubung ke `https://github.com/aryapulosari-design/UTS-Mobile-Praktikum.git`. Source code UTS dikelola terpisah dari tugas di direktori induk. Folder `build/`, `.dart_tool/`, `.idea/`, serta berkas lokal Android diabaikan Git. `pubspec.lock` disertakan karena ini proyek aplikasi.

## Referensi

- [Dokumentasi Flutter](https://docs.flutter.dev/)
- [FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [Asynchronous programming Dart](https://dart.dev/libraries/async/async-await)
- [Package HTTP](https://pub.dev/packages/http)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)
- [Pengujian Flutter](https://docs.flutter.dev/testing/overview)
- [Open-Meteo Forecast API](https://open-meteo.com/en/docs)
- [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api)
