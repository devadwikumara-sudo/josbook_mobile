# JosBook Mobile (Flutter) - Aturan Proyek

Ganti nama file ini menjadi CLAUDE.md dan letakkan di root proyek Flutter (sejajar dengan pubspec.yaml).
Agent membaca file ini otomatis di setiap sesi. Jangan hapus.

## Ringkasan proyek
Aplikasi mobile JosBook untuk SISWA SMA Negeri 1 Rejoso Nganjuk: melihat biodata, nilai per semester,
mengunduh dokumen PDF, notifikasi, dan mengelola profil/sesi. Backend: proyek Laravel (repo terpisah) dengan API
/api/v1/* dan token Sanctum. Bahasa antarmuka: Bahasa Indonesia.

## Kontrak API
Salinan kontrak API ada di docs/api-kontrak.md (salinan routes/api.php dan AuthApiController, NilaiApiController,
NotifikasiApiController, dll. dari proyek web). Itu SATU-SATUNYA sumber kebenaran nama endpoint dan bentuk respons.
JANGAN menebak endpoint atau field. Jika sebuah endpoint tidak ada di dokumen, berhenti dan tanyakan.
Backend TIDAK boleh diubah dari proyek ini; jika butuh perubahan API, tulis kebutuhannya dan berhenti.

## Teknologi yang sudah dipakai (jangan ganti tanpa diminta)
- State: provider (pola AuthProvider, ProfilProvider)
- Routing: go_router (rute di lib/app.dart)
- HTTP: dio lewat lib/core/api_client.dart, token di flutter_secure_storage (lib/core/token_storage.dart)
- Berbagi/unduh file: share_plus, url_launcher
- Konfigurasi: lib/core/config.dart (baseUrl lewat String.fromEnvironment)

## Struktur
lib/core (config, api_client, theme, token_storage), lib/features/<fitur>/ (screen, service, provider, widgets),
lib/shared/widgets. Fitur: auth, home, biodata, nilai, unduh, profil, sesi, splash.
Ikuti pola yang sudah ada (service memanggil API, provider menyimpan state, screen menampilkan).

## Aturan desain
- Ikuti desain di folder desain mobile yang dirujuk tugas. Jangan mengarang tampilan baru.
- Gunakan theme dan warna yang ada (lib/core/theme.dart, auth_warna.dart, home_warna.dart).
- Nama produk selalu "JosBook" (bukan JosLearn).

## Aturan kerja (berlaku di semua tugas)
1. Baca dulu kode yang relevan dan tulis rencana singkat sebelum mengedit. Jika kode berbeda dari deskripsi
   tugas, percayai kode dan beri tahu perbedaannya.
2. Kerjakan HANYA tugas yang diminta. Jangan merapikan atau mengubah fitur lain.
3. Tidak ada data contoh yang ditulis langsung di layar (hardcode) untuk fitur yang punya API.
4. Setiap layar yang memanggil API wajib punya tiga keadaan: loading, error (dengan tombol coba lagi), dan kosong.
5. Token tidak boleh dicetak ke log. Jangan menyimpan kata sandi di penyimpanan permanen.
6. Respons 401 (token dicabut/kedaluwarsa) harus menghapus token dan mengarahkan ke login.
7. Setelah selesai: jalankan `flutter analyze` dan `flutter test`, tampilkan hasilnya, dan ringkas file yang diubah.
   Jangan klaim selesai jika analisis menampilkan error.
8. Jangan commit sendiri kecuali diminta.

## Perintah
- Analisis: `flutter analyze`
- Test: `flutter test`
- Jalankan dengan server lokal (emulator Android): `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
  (cek nama variabel sebenarnya di lib/core/config.dart)
