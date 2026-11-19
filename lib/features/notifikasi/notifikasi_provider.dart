import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'notifikasi_model.dart';
import 'notifikasi_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  NotifikasiProvider({required NotifikasiService service}) : _service = service;

  final NotifikasiService _service;

  List<Notifikasi> _items = const [];
  int _jumlahBelumDibaca = 0;
  String? _error;
  bool _memuat = false;

  List<Notifikasi> get items => _items;
  int get jumlahBelumDibaca => _jumlahBelumDibaca;
  String? get error => _error;
  bool get memuat => _memuat;

  Future<void> muat() async {
    _memuat = true;
    _error = null;
    notifyListeners();
    try {
      final DaftarNotifikasi daftar = await _service.ambilNotifikasi();
      _items = daftar.items;
      _jumlahBelumDibaca = daftar.jumlahBelumDibaca;
    } catch (error) {
      _error = error is ApiException
          ? error.pesan
          : 'Terjadi kesalahan saat memuat notifikasi. Coba lagi.';
    } finally {
      _memuat = false;
      notifyListeners();
    }
  }

  Future<void> tandaiDibaca(String id) async {
    final int index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].dibaca) return;

    await _service.tandaiDibaca(id);
    _items = [
      for (final item in _items)
        if (item.id == id) item.tandaiDibaca() else item,
    ];
    if (_jumlahBelumDibaca > 0) _jumlahBelumDibaca--;
    notifyListeners();
  }

  Future<void> tandaiSemuaDibaca() async {
    if (_jumlahBelumDibaca == 0) return;
    await _service.tandaiSemuaDibaca();
    _items = _items.map((item) => item.tandaiDibaca()).toList(growable: false);
    _jumlahBelumDibaca = 0;
    notifyListeners();
  }
}
