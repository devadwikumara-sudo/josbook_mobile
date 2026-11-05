import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Menyimpan token login di penyimpanan aman perangkat.
class TokenStorage {
  static const String _kunci = 'josbook_token';
  final FlutterSecureStorage _penyimpanan = const FlutterSecureStorage();

  Future<String?> baca() => _penyimpanan.read(key: _kunci);

  Future<void> simpan(String token) =>
      _penyimpanan.write(key: _kunci, value: token);

  Future<void> hapus() => _penyimpanan.delete(key: _kunci);
}