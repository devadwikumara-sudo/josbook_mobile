# Rilis Android JosBook

## Konfigurasi

- Atur `API_BASE_URL` saat build. Build release membutuhkan URL HTTPS; bila tidak
  diatur atau bukan HTTPS, aplikasi menampilkan pesan konfigurasi dan tidak
  memulai koneksi API.
- Debug emulator memakai `http://10.0.2.2:8000/api/v1` jika define tidak diisi.
  Untuk perangkat fisik, gunakan alamat HTTPS server atau IP LAN komputer untuk
  debug.
- `version` sekarang `1.0.0+1` di `pubspec.yaml` (`versionName+versionCode`).
  Naikkan build number setiap kali membuat rilis baru.
- `applicationId` dan `namespace` saat ini sama, yaitu
  `com.example.josbook_mobile`, dan cocok dengan package `MainActivity`. Nilai
  `com.example` masih placeholder; tentukan ID reverse-domain milik organisasi
  sebelum publikasi. Setelah pernah dirilis, jangan mengubah applicationId.

## Ikon dan splash screen

Logo tersedia di `assets/images/josbook-logo.png` dan sudah dikonfigurasi untuk
`flutter_launcher_icons` serta `flutter_native_splash`. Sebelum build Android,
ambil dependensi lalu hasilkan resource:

```powershell
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Jalankan kembali kedua generator tersebut jika logo atau konfigurasinya berubah.

## Signing release

1. Buat keystore upload lokal. Simpan cadangan aman di luar repository:

   ```powershell
   keytool -genkeypair -v -keystore android/app/upload-keystore.jks `
     -keyalg RSA -keysize 2048 -validity 10000 -alias josbook-upload
   ```

2. Buat `android/key.properties` secara lokal (file ini diabaikan Git):

   ```properties
   storePassword=ISI_PASSWORD_KEYSTORE
   keyPassword=ISI_PASSWORD_KEY
   keyAlias=josbook-upload
   storeFile=app/upload-keystore.jks
   ```

   Jangan commit `key.properties`, password, atau file `.jks`/`.keystore`.
   Gradle akan menolak task `assembleRelease`/`bundleRelease` jika konfigurasi
   signing atau file keystore belum ada. Jangan memakai signing debug untuk
   APK release.

## Build

Setelah signing siap dan server API production tersedia:

```powershell
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://SERVER-API/api/v1
```

APK berada di `build/app/outputs/flutter-apk/app-release.apk`.

Jika keystore belum tersedia, buktikan build tanpa signing release dengan APK
debug:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Untuk HP fisik, `10.0.2.2` tidak menunjuk ke komputer host; gunakan alamat LAN
komputer yang dapat dijangkau HP (HTTP hanya untuk debug) atau endpoint HTTPS.

## Mock

Jangan berikan `--dart-define=MOCK_AUTH=true` untuk build uji API/produksi.
Mock Auth dan Home juga dibatasi `kDebugMode`, sehingga nonaktif di release.
Rilis tidak menggunakan URL default emulator.

## Checklist uji di HP Android asli

- [ ] Instal APK release yang ditandatangani; pastikan koneksi API memakai HTTPS.
- [ ] Daftar akun dan selesaikan verifikasi OTP.
- [ ] Login dengan akun siswa.
- [ ] Buka nilai dan pastikan satu semester tampil.
- [ ] Unduh PDF dan buka/bagikan hasilnya.
- [ ] Jalankan alur lupa sandi dan verifikasi OTP.
- [ ] Buka notifikasi; pastikan daftar dari backend tampil dan status baca
      tersimpan setelah layar dibuka atau kartu ditekan.
- [ ] Logout semua sesi dan pastikan aplikasi kembali ke alur login.
- [ ] Uji kegagalan koneksi dan pastikan layar/pesan coba lagi tampil tanpa
      aplikasi crash.
