import '../../core/api_client.dart';
import 'biodata_model.dart';

class BiodataService {
  BiodataService({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  Future<BiodataData> ambil() async {
    final response = await _api.get('/biodata');
    final Object? data = response['data'];
    if (data is! Map) {
      throw const FormatException('Data biodata dari server tidak valid.');
    }
    return BiodataData.dariJson(Map<String, dynamic>.from(data));
  }
}
