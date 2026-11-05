/// Alamat API Laravel.
///
/// Default untuk emulator Android (10.0.2.2 = komputer Anda).
/// Untuk HP asli, jalankan dengan alamat IP komputer di wifi yang sama:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
}