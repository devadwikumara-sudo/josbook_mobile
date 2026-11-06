import 'package:flutter/foundation.dart' show kDebugMode;

import '../../core/api_client.dart';
import 'home_data.dart';

/// Sama seperti AuthService: data contoh hanya aktif di mode debug dan bila
/// dijalankan dengan  flutter run --dart-define=MOCK_AUTH=true
const bool _pakaiMock = kDebugMode && bool.fromEnvironment('MOCK_AUTH');

/// Panggilan API untuk layar Home. Tidak menyimpan state.
class HomeService {
  /// GET /home — endpoint yang sudah ada di Laravel.
  Future<HomeData> muat() async {
    if (_pakaiMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return HomeData.dariJson(_dataMock());
    }

    final res = await ApiClient.instance.get('/home');
    return HomeData.dariJson(Map<String, dynamic>.from(res['data'] as Map));
  }

  Map<String, dynamic> _dataMock() {
    String lalu(Duration d) =>
        DateTime.now().toUtc().subtract(d).toIso8601String();

    return {
      'nama': 'Indra Kusuma',
      'nisn': '0098202509',
      'kelas': 'X-1',
      'status': 'Aktif',
      'tahun_ajaran': '2025/2026',
      'semester': 'Ganjil',
      'sekolah': 'SMA NEGERI 1 REJOSO',
      'ada_notifikasi_baru': true,
      'aktivitas': [
        {
          'judul': 'PDF Bodata berhasil di unduh',
          'jenis': 'info',
          'waktu': lalu(const Duration(minutes: 20)),
        },
        {
          'judul': 'Nilai Matematika diperbarui',
          'jenis': 'info',
          'waktu': lalu(const Duration(days: 1)),
        },
        {
          'judul': 'Profil berhasil diperbarui',
          'jenis': 'peringatan',
          'waktu': lalu(const Duration(days: 12)),
        },
      ],
    };
  }
}