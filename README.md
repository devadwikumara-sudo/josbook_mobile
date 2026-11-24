# JosBook Mobile

Aplikasi Flutter/Dart untuk siswa yang terhubung ke API Laravel website JosBook. Data siswa dibaca dan perubahan profil/notifikasi dikirim lewat REST API; aplikasi tidak mengakses MySQL secara langsung.

## Menjalankan dengan backend lokal

1. Pastikan proyek backend Laravel sudah dikonfigurasi agar tersambung ke database sekolah yang digunakan website. Jalankan backend dari folder proyeknya:

   ```powershell
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. Jalankan aplikasi pada emulator Android:

   ```powershell
   flutter run
   ```

   URL debug bawaan memakai `http://10.0.2.2:8000/api/v1` pada emulator Android dan `http://josbook_web.test/api/v1` pada Flutter Web (Laragon). Jika nama virtual host berbeda, atur `API_BASE_URL`. Backend lokal mengizinkan origin localhost pada environment Laravel `local` saja. Untuk perangkat fisik, berikan alamat LAN komputer:

   ```powershell
   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
   ```

3. Build selain debug harus menerima `API_BASE_URL`; build rilis hanya menerima URL HTTPS:

   ```powershell
   flutter build apk --dart-define=API_BASE_URL=https://api.sekolah.example/api/v1
   ```

Jangan menaruh username/password database atau token rahasia di source code maupun konfigurasi build yang dibagikan. Detail path dan bentuk JSON ada di [docs/api-kontrak.md](docs/api-kontrak.md).

## Pemeriksaan

```powershell
flutter analyze
flutter test
```
