import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'auth_service.dart';

enum AuthStatus { memeriksa, belumLogin, sudahLogin }

/// State login untuk seluruh aplikasi (dibaca oleh router dan layar).
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    ApiClient.instance.onUnauthorized = _sesiBerakhir;
  }

  final AuthService _service = AuthService();

  AuthStatus status = AuthStatus.memeriksa;
  bool sedangMemproses = false;
  String? pesanError;
  bool wajibGantiPassword = false;
  String? namaPengguna;

  /// Dipanggil sekali saat aplikasi dibuka: cek apakah masih ada sesi.
  Future<void> mulai() async {
    try {
      final token = await ApiClient.instance.tokenStorage.baca();

      if (token == null || token.isEmpty) {
        status = AuthStatus.belumLogin;
        notifyListeners();
        return;
      }

      final data = await _service.cekSesi();
      namaPengguna = (data['pengguna'] as Map?)?['nama'] as String?;
      perluKonfirmasiSesi = true;
      status = AuthStatus.sudahLogin;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await ApiClient.instance.tokenStorage.hapus();
      } else {
        pesanError = e.pesan;
      }
      status = AuthStatus.belumLogin;
    } catch (_) {
      // Error tak terduga: jangan biarkan splash menahan selamanya.
      status = AuthStatus.belumLogin;
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    sedangMemproses = true;
    pesanError = null;
    notifyListeners();

    try {
      final data = await _service.login(username.trim(), password);
      wajibGantiPassword = data['wajib_ganti_password'] == true;
      namaPengguna = (data['pengguna'] as Map?)?['nama'] as String?;
      status = AuthStatus.sudahLogin;
      return true;
    } on ApiException catch (e) {
      pesanError = e.pesan;
      return false;
    } finally {
      sedangMemproses = false;
      notifyListeners();
    }
  }

  /// Mendaftarkan akun baru. Mengembalikan true bila berhasil.
  /// Setelah berhasil, pengguna diarahkan ke layar Login (tidak otomatis
  /// masuk), jadi [status] sengaja tidak diubah di sini.
  Future<bool> daftar({
    required String nama,
    required String nisn,
    required String email,
    required String password,
  }) async {
    sedangMemproses = true;
    pesanError = null;
    notifyListeners();

    try {
      await _service.daftar(
        nama: nama.trim(),
        nisn: nisn.trim(),
        email: email.trim(),
        password: password,
      );
      return true;
    } on ApiException catch (e) {
      pesanError = e.pesan;
      return false;
    } catch (_) {
      pesanError = 'Pendaftaran gagal. Periksa koneksi lalu coba lagi.';
      return false;
    } finally {
      sedangMemproses = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    status = AuthStatus.belumLogin;
    perluKonfirmasiSesi = false;
    wajibGantiPassword = false;
    pesanError = null;
    notifyListeners();
  }

  /// Layar "Logout dari semua perangkat?" -> DELETE /sesi.
  Future<void> logoutSemua() async {
    await _service.logoutSemua();
    status = AuthStatus.belumLogin;
    perluKonfirmasiSesi = false;
    wajibGantiPassword = false;
    pesanError = null;
    barusLogin = false;
    notifyListeners();
  }

  void hapusError() {
    if (pesanError != null) {
      pesanError = null;
      notifyListeners();
    }
  }

  void _sesiBerakhir() {
    ApiClient.instance.tokenStorage.hapus();
    if (status != AuthStatus.belumLogin) {
      status = AuthStatus.belumLogin;
      perluKonfirmasiSesi = false;
      pesanError = 'Sesi Anda telah berakhir. Silakan login kembali.';
      notifyListeners();
    }
  }
}