import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/core/api_client.dart';
import 'package:josbook_mobile/core/token_storage.dart';
import 'package:josbook_mobile/features/nilai/nilai_service.dart';

void main() {
  test('uses Laravel period IDs and decodes the API value shape', () async {
    final adapter = _NilaiAdapter();
    final api = ApiClient.test(
      dio: Dio(BaseOptions(baseUrl: 'https://josbook.test/api/v1'))
        ..httpClientAdapter = adapter,
      tokenStorage: _MemoryTokenStorage(),
    );
    final service = HttpNilaiService(api: api);

    final periode = await service.ambilPeriode();
    expect(periode, hasLength(4));
    expect(
      periode.where(
        (item) => item.tahunAjaran == '2025/2026' && item.semester == 'Genap',
      ),
      isNotEmpty,
    );
    final terpilih = periode.singleWhere(
      (item) => item.tahunAjaran == '2025/2026' && item.semester == 'Ganjil',
    );
    expect(terpilih.tahunAjaranId, 6);
    expect(terpilih.terpilih, isTrue);

    final nilai = await service.ambilNilai(terpilih);
    expect(adapter.requests.last.path, '/nilai');
    expect(adapter.requests.last.queryParameters, {
      'ta': 6,
      'semester': 'Ganjil',
    });
    expect(nilai.tahunAjaran, '2025/2026');
    expect(nilai.mapel.single.nama, 'Matematika');
    expect(nilai.mapel.single.nilai, 88);
    expect(nilai.rataRata, 88);
  });
}

class _NilaiAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final bool requestPeriode = options.queryParameters.isEmpty;
    final Object body = requestPeriode
        ? {
            'data': {
              'periode': [
                {
                  'tahun_ajaran_id': 5,
                  'tahun_ajaran': '2024/2025',
                  'semester': [
                    {'nama': 'Ganjil', 'terbuka': true},
                    {'nama': 'Genap', 'terbuka': true},
                  ],
                },
                {
                  'tahun_ajaran_id': 6,
                  'tahun_ajaran': '2025/2026',
                  'semester': [
                    {'nama': 'Ganjil', 'terbuka': true},
                    {'nama': 'Genap', 'terbuka': false},
                  ],
                },
              ],
              'terpilih': {
                'tahun_ajaran_id': 6,
                'tahun_ajaran': '2025/2026',
                'semester': 'Ganjil',
              },
            },
          }
        : {
            'data': {
              'terpilih': {
                'tahun_ajaran_id': 6,
                'tahun_ajaran': '2025/2026',
                'semester': 'Ganjil',
              },
              'nilai': [
                {'mapel': 'Matematika', 'nilai': 88.0},
              ],
              'rata_rata': 88.0,
            },
          };

    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemoryTokenStorage extends TokenStorage {
  @override
  Future<String?> baca() async => 'token-uji';

  @override
  Future<void> simpan(String token) async {}

  @override
  Future<void> hapus() async {}
}
