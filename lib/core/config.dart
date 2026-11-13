import 'package:flutter/foundation.dart';

/// Alamat API Laravel.
///
/// Build debug memakai emulator Android secara default. Semua build lain wajib
/// menerima API_BASE_URL lewat --dart-define; build release hanya menerima HTTPS.
class AppConfig {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _debugBaseUrl = 'http://10.0.2.2:8000/api/v1';

  static String get baseUrl {
    final String configured = _apiBaseUrl.trim();
    if (configured.isNotEmpty) return configured;
    return kDebugMode ? _debugBaseUrl : '';
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
