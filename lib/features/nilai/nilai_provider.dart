import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'nilai_model.dart';
import 'nilai_service.dart';

class NilaiProvider extends ChangeNotifier {
  NilaiProvider({required NilaiService service}) : _service = service;

  final NilaiService _service;

  List<NilaiPeriode> periode = const [];
  NilaiPeriode? periodeTerpilih;
  NilaiData? data;
  bool memuatPeriode = true;
  bool memuatNilai = false;
  String? errorPeriode;
  String? errorNilai;

  int _requestPeriode = 0;
  int _requestNilai = 0;

  Future<void> muatPeriode() async {
    final request = ++_requestPeriode;
    ++_requestNilai;
    memuatPeriode = true;
    memuatNilai = false;
    errorPeriode = null;
    errorNilai = null;
    data = null;
    periodeTerpilih = null;
    notifyListeners();

    try {
      final hasil = await _service.ambilPeriode();
      if (request != _requestPeriode) return;

      periode = hasil;
      periodeTerpilih = hasil.isEmpty ? null : hasil.first;
      memuatPeriode = false;
      notifyListeners();

      if (periodeTerpilih != null) await muatNilai();
    } catch (error) {
      if (request != _requestPeriode) return;
      errorPeriode = _pesanError(error);
      memuatPeriode = false;
      notifyListeners();
    }
  }

  Future<void> pilihTahun(String tahunAjaran) async {
    final pilihan = periode.where((item) => item.tahunAjaran == tahunAjaran);
    if (pilihan.isEmpty) return;
    await _pilihPeriode(pilihan.first);
  }

  Future<void> pilihSemester(String semester) async {
    final tahun = periodeTerpilih?.tahunAjaran;
    if (tahun == null) return;
    for (final item in periode) {
      if (item.tahunAjaran == tahun && item.semester == semester) {
        await _pilihPeriode(item);
        return;
      }
    }
  }

  Future<void> _pilihPeriode(NilaiPeriode pilihan) async {
    if (periodeTerpilih?.tahunAjaran == pilihan.tahunAjaran &&
        periodeTerpilih?.semester == pilihan.semester) {
      return;
    }
    periodeTerpilih = pilihan;
    data = null;
    errorNilai = null;
    await muatNilai();
  }

  Future<void> muatNilai() async {
    final pilihan = periodeTerpilih;
    if (pilihan == null) return;

    final request = ++_requestNilai;
    memuatNilai = true;
    errorNilai = null;
    data = null;
    notifyListeners();

    try {
      final hasil = await _service.ambilNilai(pilihan);
      if (request != _requestNilai) return;
      data = hasil;
    } catch (error) {
      if (request != _requestNilai) return;
      errorNilai = _pesanError(error);
    } finally {
      if (request == _requestNilai) {
        memuatNilai = false;
        notifyListeners();
      }
    }
  }

  String _pesanError(Object error) =>
      error is ApiException ? error.pesan : 'Terjadi kesalahan. Coba lagi.';
}
