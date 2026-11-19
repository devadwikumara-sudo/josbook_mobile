import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../../core/api_client.dart';

enum JenisUnduhan {
  biodata('bio', 'Biodata'),
  nilai('nilai', 'Nilai'),
  hadir('hadir', 'Hadir'),
  ekskul('ekskul', 'Ekskul'),
  semua('all', 'Semua');

  const JenisUnduhan(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class UnduhService {
  static const Set<JenisUnduhan> _tanpaPeriode = {JenisUnduhan.biodata};

  Future<void> unduh({
    required JenisUnduhan jenis,
    String? tahunAjaran,
    int? tahunAjaranId,
    String? semester,
  }) async {
    final query = <String, dynamic>{};
    if (!_tanpaPeriode.contains(jenis)) {
      if (tahunAjaran == null || tahunAjaranId == null || semester == null) {
        throw ArgumentError(
          'Tahun ajaran dan semester wajib untuk unduhan ${jenis.label}.',
        );
      }
      query
        ..['ta'] = tahunAjaranId
        ..['semester'] = semester;
    }

    final bytes = await ApiClient.instance.getBytes(
      '/unduh/${jenis.apiValue}',
      query: query,
      accept: 'application/pdf',
    );

    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException(
        'Server tidak mengirim dokumen PDF yang valid.',
      );
    }

    final namaFile = _namaFile(jenis, tahunAjaran, semester);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType: 'application/pdf',
            name: namaFile,
          ),
        ],
        fileNameOverrides: [namaFile],
        subject: 'Unduhan ${jenis.label} JosBook',
      ),
    );
  }

  String _namaFile(JenisUnduhan jenis, String? tahunAjaran, String? semester) {
    final periode = tahunAjaran == null || semester == null
        ? ''
        : '-${tahunAjaran.replaceAll('/', '-')}-${semester.toLowerCase()}';
    return 'josbook-${jenis.apiValue}$periode.pdf';
  }
}
