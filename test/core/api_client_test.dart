import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/core/api_client.dart';
import 'package:josbook_mobile/core/token_storage.dart';

void main() {
  group('ApiException mapping', () {
    test('maps offline and timeout errors to stable user messages', () {
      final request = RequestOptions(path: '/home');

      expect(
        ApiException.dariDio(
          DioException(
            requestOptions: request,
            type: DioExceptionType.connectionError,
          ),
        ).pesan,
        'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.',
      );
      expect(
        ApiException.dariDio(
          DioException(
            requestOptions: request,
            type: DioExceptionType.receiveTimeout,
          ),
        ).pesan,
        'Koneksi ke server terlalu lama. Coba lagi.',
      );
      expect(
        _mapResponse(408, {}).pesan,
        'Koneksi ke server terlalu lama. Coba lagi.',
      );
    });

    test('maps server, validation, and rate-limit responses', () {
      expect(
        _mapResponse(500, {'message': 'private server detail'}).pesan,
        'Server sedang bermasalah. Coba lagi nanti.',
      );

      final validation = _mapResponse(422, {
        'errors': {
          'email': ['Format email tidak valid.'],
        },
      });
      expect(validation.pesan, 'Format email tidak valid.');
      expect(validation.statusCode, 422);

      final rateLimit = ApiException.dariDio(
        DioException(
          requestOptions: RequestOptions(path: '/otp'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/otp'),
            statusCode: 429,
            data: {
              'pesan': 'Terlalu banyak percobaan.',
              'data': {'sisa_detik': 30},
            },
          ),
        ),
      );
      expect(
        rateLimit.pesan,
        'Terlalu banyak percobaan. Coba lagi dalam 30 detik.',
      );
    });
  });

  test('401 clears the matching token and notifies auth only once', () async {
    final storage = _MemoryTokenStorage('token-sesi');
    final adapter = _UnauthorizedAdapter();
    final client = ApiClient.test(
      dio: Dio(BaseOptions(baseUrl: 'https://josbook.test/api'))
        ..httpClientAdapter = adapter,
      tokenStorage: storage,
    );
    var jumlah401 = 0;
    client.onUnauthorized = () async {
      jumlah401++;
    };

    await Future.wait([_request(client), _request(client)]);

    expect(storage.token, isNull);
    expect(jumlah401, 1);
    expect(adapter.jumlahPermintaan, 2);
  });
}

ApiException _mapResponse(int statusCode, Object data) {
  final request = RequestOptions(path: '/test');
  return ApiException.dariDio(
    DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: statusCode,
        data: data,
      ),
    ),
  );
}

Future<void> _request(ApiClient client) async {
  try {
    await client.get('/protected');
    fail('Request 401 seharusnya menghasilkan ApiException.');
  } on ApiException catch (error) {
    expect(error.pesan, 'Sesi berakhir, silakan masuk lagi');
  }
}

class _MemoryTokenStorage extends TokenStorage {
  _MemoryTokenStorage(this.token);

  String? token;

  @override
  Future<String?> baca() async => token;

  @override
  Future<void> hapus() async {
    token = null;
  }
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  int jumlahPermintaan = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    jumlahPermintaan++;
    await Future<void>.delayed(Duration.zero);
    return ResponseBody.fromString(
      jsonEncode({'pesan': 'token tidak valid'}),
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
