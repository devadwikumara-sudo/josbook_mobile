import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;

import '../../core/api_client.dart';

/// Mode data contoh (mock) untuk dipakai selama endpoint Laravel belum jadi.
/// Hanya aktif di mode debug DAN bila dijalankan dengan:
///   flutter run --dart-define=MOCK_AUTH=true
/// Tanpa flag itu, aplikasi memanggil API Laravel yang sebenarnya.
const bool _pakaiMock =
    kDebugMode && bool.fromEnvironment('MOCK_AUTH', defaultValue: false);

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
    final Map<String, dynamic> data = _pakaiMock
        ? await _loginMock(username, password)
        : await _loginServer(username, password);

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

  /// POST /daftar — mendaftarkan akun siswa dan mengirim kode OTP email.
  Future<Map<String, dynamic>> daftar({
    required String nama,
    required String nisn,
    required String email,
    required String password,
  }) async {
    if (_pakaiMock) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return {
        'email': _samarkanEmail(email),
        'berlaku_menit': 10,
        'jeda_kirim_ulang_detik': 60,
      };
    }

    final res = await _api.post(
      '/daftar',
      data: {'nama': nama, 'nisn': nisn, 'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /lupa-password — mulai proses reset password dengan email.
  Future<Map<String, dynamic>> lupaPassword({required String email}) async {
    if (_pakaiMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return {
        'email': _samarkanEmail(email),
        'berlaku_menit': 10,
        'jeda_kirim_ulang_detik': 60,
      };
    }

    final res = await _api.post('/lupa-password', data: {'email': email});
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /verifikasi-otp — mengaktifkan akun setelah kode email benar.
  Future<Map<String, dynamic>> verifikasiOtp({
    required String email,
    required String tujuan,
    required String kode,
  }) async {
    if (_pakaiMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (kode != '123456') {
        throw ApiException(
          'Kode verifikasi tidak valid atau sudah kedaluwarsa. Silakan kirim ulang kode.',
          kode: 'otp_salah',
          statusCode: 422,
        );
      }
      if (tujuan == 'lupa_password') {
        return {'reset_token': 'reset-token-mock'};
      }
      return {'nama': 'Siswa Contoh', 'nisn': '0098202509'};
    }

    final res = await _api.post(
      '/verifikasi-otp',
      data: {'email': email, 'tujuan': tujuan, 'kode': kode},
    );
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /reset-password — menyimpan password baru setelah token valid.
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String password,
  }) async {
    if (_pakaiMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return {'status': 'berhasil'};
    }

    final res = await _api.post(
      '/reset-password',
      data: {'email': email, 'reset_token': resetToken, 'password': password},
    );
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /kirim-ulang-otp — meminta kode baru sesuai jeda server.
  Future<Map<String, dynamic>> kirimUlangOtp({
    required String email,
    required String tujuan,
  }) async {
    if (_pakaiMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return {
        'email': _samarkanEmail(email),
        'berlaku_menit': 10,
        'jeda_kirim_ulang_detik': 60,
      };
    }

    final res = await _api.post(
      '/kirim-ulang-otp',
      data: {'email': email, 'tujuan': tujuan},
    );
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// GET /sesi — memeriksa token yang tersimpan masih berlaku.
  Future<Map<String, dynamic>> cekSesi() async {
    if (_pakaiMock) return _dataSiswaMock();

    final res = await _api.get('/sesi');
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  /// POST /logout — kegagalan jaringan diabaikan, token lokal tetap dihapus.
  Future<void> logout() async {
    if (!_pakaiMock) {
      try {
        await _api.post('/logout');
      } on ApiException {
        // diabaikan
      }
    }
    await _api.tokenStorage.hapus();
  }

  /// DELETE /sesi — keluar dari SEMUA perangkat, lalu hapus token lokal.
  Future<void> logoutSemua() async {
    if (!_pakaiMock) {
      try {
        await _api.delete('/sesi');
      } on ApiException {
        // Jaringan/token sudah tidak valid: tetap hapus token lokal.
      }
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

  String _samarkanEmail(String email) {
    final int pemisah = email.indexOf('@');
    if (pemisah <= 0) return email;
    final String nama = email.substring(0, pemisah);
    final String bagianNama = nama.length <= 2
        ? nama
        : '${nama.substring(0, 2)}****';
    return '$bagianNama${email.substring(pemisah)}';
  }

  // ---------------------------------------------------------------- MOCK ---

  Map<String, dynamic> _dataSiswaMock() => {
    'token': 'token-mock',
    'wajib_ganti_password': false,
    'pengguna': {'nama': 'Indra Kusuma', 'peran': 'siswa'},
  };

  /// Akun contoh: siswa 0098202509 / 12345678, guru guru1 / 12345678.
  Future<Map<String, dynamic>> _loginMock(
    String username,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (password != '12345678') {
      throw ApiException(
        'Username atau kata sandi yang dimasukkan tidak sesuai.',
        kode: 'login_gagal',
        statusCode: 401,
      );
    }
    if (username == '0098202509') return _dataSiswaMock();
    if (username == 'guru1') {
      return {
        'token': 'token-mock',
        'wajib_ganti_password': false,
        'pengguna': {'nama': 'Guru Contoh', 'peran': 'guru'},
      };
    }

    throw ApiException(
      'Username atau kata sandi yang dimasukkan tidak sesuai.',
      kode: 'login_gagal',
      statusCode: 401,
    );
  }
}
