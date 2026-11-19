import '../profil/profil_model.dart';

class BiodataData {
  const BiodataData({
    required this.nama,
    required this.nisn,
    this.nomorInduk,
    this.tempatLahir,
    this.tanggalLahir,
    this.agama,
    this.alamat,
    this.namaAyah,
    this.namaIbu,
    this.namaWali,
    this.sekolahAsal,
    this.tanggalDiterima,
    this.tinggiBadan,
    this.beratBadan,
  });

  final String nama;
  final String nisn;
  final String? nomorInduk;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? agama;
  final String? alamat;
  final String? namaAyah;
  final String? namaIbu;
  final String? namaWali;
  final String? sekolahAsal;
  final String? tanggalDiterima;
  final String? tinggiBadan;
  final String? beratBadan;

  factory BiodataData.dariJson(Map<String, dynamic> json) => BiodataData(
    nama: _teks(json['nama']) ?? '-',
    nisn: _teks(json['nisn']) ?? '-',
    nomorInduk: _teks(json['nomor_induk']),
    tempatLahir: _teks(json['tempat_lahir']),
    tanggalLahir: _teks(json['tanggal_lahir']),
    agama: _teks(json['agama']),
    alamat: _teks(json['alamat']),
    namaAyah: _teks(json['nama_ayah']),
    namaIbu: _teks(json['nama_ibu']),
    namaWali: _teks(json['nama_wali']),
    sekolahAsal: _teks(json['sekolah_asal']),
    tanggalDiterima: _teks(json['tanggal_diterima']),
    tinggiBadan: _angka(json['tinggi_badan_cm']),
    beratBadan: _angka(json['berat_badan_kg']),
  );

  List<MapEntry<String, String>> get baris => [
    MapEntry('Nama', nama),
    MapEntry('NISN', nisn),
    MapEntry('NIS', _tampil(nomorInduk)),
    MapEntry('TTL', _tempatTanggalLahir),
    MapEntry('Agama', _tampil(agama)),
    MapEntry('Alamat', _tampil(alamat)),
    MapEntry('Ayah', _tampil(namaAyah)),
    MapEntry('Ibu', _tampil(namaIbu)),
    MapEntry('Wali', _tampil(namaWali)),
    MapEntry('Asal sekolah', _tampil(sekolahAsal)),
    MapEntry('Tgl diterima', _tanggal(tanggalDiterima)),
    MapEntry('Tinggi / berat', _tinggiBerat),
  ];

  String get _tempatTanggalLahir {
    final tanggal = formatTanggalIndonesia(tanggalLahir);
    final bagian = [?tempatLahir, ?tanggal];
    return bagian.isEmpty ? '-' : bagian.join(', ');
  }

  String get _tinggiBerat {
    final String tinggi = tinggiBadan == null ? '' : '$tinggiBadan cm';
    final String berat = beratBadan == null ? '' : '$beratBadan kg';
    final String hasil = [
      tinggi,
      berat,
    ].where((bagian) => bagian.isNotEmpty).join(' / ');
    return hasil.isEmpty ? '-' : hasil;
  }

  static String _tampil(String? value) => value ?? '-';

  static String _tanggal(String? value) =>
      formatTanggalIndonesia(value) ?? _tampil(value);
}

String? _teks(Object? value) {
  final String? text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String? _angka(Object? value) {
  if (value is! num) return _teks(value);
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
