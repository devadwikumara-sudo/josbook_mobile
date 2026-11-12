import '../../core/api_client.dart';
import 'notifikasi_model.dart';

abstract class NotifikasiService {
  Future<DaftarNotifikasi> ambilNotifikasi();

  Future<void> tandaiDibaca(String id);
}

class HttpNotifikasiService implements NotifikasiService {
  HttpNotifikasiService({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  @override
  Future<DaftarNotifikasi> ambilNotifikasi() async {
    final response = await _api.get('/notifikasi');
    return DaftarNotifikasi.dariJson(response);
  }

  @override
  Future<void> tandaiDibaca(String id) async {
    await _api.post('/notifikasi/$id/baca');
  }
}
