import 'dart:convert';

import 'package:dio/dio.dart';

import 'config.dart';
import 'token_storage.dart';

/// Satu bentuk kesalahan API yang aman ditampilkan ke pengguna.
class ApiException implements Exception {
  const ApiException(this.pesan, {this.kode, this.statusCode, this.data});

  final String pesan;
  final String? kode;
  final int? statusCode;
  final Map<String, dynamic>? data;

  @override
  String toString() => pesan;

  factory ApiException.dariDio(DioException error) {
    final response = error.response;
    if (response == null) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const ApiException('Koneksi ke server terlalu lama. Coba lagi.');
      }
      return const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.',
      );
    }

    final Map<String, dynamic>? bodyMap = _decodeBody(response.data);
    final Map<String, dynamic>? data = bodyMap?['data'] is Map
        ? Map<String, dynamic>.from(bodyMap!['data'] as Map)
        : null;
    final String? kode = bodyMap?['kode']?.toString();
    final String? pesanServer = _pesanServer(bodyMap);
    final int? statusCode = response.statusCode;

    if (statusCode == 408) {
      return ApiException(
        'Koneksi ke server terlalu lama. Coba lagi.',
        kode: kode,
        statusCode: statusCode,
        data: data,
      );
    }

    if (statusCode == 401 &&
        _tokenDariHeader(error.requestOptions.headers['Authorization']) !=
            null) {
      return ApiException(
        'Sesi berakhir, silakan masuk lagi',
        kode: kode,
        statusCode: statusCode,
        data: data,
      );
    }

    if (statusCode == 422) {
      return ApiException(
        pesanServer ?? 'Data yang dimasukkan tidak valid.',
        kode: kode,
        statusCode: statusCode,
        data: data,
      );
    }

    if (statusCode == 429) {
      final int? tunggu = _waktuTunggu(bodyMap, data, response.headers);
      final String pesan = tunggu == null
          ? (pesanServer ?? 'Terlalu banyak percobaan. Coba lagi nanti.')
          : 'Terlalu banyak percobaan. Coba lagi dalam $tunggu detik.';
      return ApiException(
        pesan,
        kode: kode,
        statusCode: statusCode,
        data: data,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        'Server sedang bermasalah. Coba lagi nanti.',
        kode: kode,
        statusCode: statusCode,
        data: data,
      );
    }

    return ApiException(
      pesanServer ?? 'Terjadi kesalahan. Coba lagi.',
      kode: kode,
      statusCode: statusCode,
      data: data,
    );
  }

  static String? _pesanServer(Map<String, dynamic>? body) {
    if (body == null) return null;
    final Object? pesan = body['pesan'] ?? body['message'];
    if (pesan is String && pesan.trim().isNotEmpty) return pesan.trim();

    final Object? errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final Object? pertama = errors.values.first;
      if (pertama is List && pertama.isNotEmpty) {
        return pertama.first.toString();
      }
      if (pertama != null) return pertama.toString();
    }
    return null;
  }

  static Map<String, dynamic>? _decodeBody(Object? body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is List<int>) {
      try {
        final Object? decoded = jsonDecode(utf8.decode(body));
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  static int? _waktuTunggu(
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Headers headers,
  ) {
    const keys = [
      'sisa_detik',
      'retry_after',
      'retry_after_seconds',
      'waktu_tunggu_detik',
    ];
    for (final source in [data, body]) {
      if (source == null) continue;
      for (final key in keys) {
        final value = source[key];
        final int? seconds = value is num
            ? value.toInt()
            : int.tryParse(value?.toString() ?? '');
        if (seconds != null && seconds > 0) return seconds;
      }
    }

    final String? retryAfter = headers.value('retry-after');
    final int? seconds = int.tryParse(retryAfter ?? '');
    if (seconds != null && seconds > 0) return seconds;
    final DateTime? batasWaktu = DateTime.tryParse(retryAfter ?? '');
    if (batasWaktu == null) return null;
    final int selisih = batasWaktu.difference(DateTime.now()).inSeconds;
    return selisih > 0 ? selisih : null;
  }

  static String? _tokenDariHeader(Object? header) {
    if (header is! String || header.trim().isEmpty) return null;
    final nilai = header.trim();
    return nilai.toLowerCase().startsWith('bearer ')
        ? nilai.substring(7).trim()
        : nilai;
  }
}

/// Satu pintu untuk semua panggilan ke Laravel.
/// Otomatis menambah header Accept JSON dan Authorization Bearer.
class ApiClient {
  ApiClient._({Dio? dio, TokenStorage? tokenStorage})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            ),
          ),
      tokenStorage = tokenStorage ?? TokenStorage() {
    _pasangInterceptor();
  }

  ApiClient.test({required Dio dio, required TokenStorage tokenStorage})
    : this._(dio: dio, tokenStorage: tokenStorage);

  static final ApiClient instance = ApiClient._();

  final Dio dio;
  final TokenStorage tokenStorage;

  Future<void> Function()? onUnauthorized;
  String? _tokenSesiBerakhir;

  void tandaiSesiAktif() {
    _tokenSesiBerakhir = null;
  }

  void _pasangInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_rutePublik(options.uri.path)) {
            final token = await tokenStorage.baca();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final token = ApiException._tokenDariHeader(
            error.requestOptions.headers['Authorization'],
          );
          if (error.response?.statusCode == 401 && token != null) {
            await _tanganiSesiBerakhir(token);
          }
          handler.next(error);
        },
      ),
    );
  }

  bool _rutePublik(String path) {
    const routes = [
      '/login',
      '/daftar',
      '/lupa-password',
      '/verifikasi-otp',
      '/reset-password',
      '/kirim-ulang-otp',
    ];
    return routes.any(path.endsWith);
  }

  Future<void> _tanganiSesiBerakhir(String tokenPermintaan) async {
    if (_tokenSesiBerakhir == tokenPermintaan) return;

    final tokenSaatIni = await tokenStorage.baca();
    if (tokenSaatIni == null || tokenSaatIni != tokenPermintaan) return;
    if (_tokenSesiBerakhir == tokenPermintaan) return;

    _tokenSesiBerakhir = tokenPermintaan;
    try {
      await tokenStorage.hapus();
    } finally {
      await onUnauthorized?.call();
    }
  }

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
      throw ApiException.dariDio(error);
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
    } on DioException catch (error) {
      throw ApiException.dariDio(error);
    }
  }
}
