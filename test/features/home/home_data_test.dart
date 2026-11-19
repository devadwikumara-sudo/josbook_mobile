import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/features/home/home_data.dart';

void main() {
  test('parses Laravel home activity and unread notification fields', () {
    final data = HomeData.dariJson({
      'nama': 'Siswa',
      'nisn': '0012345678',
      'kelas': 'X-1',
      'status': 'Aktif',
      'tahun_ajaran': '2025/2026',
      'semester': 'Ganjil',
      'belum_dibaca': 2,
      'aktivitas_terbaru': [
        {
          'judul': 'Nilai diperbarui',
          'jenis': 'info',
          'created_at': '2026-11-19T02:00:00Z',
        },
      ],
    });

    expect(data.adaNotifikasiBaru, isTrue);
    expect(data.aktivitas.single.judul, 'Nilai diperbarui');
    expect(data.aktivitas.single.waktu, isNotEmpty);
  });
}
