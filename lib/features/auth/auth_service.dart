import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import '../../core/api_client.dart';

const String _pesanBukanSiswa =
    'Aplikasi ini khusus untuk siswa. Silakan gunakan website JosBook.';

/// Panggilan API untuk autentikasi. Tidak menyimpan state.
class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// Nama platform untuk layar "Sesi Aktif" (aman dipakai di Android, iOS, dan Chrome).
  String get _namaPlatform => kIsWeb ? 'Web' : defaultTargetPlatform.name;

  /// POST /login — menyimpan token jika berhasil, lalu mengembalikan `data`.
  /// Akun yang perannya bukan siswa ditolak (sesi di server langsung dicabut).
  Future<Map<String, dynamic>> login(String username, String password) async {
    final Map<String, dynamic> data = await _loginServer(username, password);

    final String token = data['token'] as String;

    if (!_apakahSiswa(data)) {
      await _api.tokenStorage.simpan(token);
      await logout(); // cabut token di server, lalu hapus token lokal
      throw ApiException(_pesanBukanSiswa, kode: 'bukan_siswa');
    }

    await _api.tokenStorage.simpan(token);
    _api.tandaiSesiAktif();
    return data;
  }

  /// POST /daftar — mendaftarkan dan langsung mengaktifkan akun siswa yang cocok.
  Future<Map<String, dynamic>> daftar({
    required String nama,
    required String nisn,
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      '/daftar',
      data: {'nama': nama, 'nisn': nisn, 'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /lupa-password — meminta tautan reset kata sandi melalui email.
  Future<Map<String, dynamic>> lupaPassword({required String email}) async {
    final res = await _api.post('/lupa-password', data: {'email': email});
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// GET /sesi — memeriksa token yang tersimpan masih berlaku.
  Future<Map<String, dynamic>> cekSesi() async {
    final res = await _api.get('/sesi');
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /logout — kegagalan jaringan diabaikan, token lokal tetap dihapus.
  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } on ApiException {
      // diabaikan
    }
    await _api.tokenStorage.hapus();
  }

  /// DELETE /sesi — keluar dari SEMUA perangkat, lalu hapus token lokal.
  Future<void> logoutSemua() async {
    try {
      await _api.delete('/sesi');
    } on ApiException {
      // Jaringan/token sudah tidak valid: tetap hapus token lokal.
    }
    await _api.tokenStorage.hapus();
  }

  Future<Map<String, dynamic>> _loginServer(
    String username,
    String password,
  ) async {
    final res = await _api.post(
      '/login',
      data: {
        'username': username,
        'password': password,
        'nama_perangkat': 'Aplikasi JosBook ($_namaPlatform)',
      },
    );
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// Bila server tidak mengirim `pengguna.peran`, dianggap siswa
  /// (server tetap yang berwenang menolak peran lain).
  bool _apakahSiswa(Map<String, dynamic> data) {
    final Object? peran = (data['pengguna'] as Map?)?['peran'];
    return peran == null || peran == 'siswa';
  }
}
