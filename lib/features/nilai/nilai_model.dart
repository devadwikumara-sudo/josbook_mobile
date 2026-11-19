class NilaiPeriode {
  const NilaiPeriode({
    required this.tahunAjaran,
    required this.semester,
    this.tahunAjaranId,
    this.terpilih = false,
  });

  final String tahunAjaran;
  final String semester;
  final int? tahunAjaranId;
  final bool terpilih;
}

class NilaiMapel {
  const NilaiMapel({required this.nama, required this.nilai});

  final String nama;
  final num? nilai;

  factory NilaiMapel.dariJson(Map<String, dynamic> json) {
    final nama = json['nama'];
    final nilai = json['nilai'];
    if (nama is! String ||
        nama.trim().isEmpty ||
        (nilai != null && nilai is! num)) {
      throw const FormatException(
        'Data mata pelajaran dari server tidak valid.',
      );
    }

    return NilaiMapel(nama: nama, nilai: nilai as num?);
  }
}

class NilaiData {
  const NilaiData({
    required this.tahunAjaran,
    required this.semester,
    required this.mapel,
    required this.rataRata,
  });

  final String tahunAjaran;
  final String semester;
  final List<NilaiMapel> mapel;
  final num? rataRata;

  factory NilaiData.dariJson(Map<String, dynamic> json) {
    final tahunAjaran = json['tahun_ajaran'];
    final semester = json['semester'];
    final mapel = json['mapel'];
    final rataRata = json['rata_rata'];
    if (tahunAjaran is! String ||
        semester is! String ||
        mapel is! List ||
        (rataRata != null && rataRata is! num)) {
      throw const FormatException('Data nilai dari server tidak valid.');
    }

    return NilaiData(
      tahunAjaran: tahunAjaran,
      semester: semester,
      mapel: mapel
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Data mata pelajaran dari server tidak valid.',
              );
            }
            return NilaiMapel.dariJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false),
      rataRata: rataRata as num?,
    );
  }
}
