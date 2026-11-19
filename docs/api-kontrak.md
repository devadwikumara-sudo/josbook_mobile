# Kontrak API Mobile JosBook

Mobile memakai API Laravel pada prefix `/api/v1`; API dan website menggunakan database `josbook` yang sama. Semua respons dan request memakai JSON kecuali unduhan dokumen PDF.

## Konfigurasi koneksi

- Emulator Android debug bawaan: `http://10.0.2.2:8000/api/v1`; Flutter Web pada Laragon: `http://joslearn_project.test/api/v1`; simulator iOS debug: `http://127.0.0.1:8000/api/v1`.
- Untuk alamat lain, jalankan aplikasi dengan `--dart-define=API_BASE_URL=<URL_API>`.
- Perangkat fisik harus memakai alamat LAN komputer backend; jangan gunakan alamat emulator `10.0.2.2`.
- CORS backend mengizinkan origin `localhost` hanya saat `APP_ENV=local`; origin produksi harus ditetapkan eksplisit melalui `CORS_ALLOWED_ORIGINS`.
- Build rilis wajib menggunakan URL HTTPS. Jangan menyimpan kredensial database di aplikasi.

## Autentikasi

Endpoint publik: `POST /login`, `/daftar`, `/lupa-password`, dan `/reset-password`. Pendaftaran mengaktifkan akun setelah nama dan NISN cocok dengan data siswa. Pemulihan sandi mengirim tautan sekali pakai melalui email; kata sandi baru diatur pada halaman backend setelah tautan dibuka. Respons sukses membungkus payload dalam `data`; login mengembalikan token Sanctum. Request terlindungi mengirim `Authorization: Bearer <token>`.

Tautan reset berlaku selama 15 menit dan hanya dapat dipakai sekali. OTP website tetap digunakan pada alur autentikasi website.

## Data siswa (wajib login)

| Method | Path | Kegunaan |
|---|---|---|
| GET | `/home` | Ringkasan siswa dan aktivitas terbaru |
| GET | `/biodata` | Biodata siswa |
| GET | `/nilai` | Periode dan nilai siswa |
| GET | `/profil` | Data profil |
| PUT | `/profil` | Ubah email, nomor HP, dan alamat |
| PUT | `/ganti-password` | Ganti password |
| GET | `/notifikasi` | Daftar notifikasi |
| POST | `/notifikasi/baca` | Tandai semua notifikasi sebagai dibaca |
| POST | `/notifikasi/{id}/baca` | Tandai notifikasi milik pengguna sebagai dibaca |
| GET | `/sesi` | Daftar sesi login |
| DELETE | `/sesi` atau `/sesi/{id}` | Cabut satu atau semua sesi |
| POST | `/logout` | Cabut sesi saat ini |

### Nilai

`GET /nilai` tanpa query mengembalikan periode yang tersedia dan periode terpilih. Setiap periode berisi `tahun_ajaran_id`, `tahun_ajaran`, dan daftar semester beserta status `terbuka`. Untuk mengambil data periode, gunakan `GET /nilai?ta=<tahun_ajaran_id>&semester=Ganjil|Genap`. Respons nilai berisi `terpilih`, `nilai` (nama mata pelajaran berada di field `mapel`), dan `rata_rata`. Aplikasi tidak menghitung ulang rata-rata.

### Unduhan

`GET /unduh/{jenis}` mengembalikan PDF: `bio`, `nilai`, `hadir`, `ekskul`, atau `all`. Jenis selain `bio` membutuhkan query `ta=<tahun_ajaran_id>&semester=Ganjil|Genap`.

## Bentuk error

Laravel mengembalikan pesan pada field `pesan` (dan `kode` bila tersedia); validasi mengembalikan HTTP 422 dengan `errors`. Klien mengubah timeout, kegagalan jaringan, validasi, dan error server menjadi pesan yang aman ditampilkan.