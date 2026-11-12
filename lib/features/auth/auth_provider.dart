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
  String? kodeError;
  Map<String, dynamic>? dataError;
  int? otpSisaDetik;
  int? otpSisaPercobaan;
  bool wajibGantiPassword = false;
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
      if (e.statusCode == 401) {
        await ApiClient.instance.tokenStorage.hapus();
      } else {
        pesanError = e.pesan;
      }
      status = AuthStatus.belumLogin;
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    sedangMemproses = true;
    pesanError = null;
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

  Future<bool> verifikasiOtp({
    required String email,
    required String tujuan,
    required String kode,
  }) async {
    sedangMemproses = true;
    pesanError = null;
    kodeError = null;
    dataError = null;
    otpSisaPercobaan = null;
    notifyListeners();

    try {
      await _service.verifikasiOtp(email: email, tujuan: tujuan, kode: kode);
      return true;
    } on ApiException catch (e) {
      _simpanError(e);
      otpSisaPercobaan = _angka(e.data?['sisa_percobaan']);
      return false;
    } finally {
      sedangMemproses = false;
      notifyListeners();
    }
  }

  Future<bool> kirimUlangOtp({
    required String email,
    required String tujuan,
  }) async {
    sedangMemproses = true;
    pesanError = null;
    kodeError = null;
    dataError = null;
    otpSisaDetik = null;
    notifyListeners();

    try {
      final data = await _service.kirimUlangOtp(email: email, tujuan: tujuan);
      otpSisaDetik = _angka(data['jeda_kirim_ulang_detik']) ?? 60;
      return true;
    } on ApiException catch (e) {
      _simpanError(e);
      otpSisaDetik = _angka(e.data?['sisa_detik']);
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

  int? _angka(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

  Future<void> logout() async {
    await _service.logout();
    status = AuthStatus.belumLogin;
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
        otpSisaPercobaan != null) {
      pesanError = null;
      kodeError = null;
      dataError = null;
      otpSisaPercobaan = null;
      notifyListeners();
    }
  }

  void _sesiBerakhir() {
    ApiClient.instance.tokenStorage.hapus();
    if (status != AuthStatus.belumLogin) {
      status = AuthStatus.belumLogin;
      perluKonfirmasiSesi = false;
      barusLogin = false;
      pesanError = 'Sesi Anda telah berakhir. Silakan login kembali.';
      notifyListeners();
    }
  }
}
