import '../../core/api_client.dart';
import 'nilai_model.dart';

abstract class NilaiService {
  Future<List<NilaiPeriode>> ambilPeriode();

  Future<NilaiData> ambilNilai(NilaiPeriode periode);
}

class MockNilaiService implements NilaiService {
  const MockNilaiService();

  static const List<NilaiPeriode> _periode = [
    NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
    NilaiPeriode(tahunAjaran: '2024/2025', semester: 'Genap'),
  ];

  @override
  Future<List<NilaiPeriode>> ambilPeriode() async => _periode;

  @override
  Future<NilaiData> ambilNilai(NilaiPeriode periode) async {
    if (periode.tahunAjaran == '2025/2026' && periode.semester == 'Ganjil') {
      return const NilaiData(
        tahunAjaran: '2025/2026',
        semester: 'Ganjil',
        mapel: [
          NilaiMapel(nama: 'Matematika', nilai: 85),
          NilaiMapel(nama: 'Bahasa Inggris', nilai: null),
        ],
        rataRata: 85.0,
      );
    }
    if (periode.tahunAjaran == '2024/2025' && periode.semester == 'Genap') {
      return const NilaiData(
        tahunAjaran: '2024/2025',
        semester: 'Genap',
        mapel: [
          NilaiMapel(nama: 'Matematika', nilai: 78),
          NilaiMapel(nama: 'Bahasa Inggris', nilai: 82),
        ],
        rataRata: 80.0,
      );
    }

    throw ArgumentError('Periode nilai tidak tersedia di data mock.');
  }
}

class HttpNilaiService implements NilaiService {
  HttpNilaiService({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  @override
  Future<List<NilaiPeriode>> ambilPeriode() async {
    final response = await _api.get('/nilai/periode');
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('Daftar periode dari server tidak valid.');
    }

    return data
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Periode nilai dari server tidak valid.',
            );
          }
          return NilaiPeriode.dariJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  @override
  Future<NilaiData> ambilNilai(NilaiPeriode periode) async {
    final response = await _api.get(
      '/nilai',
      query: {
        'tahun_ajaran': periode.tahunAjaran,
        'semester': periode.semester,
      },
    );
    return NilaiData.dariJson(response);
  }
}
