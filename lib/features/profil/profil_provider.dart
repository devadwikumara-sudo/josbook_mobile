import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'profil_model.dart';
import 'profil_service.dart';

/// State profil yang dipakai bersama oleh semua layar Profil
/// (Profil, Data Diri, Edit Profil, Ganti Password) supaya header
/// tidak memuat ulang setiap pindah halaman.
class ProfilProvider extends ChangeNotifier {
  final ProfilService _service = ProfilService();

  ProfilData? data;
  Uint8List? foto;
  bool memuat = false;
  String? error;

  /// Muat profil bila belum ada (atau paksa dengan [paksa]).
  Future<void> muat({bool paksa = false}) async {
    if (memuat || (data != null && !paksa)) return;
    memuat = true;
    error = null;
    notifyListeners();

    try {
      data = await _service.ambil();
      if (data!.adaFoto) {
        final bytes = await _service.ambilFoto();
        foto = bytes == null ? null : Uint8List.fromList(bytes);
      }
    } on ApiException catch (e) {
      error = e.pesan;
    } finally {
      memuat = false;
      notifyListeners();
    }
  }

  /// Simpan Edit Profil. Melempar [ApiException] bila gagal (ditangkap layar).
  Future<void> simpan({
    required String email,
    required String nomorHp,
    required String alamat,
  }) async {
    data = await _service.simpan(email: email, nomorHp: nomorHp, alamat: alamat);
    notifyListeners();
  }

  Future<void> gantiPassword({
    required String lama,
    required String baru,
    required String konfirmasi,
  }) =>
      _service.gantiPassword(lama: lama, baru: baru, konfirmasi: konfirmasi);

  /// Dipanggil saat logout supaya data akun lama tidak tampil di akun berikutnya.
  /// Sengaja tanpa notifyListeners (dipanggil dari proses update provider).
  void kosongkan() {
    data = null;
    foto = null;
    error = null;
    memuat = false;
  }
}
