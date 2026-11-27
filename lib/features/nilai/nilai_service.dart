import '../../core/api_client.dart';
import 'nilai_model.dart';

abstract class NilaiService {
  Future<List<NilaiPeriode>> ambilPeriode();

  Future<NilaiData> ambilNilai(NilaiPeriode periode);
}

class HttpNilaiService implements NilaiService {
  HttpNilaiService({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  @override
  Future<List<NilaiPeriode>> ambilPeriode() async {
    final response = await _api.get('/nilai');
    final Object? data = response['data'];
    if (data is! Map || data['periode'] is! List) {
      throw const FormatException('Daftar periode dari server tidak valid.');
    }

    final Object? terpilih = data['terpilih'];
    final String? tahunTerpilih = terpilih is Map
        ? terpilih['tahun_ajaran']?.toString()
        : null;
    final String? semesterTerpilih = terpilih is Map
        ? terpilih['semester']?.toString()
        : null;
    final List<NilaiPeriode> hasil = [];

    for (final Object? item in data['periode'] as List) {
      if (item is! Map) {
        throw const FormatException('Periode nilai dari server tidak valid.');
      }
      final Map<String, dynamic> periode = Map<String, dynamic>.from(item);
      final Object? tahun = periode['tahun_ajaran'];
      final int? tahunId = _angka(periode['tahun_ajaran_id']);
      final Object? semester = periode['semester'];
      if (tahun is! String ||
          tahun.trim().isEmpty ||
          tahunId == null ||
          semester is! List) {
        throw const FormatException('Periode nilai dari server tidak valid.');
      }

      for (final Object? pilihan in semester) {
        if (pilihan is! Map) {
          throw const FormatException(
            'Semester nilai dari server tidak valid.',
          );
        }
        final Object? nama = pilihan['nama'];
        if (nama != 'Ganjil' && nama != 'Genap') {
          throw const FormatException(
            'Semester nilai dari server tidak valid.',
          );
        }
        hasil.add(
          NilaiPeriode(
            tahunAjaran: tahun,
            semester: nama as String,
            tahunAjaranId: tahunId,
            terpilih: tahun == tahunTerpilih && nama == semesterTerpilih,
          ),
        );
      }
    }
    return hasil;
  }

  @override
  Future<NilaiData> ambilNilai(NilaiPeriode periode) async {
    final int? tahunAjaranId = periode.tahunAjaranId;
    if (tahunAjaranId == null) {
      throw ArgumentError('ID tahun ajaran wajib untuk mengambil nilai.');
    }
    final response = await _api.get(
      '/nilai',
      query: {'ta': tahunAjaranId, 'semester': periode.semester},
    );
    final Object? data = response['data'];
    if (data is! Map || data['terpilih'] is! Map || data['nilai'] is! List) {
      throw const FormatException('Data nilai dari server tidak valid.');
    }

    final Map<String, dynamic> terpilih = Map<String, dynamic>.from(
      data['terpilih'] as Map,
    );
    final List<Map<String, dynamic>> mapel = [];
    for (final Object? item in data['nilai'] as List) {
      if (item is! Map || item['mapel'] is! String) {
        throw const FormatException(
          'Data mata pelajaran dari server tidak valid.',
        );
      }
      mapel.add({'nama': item['mapel'], 'nilai': item['nilai']});
    }

    return NilaiData.dariJson({
      'tahun_ajaran': terpilih['tahun_ajaran'],
      'semester': terpilih['semester'],
      'mapel': mapel,
      'rata_rata': data['rata_rata'],
    });
  }

  int? _angka(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
}
