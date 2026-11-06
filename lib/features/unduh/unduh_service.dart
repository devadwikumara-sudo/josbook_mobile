import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../../core/api_client.dart';

enum JenisUnduhan {
  biodata('biodata', 'Biodata'),
  nilai('nilai', 'Nilai'),
  hadir('hadir', 'Hadir'),
  ekskul('ekskul', 'Ekskul'),
  semua('semua', 'Semua');

  const JenisUnduhan(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class UnduhService {
  Future<void> unduh({
    required JenisUnduhan jenis,
    required String tahunAjaran,
    required String semester,
  }) async {
    final bytes = await ApiClient.instance.getBytes(
      '/unduh',
      query: {
        'jenis': jenis.apiValue,
        'tahun_ajaran': tahunAjaran,
        'semester': semester.toLowerCase(),
      },
      accept: 'application/pdf',
    );

    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException(
        'Server tidak mengirim dokumen PDF yang valid.',
      );
    }

    final namaFile =
        'josbook-${jenis.apiValue}-${tahunAjaran.replaceAll('/', '-')}-'
        '${semester.toLowerCase()}.pdf';
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
}
