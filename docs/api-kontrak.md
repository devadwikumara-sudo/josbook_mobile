# Kontrak API Mobile JosBook

Mobile memakai API Laravel pada prefix `/api/v1`; API dan website menggunakan database `josbook` yang sama. Semua respons dan request memakai JSON kecuali unduhan dokumen PDF.

## Konfigurasi koneksi

- Emulator Android debug bawaan: `http://10.0.2.2:8000/api/v1`; Flutter Web pada Laragon: `http://josbook_web.test/api/v1`; simulator iOS debug: `http://127.0.0.1:8000/api/v1`.
- Untuk alamat lain, jalankan aplikasi dengan `--dart-define=API_BASE_URL=<URL_API>`.
- `API_BASE_URL` boleh berupa alamat lengkap (`https://server/api/v1`) atau hanya alamat server (`https://server`); `/api/v1` ditambahkan otomatis bila alamat tidak memiliki jalur.
- Perangkat fisik harus memakai alamat LAN komputer backend; jangan gunakan alamat emulator `10.0.2.2`.
- CORS backend mengizinkan origin `localhost` hanya saat `APP_ENV=local`; origin produksi harus ditetapkan eksplisit melalui `CORS_ALLOWED_ORIGINS`.
- Build rilis wajib menggunakan URL HTTPS. Jangan menyimpan kredensial database di aplikasi.

## Autentikasi

Mobile tidak memakai OTP. Endpoint publik (tanpa token): `POST /login`, `/daftar`, dan `/lupa-password`. Respons sukses membungkus payload dalam `data`. Request terlindungi mengirim `Authorization: Bearer <token>` (token Sanctum dari `/login`).

| Method | Path | Body | Hasil |
|---|---|---|---|
| POST | `/login` | `username` (NISN/username/email), `password`, `nama_perangkat` | `data.token`, `data.tipe_token`, `data.wajib_ganti_password`, `data.pengguna{nama,nisn,email}`. Gagal: 401 `login_gagal`, 403 `akun_nonaktif`, 429 `terlalu_banyak` |
| POST | `/daftar` | `nama`, `nisn` (10 digit), `email`, `password` (min. 8) | 201, akun **langsung aktif**. Nama dan NISN harus cocok dengan data sekolah. `data{nama,nisn}`. Gagal: 422 `register_gagal` (data tidak cocok, NISN sudah punya akun atau dinonaktifkan administrator, email sudah dipakai) |
| POST | `/lupa-password` | `email` | Jawaban selalu sama. Bila email milik akun aktif, server mengirim **tautan** ke email; kata sandi baru dibuat di halaman web tautan tersebut (`/siswa/reset-sandi`, berlaku 60 menit, sekali pakai). `data{email(tersamar)}` |

Setelah kata sandi diganti lewat tautan, semua perangkat dikeluarkan dan siswa login ulang di aplikasi. Pada server `APP_ENV=local` dengan `APP_DEBUG=true`, respons `/lupa-password` juga memuat `data.tautan_debug` untuk pengembangan (tidak pernah muncul di produksi). Tautan memakai `APP_URL` server, jadi `APP_URL` produksi harus alamat publik yang benar.

## Data siswa (wajib login)

| Method | Path | Kegunaan |
|---|---|---|
| GET | `/home` | Ringkasan siswa dan aktivitas terbaru |
| GET | `/biodata` | Biodata siswa |
| GET | `/nilai` | Periode dan nilai siswa |
| GET | `/profil` | Data profil |
| PUT | `/profil` | Ubah email, nomor HP, dan alamat |
| PUT | `/ganti-password` | Ganti password |
| GET | `/profil/foto` | Pas foto siswa (gambar); 404 bila belum ada |
| POST | `/profil/foto` | Unggah pas foto: multipart, field `foto_file`, JPG/PNG/WEBP, maksimal 2 MB |
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

Isi PDF sama dengan cetak PDF di web (kertas F4): `bio` memuat Buku Induk (register A-I dengan pas foto); `nilai`, `hadir`, dan `ekskul` memuat laporan capaian pembelajaran (intrakurikuler, kokurikuler, ekstrakurikuler, ketidakhadiran) untuk satu periode; `all` memuat keduanya. Isinya dibatasi pada siswa yang login dan pada periode yang sudah terbuka (403 bila belum). Bagian "Kenaikan Kelas" hanya dicetak pada `all` setelah keputusannya tersimpan di server.

## Bentuk error

Laravel mengembalikan pesan pada field `pesan` (dan `kode` bila tersedia); validasi mengembalikan HTTP 422 dengan `errors`. Klien mengubah timeout, kegagalan jaringan, validasi, dan error server menjadi pesan yang aman ditampilkan.