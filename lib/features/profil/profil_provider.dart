import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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
  bool sedangMengubahFoto = false;
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
    } catch (e) {
      error = e is ApiException
          ? e.pesan
          : 'Terjadi kesalahan saat memuat profil. Coba lagi.';
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
    data = await _service.simpan(
      email: email,
      nomorHp: nomorHp,
      alamat: alamat,
    );
    notifyListeners();
  }

  /// Pilih foto dari galeri lalu simpan ke server.
  Future<bool> pilihFoto() async {
    if (sedangMengubahFoto) return false;

    sedangMengubahFoto = true;
    notifyListeners();
    try {
      final XFile? pilihan = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pilihan == null) return false;

      final Uint8List bytes = await pilihan.readAsBytes();
      if (bytes.isEmpty) {
        throw const ApiException('File foto kosong. Pilih foto lain.');
      }
      if (bytes.length > 2 * 1024 * 1024) {
        throw const ApiException('Ukuran foto maksimal 2 MB. Pilih foto lain.');
      }

      await _service.simpanFoto(bytes: bytes, namaFile: pilihan.name);
      foto = bytes;
      data = data?.copyWith(adaFoto: true);
      return true;
    } finally {
      sedangMengubahFoto = false;
      notifyListeners();
    }
  }

  Future<void> gantiPassword({
    required String lama,
    required String baru,
    required String konfirmasi,
  }) => _service.gantiPassword(lama: lama, baru: baru, konfirmasi: konfirmasi);

  /// Dipanggil saat logout supaya data akun lama tidak tampil di akun berikutnya.
  /// Sengaja tanpa notifyListeners (dipanggil dari proses update provider).
  void kosongkan() {
    data = null;
    foto = null;
    error = null;
    memuat = false;
  }
}
