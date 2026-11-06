/// Satu baris di "Aktivitas Terbaru".
class ItemAktivitas {
  const ItemAktivitas({
    required this.judul,
    required this.waktu,
    required this.peringatan,
  });

  final String judul;

  /// Sudah diformat, contoh: "Hari ini · 07:12 WIB".
  final String waktu;

  /// true bila jenisnya 'peringatan' (ikon jam oranye); selain itu ikon centang.
  final bool peringatan;

  factory ItemAktivitas.dariJson(Map<String, dynamic> j) {
    return ItemAktivitas(
      judul: _teks(j['judul'], '-'),
      waktu: formatWaktuWib((j['waktu'] ?? j['created_at'])?.toString()),
      peringatan: j['jenis']?.toString() == 'peringatan',
    );
  }
}

/// Data layar Home. Field wajib (dipakai kerangka GET /home yang sudah ada):
/// nama, nisn, kelas, status, tahun_ajaran, semester.
/// Field opsional (belum tentu dikirim server): foto_url, sekolah,
/// ada_notifikasi_baru, aktivitas.
class HomeData {
  const HomeData({
    required this.nama,
    required this.nisn,
    required this.kelas,
    required this.status,
    required this.tahunAjaran,
    required this.semester,
    required this.sekolah,
    required this.fotoUrl,
    required this.adaNotifikasiBaru,
    required this.aktivitas,
  });

  static const String sekolahBawaan = 'SMA NEGERI 1 REJOSO';

  final String nama;
  final String nisn;
  final String kelas;
  final String status;
  final String tahunAjaran;
  final String semester;
  final String sekolah;
  final String? fotoUrl;
  final bool adaNotifikasiBaru;
  final List<ItemAktivitas> aktivitas;

  factory HomeData.dariJson(Map<String, dynamic> j) {
    final Object? foto = j['foto_url'];
    final Object? daftar = j['aktivitas'];

    return HomeData(
      nama: _teks(j['nama'], '-'),
      nisn: _teks(j['nisn'], '-'),
      kelas: _teks(j['kelas'], '-'),
      status: _teks(j['status'], '-'),
      tahunAjaran: _teks(j['tahun_ajaran'], '-'),
      semester: _teks(j['semester'], '-'),
      sekolah: _teks(j['sekolah'], sekolahBawaan),
      fotoUrl: (foto == null || foto.toString().trim().isEmpty)
          ? null
          : foto.toString().trim(),
      adaNotifikasiBaru:
          j['ada_notifikasi_baru'] == true || j['ada_notifikasi_baru'] == 1,
      aktivitas: daftar is List
          ? daftar
              .whereType<Map>()
              .map((e) => ItemAktivitas.dariJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

String _teks(Object? nilai, String cadangan) {
  final String? s = nilai?.toString().trim();
  return (s == null || s.isEmpty) ? cadangan : s;
}

const List<String> _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Ubah waktu ISO dari server menjadi "Hari ini · 07:12 WIB",
/// "Kemarin · 14:32 WIB", atau "23 Sep · 09:15 WIB".
/// Waktu berakhiran Z/zona dikonversi ke WIB (UTC+7); tanpa zona dianggap WIB.
String formatWaktuWib(String? mentah) {
  if (mentah == null || mentah.isEmpty) return '';
  final DateTime? t = DateTime.tryParse(mentah);
  if (t == null) return mentah;

  final DateTime wib = t.isUtc ? t.add(const Duration(hours: 7)) : t;
  final DateTime sekarang = DateTime.now().toUtc().add(const Duration(hours: 7));

  final DateTime hariIni =
      DateTime.utc(sekarang.year, sekarang.month, sekarang.day);
  final DateTime hariItu = DateTime.utc(wib.year, wib.month, wib.day);
  final int selisih = hariIni.difference(hariItu).inDays;

  final String jam = '${wib.hour.toString().padLeft(2, '0')}:'
      '${wib.minute.toString().padLeft(2, '0')} WIB';

  if (selisih == 0) return 'Hari ini · $jam';
  if (selisih == 1) return 'Kemarin · $jam';
  return '${wib.day} ${_bulan[wib.month - 1]} · $jam';
}