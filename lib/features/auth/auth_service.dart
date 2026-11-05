import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import '../../core/api_client.dart';

/// Panggilan API untuk autentikasi. Tidak menyimpan state.
class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// Nama platform untuk layar "Sesi Aktif" (aman dipakai di Android, iOS, dan Chrome).
  String get _namaPlatform =>
      kIsWeb ? 'Web' : defaultTargetPlatform.name;

  /// POST /login — menyimpan token jika berhasil, lalu mengembalikan `data`.
  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _api.post('/login', data: {
      'username': username,
      'password': password,
      'nama_perangkat': 'Aplikasi JosBook ($_namaPlatform)',
    });

    final data = Map<String, dynamic>.from(res['data'] as Map);
    await _api.tokenStorage.simpan(data['token'] as String);
    return data;
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
}