# Masjid Sabilillah — Praktikum Pemrograman Mobile

Aplikasi Flutter untuk jamaah dan pengurus Masjid Sabilillah: jadwal sholat, pengumuman dan kajian, agenda Ramadhan, serta pelacakan lokasi. Data disimpan di Supabase, state management dan routing memakai GetX.

Spesifikasi kebutuhan (use case diagram + use case description) ada di [docs/SPESIFIKASI_KEBUTUHAN.md](docs/SPESIFIKASI_KEBUTUHAN.md).

## Fitur

| Fitur | Keterangan |
|---|---|
| Registrasi & Login | Autentikasi email/password dengan Supabase Auth. Sesi dicek di Splash Screen. |
| Jadwal Sholat | Lima waktu sholat hari ini dari API Aladhan (metode Kemenag). |
| Pengumuman | Daftar dan detail info/kajian masjid. Admin dapat menambah, mengubah, dan menghapus. |
| Agenda Ramadhan | Jadwal Tarawih, Takjil, dan Kajian. Admin dapat menambah, mengubah, dan menghapus. |
| Lokasi | Pelacakan posisi dengan provider GPS/Network di peta OpenStreetMap (mode statis dan bergerak). |
| Pengaturan | Tema terang/gelap (tersimpan di SharedPreferences) dan logout. |
| Donasi | Halaman informasi; fitur pembayaran belum tersedia. |

Akun admin ditentukan oleh email `admin@masjid.com` (lihat `lib/database/core/services/supabase_service.dart`).

## Struktur Proyek

```
lib/
├── main.dart                     # Routing GetX & tema
├── core/
│   ├── constants/app_colors.dart
│   └── providers/theme_controller.dart
├── data/
│   ├── models/prayer_time_model.dart
│   └── services/                 # API Aladhan & SharedPreferences
├── database/                     # Fitur berbasis Supabase
│   ├── core/services/supabase_service.dart
│   └── features/
│       ├── announcements/        # model, repository, controller, views
│       └── ramadhan/             # model, repository, views
├── lokasi/                       # Pelacakan lokasi GPS/Network
└── presentation/
    ├── screens/                  # splash, login, signup, home, jadwal, donasi, pengaturan
    └── widgets/
```

## Menjalankan Aplikasi

1. Salin `.env.example` menjadi `.env`, lalu isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY`.
2. Pastikan tabel `announcements` dan `ramadhan_schedules` sudah ada di Supabase.
3. Jalankan:

```bash
flutter pub get
flutter run
```

Pengujian:

```bash
flutter analyze
flutter test
```
