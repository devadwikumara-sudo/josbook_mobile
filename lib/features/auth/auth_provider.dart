import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'auth_service.dart';

enum AuthStatus { memeriksa, belumLogin, sudahLogin }

/// State login untuk seluruh aplikasi (dibaca oleh router dan layar).
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    ApiClient.instance.onUnauthorized = _tanganiSesiBerakhir;
  }

  final AuthService _service = AuthService();

  AuthStatus status = AuthStatus.memeriksa;
  bool sedangMemproses = false;
  String? pesanError;
  String? kodeError;
  Map<String, dynamic>? dataError;
  bool wajibGantiPassword = false;
  bool sesiBerakhir = false;
  String? namaPengguna;

  /// true saat aplikasi dibuka dan token lama masih berlaku: tampilkan layar
  /// "Sesi Masih Aktif" dulu. Login baru tidak perlu konfirmasi ini.
  bool perluKonfirmasiSesi = false;

  /// true setelah login berhasil; dipakai sekali untuk menampilkan toast
  /// "Login berhasil" di HomeScreen dan kemudian di-reset.
  bool barusLogin = false;

  /// Dipanggil sekali saat aplikasi dibuka: cek apakah masih ada sesi.
  Future<void> mulai() async {
    final token = await ApiClient.instance.tokenStorage.baca();

    if (token == null || token.isEmpty) {
      status = AuthStatus.belumLogin;
      notifyListeners();
      return;
    }

    try {
      final data = await _service.cekSesi();
      namaPengguna = (data['pengguna'] as Map?)?['nama'] as String?;
      perluKonfirmasiSesi = true;
      barusLogin = false;
      status = AuthStatus.sudahLogin;
    } on ApiException catch (e) {
      if (e.statusCode != 401) {
        pesanError = e.pesan;
      }
      status = AuthStatus.belumLogin;
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    sedangMemproses = true;
    pesanError = null;
    sesiBerakhir = false;
    kodeError = null;
    dataError = null;
    notifyListeners();

    try {
      final data = await _service.login(username.trim(), password);
      wajibGantiPassword = data['wajib_ganti_password'] == true;
      namaPengguna = (data['pengguna'] as Map?)?['nama'] as String?;
      perluKonfirmasiSesi = false;
      barusLogin = true;
      status = AuthStatus.sudahLogin;
      return true;
    } on ApiException catch (e) {
      _simpanError(e);
      return false;
    } finally {
      sedangMemproses = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> daftar({
    required String nama,
    required String nisn,
    required String email,
    required String password,
  }) async {
    sedangMemproses = true;
    pesanError = null;
    sesiBerakhir = false;
    kodeError = null;
    dataError = null;
    notifyListeners();

    try {
      return await _service.daftar(
        nama: nama,
        nisn: nisn,
        email: email,
        password: password,
      );
    } on ApiException catch (e) {
      _simpanError(e);
      return null;
    } finally {
      sedangMemproses = false;
      notifyListeners();
    }
  }

  Future<bool> lupaPassword({
    required String email,
  }) async {
    sedangMemproses = true;
    pesanError = null;
    sesiBerakhir = false;
    kodeError = null;
    dataError = null;
    notifyListeners();

    try {
      await _service.lupaPassword(email: email);
      return true;
    } on ApiException catch (e) {
      _simpanError(e);
      return false;
    } finally {
      sedangMemproses = false;
      notifyListeners();
    }
  }

  void _simpanError(ApiException error) {
    pesanError = error.pesan;
    kodeError = error.kode;
    dataError = error.data;
  }

  Future<void> logout() async {
    await _service.logout();
    status = AuthStatus.belumLogin;
    sesiBerakhir = false;
    perluKonfirmasiSesi = false;
    barusLogin = false;
    wajibGantiPassword = false;
    pesanError = null;
    notifyListeners();
  }

  /// Layar "Logout dari semua perangkat?" -> DELETE /sesi.
  Future<void> logoutSemua() async {
    await _service.logoutSemua();
    status = AuthStatus.belumLogin;
    sesiBerakhir = false;
    perluKonfirmasiSesi = false;
    barusLogin = false;
    wajibGantiPassword = false;
    pesanError = null;
    notifyListeners();
  }

  /// Tombol "Lanjutkan" di layar "Sesi Masih Aktif".
  void lanjutkanSesi() {
    perluKonfirmasiSesi = false;
    notifyListeners();
  }

  /// Dipanggil setelah Ganti Password berhasil (banner wajib-ganti hilang).
  void tandaiPasswordSudahDiganti() {
    if (wajibGantiPassword) {
      wajibGantiPassword = false;
      notifyListeners();
    }
  }

  /// Dipanggil setelah HomeScreen menampilkan toast login.
  void tandaiToastLoginSelesai() {
    if (barusLogin) {
      barusLogin = false;
      notifyListeners();
    }
  }

  void hapusError() {
    if (pesanError != null ||
        kodeError != null ||
        dataError != null ||
        sesiBerakhir) {
      pesanError = null;
      kodeError = null;
      dataError = null;
      sesiBerakhir = false;
      notifyListeners();
    }
  }

  Future<void> _tanganiSesiBerakhir() async {
    status = AuthStatus.belumLogin;
    sedangMemproses = false;
    perluKonfirmasiSesi = false;
    barusLogin = false;
    wajibGantiPassword = false;
    namaPengguna = null;
    pesanError = 'Sesi berakhir, silakan masuk lagi';
    kodeError = null;
    dataError = null;
    sesiBerakhir = true;
    notifyListeners();
  }
}
