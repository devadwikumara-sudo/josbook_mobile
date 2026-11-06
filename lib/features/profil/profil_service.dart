import '../../core/api_client.dart';
import 'profil_model.dart';

/// Panggilan API untuk layar Profil. Tidak menyimpan state.
class ProfilService {
  final ApiClient _api = ApiClient.instance;

  /// GET /profil
  Future<ProfilData> ambil() async {
    final res = await _api.get('/profil');
    return ProfilData.dariJson(Map<String, dynamic>.from(res['data'] as Map));
  }

  /// PUT /profil — siswa hanya boleh mengubah email, nomor HP, dan alamat.
  Future<ProfilData> simpan({
    required String email,
    required String nomorHp,
    required String alamat,
  }) async {
    final res = await _api.put('/profil', data: {
      'email': email.trim(),
      'nomor_hp': nomorHp.trim().isEmpty ? null : nomorHp.trim(),
      'alamat': alamat.trim().isEmpty ? null : alamat.trim(),
    });
    return ProfilData.dariJson(Map<String, dynamic>.from(res['data'] as Map));
  }

  /// PUT /ganti-password
  Future<void> gantiPassword({
    required String lama,
    required String baru,
    required String konfirmasi,
  }) async {
    await _api.put('/ganti-password', data: {
      'password_lama': lama,
      'password_baru': baru,
      'password_baru_confirmation': konfirmasi,
    });
  }

  /// GET /profil/foto — kembalikan null bila belum ada foto / gagal diambil.
  Future<List<int>?> ambilFoto() async {
    try {
      return await _api.getBytes('/profil/foto', accept: 'image/*');
    } on ApiException {
      return null;
    } on FormatException {
      return null;
    }
  }
}
