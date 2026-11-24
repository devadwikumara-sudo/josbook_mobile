import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/core/config.dart';

void main() {
  group('AppConfig.normalisasiAlamat', () {
    test('melengkapi alamat server tanpa jalur dengan /api/v1', () {
      expect(
        AppConfig.normalisasiAlamat('http://10.0.2.2:8000'),
        'http://10.0.2.2:8000/api/v1',
      );
      expect(
        AppConfig.normalisasiAlamat('https://sekolah.example/'),
        'https://sekolah.example/api/v1',
      );
      expect(
        AppConfig.normalisasiAlamat('  https://sekolah.example  '),
        'https://sekolah.example/api/v1',
      );
    });

    test('tidak mengubah alamat yang sudah memiliki jalur', () {
      expect(
        AppConfig.normalisasiAlamat('http://10.0.2.2:8000/api/v1'),
        'http://10.0.2.2:8000/api/v1',
      );
      expect(
        AppConfig.normalisasiAlamat('https://sekolah.example/api/v1/'),
        'https://sekolah.example/api/v1',
      );
      expect(
        AppConfig.normalisasiAlamat('https://sekolah.example/josbook/api/v1'),
        'https://sekolah.example/josbook/api/v1',
      );
    });

    test('membiarkan masukan yang bukan alamat server utuh', () {
      expect(AppConfig.normalisasiAlamat('sekolah.example'), 'sekolah.example');
      expect(
        AppConfig.normalisasiAlamat('https://sekolah.example?a=1'),
        'https://sekolah.example?a=1',
      );
    });
  });
}
