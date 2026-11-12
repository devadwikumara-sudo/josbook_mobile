class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.waktu,
    required this.jenis,
    required this.dibaca,
  });

  final String id;
  final String judul;
  final String deskripsi;
  final String waktu;
  final String jenis;
  final bool dibaca;

  Notifikasi tandaiDibaca() => Notifikasi(
    id: id,
    judul: judul,
    deskripsi: deskripsi,
    waktu: waktu,
    jenis: jenis,
    dibaca: true,
  );

  factory Notifikasi.dariJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? judul = json['judul'];
    final Object? deskripsi = json['deskripsi'];
    final Object? waktu = json['waktu'] ?? json['created_at'];
    final Object? jenis = json['jenis'];
    final Object? statusDibaca = json['dibaca'];

    if (id == null ||
        id.toString().trim().isEmpty ||
        judul is! String ||
        deskripsi is! String ||
        waktu == null ||
        jenis is! String ||
        (statusDibaca != null &&
            statusDibaca is! bool &&
            statusDibaca != 0 &&
            statusDibaca != 1)) {
      throw const FormatException('Data notifikasi dari server tidak valid.');
    }

    return Notifikasi(
      id: id.toString(),
      judul: judul,
      deskripsi: deskripsi,
      waktu: waktu.toString(),
      jenis: jenis,
      dibaca: statusDibaca == true || statusDibaca == 1,
    );
  }
}

class DaftarNotifikasi {
  const DaftarNotifikasi({
    required this.items,
    required this.jumlahBelumDibaca,
  });

  final List<Notifikasi> items;
  final int jumlahBelumDibaca;

  factory DaftarNotifikasi.dariJson(Map<String, dynamic> json) {
    final Object? data = json['data'];
    final Object? jumlah = json['belum_dibaca'];
    if (data is! List || (jumlah != null && jumlah is! int)) {
      throw const FormatException('Daftar notifikasi dari server tidak valid.');
    }

    final items = data
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Data notifikasi dari server tidak valid.',
            );
          }
          return Notifikasi.dariJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);

    return DaftarNotifikasi(
      items: items,
      jumlahBelumDibaca:
          (jumlah as int?) ?? items.where((item) => !item.dibaca).length,
    );
  }
}
