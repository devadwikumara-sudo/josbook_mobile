/// Data profil siswa dari GET /profil.
class ProfilData {
  const ProfilData({
    required this.nama,
    required this.nisn,
    this.kelas,
    this.jenisKelamin,
    this.tempatLahir,
    this.tanggalLahir,
    this.alamat,
    this.alamatJalan,
    this.email,
    this.nomorHp,
    this.adaFoto = false,
  });

  final String nama;
  final String nisn;
  final String? kelas;
  final String? jenisKelamin;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? alamat;

  /// Hanya bagian jalan (dipakai di form Edit Profil; `alamat` adalah gabungan lengkap).
  final String? alamatJalan;
  final String? email;
  final String? nomorHp;
  final bool adaFoto;

  factory ProfilData.dariJson(Map<String, dynamic> j) => ProfilData(
        nama: (j['nama'] ?? '-').toString(),
        nisn: (j['nisn'] ?? '-').toString(),
        kelas: j['kelas']?.toString(),
        jenisKelamin: j['jenis_kelamin']?.toString(),
        tempatLahir: j['tempat_lahir']?.toString(),
        tanggalLahir: j['tanggal_lahir']?.toString(),
        alamat: j['alamat']?.toString(),
        alamatJalan: j['alamat_jalan']?.toString(),
        email: j['email']?.toString(),
        nomorHp: j['nomor_hp']?.toString(),
        adaFoto: j['foto_url'] != null,
      );

  /// Teks di bawah nama pada header: "X 1 | NISN: 0061234567".
  String get subJudul => '${_ada(kelas) ? kelas : '-'} | NISN: $nisn';

  /// "Nganjuk, 12 Maret 2008" (bagian yang kosong dilewati).
  String get tempatTanggalLahir {
    final tgl = formatTanggalIndonesia(tanggalLahir);
    final bagian = <String>[];

    if (tempatLahir?.trim().isNotEmpty ?? false) {
      bagian.add(tempatLahir!.trim());
    }
    if (tgl != null) {
      bagian.add(tgl);
    }

    return bagian.isEmpty ? '-' : bagian.join(', ');
  }

  static bool _ada(String? s) => s != null && s.trim().isNotEmpty;
}

const List<String> _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// Mengubah "2008-03-12" (atau "2008-03-12T00:00:00.000000Z") menjadi "12 Maret 2008".
String? formatTanggalIndonesia(String? mentah) {
  if (mentah == null || mentah.length < 10) return null;
  final t = DateTime.tryParse(mentah.substring(0, 10));
  if (t == null) return null;
  return '${t.day} ${_bulan[t.month - 1]} ${t.year}';
}
