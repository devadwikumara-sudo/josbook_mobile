# API Kontrak

Catatan: backend belum ada. Bagian Nilai adalah usulan kontrak, dipakai frontend dengan data mock sampai backend siap.

## Auth

### 1) POST /lupa-password
Memulai proses reset password.

Request body:
```json
{
  "email": "siswa@example.com"
}
```

Respons sukses:
```json
{
  "email": "s***@example.com",
  "berlaku_menit": 10,
  "jeda_kirim_ulang_detik": 60
}
```

### 2) POST /verifikasi-otp
Verifikasi kode OTP untuk tujuan tertentu.

Request body:
```json
{
  "email": "siswa@example.com",
  "tujuan": "lupa_password",
  "kode": "123456"
}
```

Respons sukses untuk lupa password:
```json
{
  "reset_token": "abc123xyz"
}
```

### 3) POST /reset-password
Mengganti password setelah OTP valid.

Request body:
```json
{
  "email": "siswa@example.com",
  "reset_token": "abc123xyz",
  "password": "newPassword123"
}
```

Respons sukses:
```json
{
  "status": "berhasil"
}
```

Catatan aplikasi: password baru tidak disimpan ke disk atau log; hanya dipertahankan sementara di memory provider sampai proses selesai.

## Nilai

### 4) GET /nilai/periode
Daftar semester yang sudah dijalani siswa, urut terbaru dulu. Semester yang belum berjalan tidak ikut.
Tanpa parameter.

Respons sukses:
```json
{
  "data": [
    {"tahun_ajaran": "2025/2026", "semester": "Ganjil"},
    {"tahun_ajaran": "2024/2025", "semester": "Genap"}
  ]
}
```

### 5) GET /nilai
Nilai mapel untuk satu periode.

Query parameter (wajib dua-duanya):
- `tahun_ajaran`, contoh `2025/2026`
- `semester`, nilai `Ganjil` atau `Genap`

Contoh: `GET /nilai?tahun_ajaran=2025/2026&semester=Ganjil`

Respons sukses:
```json
{
  "tahun_ajaran": "2025/2026",
  "semester": "Ganjil",
  "mapel": [
    {"nama": "Matematika", "nilai": 85},
    {"nama": "Bahasa Inggris", "nilai": null}
  ],
  "rata_rata": 85.0
}
```

Jika belum ada nilai untuk periode itu: `"mapel": []` dan `"rata_rata": null`.

Catatan aplikasi: nilai `null` ditampilkan "-"; `rata_rata` diambil dari API, tidak dihitung ulang di aplikasi.