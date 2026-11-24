import 'package:flutter/foundation.dart';

/// Alamat API Laravel.
///
/// Build debug memilih alamat lokal sesuai target. Semua build lain wajib
/// menerima API_BASE_URL lewat --dart-define; build release hanya menerima HTTPS.
///
/// API_BASE_URL boleh berupa alamat lengkap (https://server/api/v1) atau hanya
/// alamat server (https://server). Jalur /api/v1 dilengkapi otomatis bila alamat
/// tidak memiliki jalur sama sekali, supaya salah ketik tidak berujung 404.
class AppConfig {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _jalurApi = '/api/v1';

  static String get _debugBaseUrl {
    if (kIsWeb) return 'http://josbook_web.test/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get baseUrl {
    final String configured = _apiBaseUrl.trim();
    if (configured.isNotEmpty) return normalisasiAlamat(configured);
    return kDebugMode ? _debugBaseUrl : '';
  }

  /// Membuang garis miring di akhir dan menambahkan /api/v1 bila alamat hanya
  /// berisi server (tanpa jalur, query, maupun fragmen). Alamat yang sudah
  /// memiliki jalur dibiarkan apa adanya.
  @visibleForTesting
  static String normalisasiAlamat(String alamat) {
    final String bersih = alamat.trim().replaceAll(RegExp(r'/+$'), '');
    final Uri? uri = Uri.tryParse(bersih);
    if (uri == null || !uri.hasAuthority || uri.hasQuery || uri.hasFragment) {
      return bersih;
    }
    return uri.path.isEmpty ? '$bersih$_jalurApi' : bersih;
  }

  static String? get configurationError {
    final String configured = _apiBaseUrl.trim();
    if (configured.isEmpty) {
      return kDebugMode
          ? null
          : 'API_BASE_URL belum diatur. '
                'Build kembali dengan alamat server HTTPS.';
    }

    final Uri? uri = Uri.tryParse(configured);
    final String scheme = uri?.scheme.toLowerCase() ?? '';
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (scheme != 'https' && scheme != 'http')) {
      return 'API_BASE_URL harus berupa alamat server HTTP atau HTTPS '
          'yang valid.';
    }
    if (kReleaseMode && scheme != 'https') {
      return 'Build rilis hanya mendukung API_BASE_URL dengan HTTPS.';
    }
    return null;
  }
}

/// Nomor WhatsApp admin sekolah untuk tombol "Chat Admin" (format 62812…, tanpa +).
/// Isi saat menjalankan/membangun aplikasi:
///   flutter run --dart-define=ADMIN_WA=6281234567890
class KontakAdmin {
  static const String whatsapp = String.fromEnvironment('ADMIN_WA');
}
