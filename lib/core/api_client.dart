import 'package:dio/dio.dart';

import 'config.dart';
import 'token_storage.dart';

/// Kesalahan dari API dalam bentuk yang siap ditampilkan ke pengguna.
class ApiException implements Exception {
  final String pesan;
  final String? kode; // contoh: login_gagal, belum_verifikasi, register_gagal
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.pesan, {this.kode, this.statusCode, this.data});

  @override
  String toString() => pesan;
}

/// Satu pintu untuk semua panggilan ke Laravel.
/// Otomatis menambah header Accept JSON dan Authorization Bearer.
class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.baca();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio dio;
  final TokenStorage tokenStorage = TokenStorage();

  /// Dipanggil saat server menjawab 401 untuk request yang membawa token
  /// (token dicabut / kedaluwarsa). Dipakai untuk memaksa kembali ke login.
  void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _jalankan(() => dio.get(path, queryParameters: query));

  Future<List<int>> getBytes(
    String path, {
    Map<String, dynamic>? query,
    String? accept,
  }) async {
    try {
      final response = await dio.get<List<int>>(
        path,
        queryParameters: query,
        options: Options(
          responseType: ResponseType.bytes,
          headers: accept == null ? null : {'Accept': accept},
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('File yang diterima dari server kosong.');
      }
      return bytes;
    } on DioException catch (error) {
      throw _ubah(error);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) =>
      _jalankan(() => dio.post(path, data: data));

  Future<Map<String, dynamic>> put(String path, {Object? data}) =>
      _jalankan(() => dio.put(path, data: data));

  Future<Map<String, dynamic>> delete(String path) =>
      _jalankan(() => dio.delete(path));

  Future<Map<String, dynamic>> _jalankan(
    Future<Response<dynamic>> Function() aksi,
  ) async {
    try {
      final res = await aksi();
      final isi = res.data;
      return isi is Map<String, dynamic> ? isi : <String, dynamic>{};
    } on DioException catch (e) {
      throw _ubah(e);
    }
  }

  ApiException _ubah(DioException e) {
    final res = e.response;

    if (res == null) {
      return ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }

    final isi = res.data;
    String pesan = 'Terjadi kesalahan (${res.statusCode}).';
    String? kode;
    Map<String, dynamic>? data;

    if (isi is Map) {
      kode = isi['kode']?.toString();
      if (isi['data'] is Map) {
        data = Map<String, dynamic>.from(isi['data'] as Map);
      }

      if (isi['pesan'] != null) {
        pesan = isi['pesan'].toString();
      } else if (isi['errors'] is Map && (isi['errors'] as Map).isNotEmpty) {
        // Galat validasi Laravel: ambil pesan pertama
        final pertama = (isi['errors'] as Map).values.first;
        pesan = pertama is List && pertama.isNotEmpty
            ? pertama.first.toString()
            : pertama.toString();
      } else if (isi['message'] != null) {
        pesan = isi['message'].toString();
      }
    }

    if (res.statusCode == 401 &&
        e.requestOptions.headers.containsKey('Authorization')) {
      onUnauthorized?.call();
    }

    return ApiException(
      pesan,
      kode: kode,
      statusCode: res.statusCode,
      data: data,
    );
  }
}
