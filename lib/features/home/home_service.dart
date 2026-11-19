import '../../core/api_client.dart';
import 'home_data.dart';

/// Panggilan API untuk layar Home. Tidak menyimpan state.
class HomeService {
  /// GET /home — endpoint yang sudah ada di Laravel.
  Future<HomeData> muat() async {
    final res = await ApiClient.instance.get('/home');
    return HomeData.dariJson(Map<String, dynamic>.from(res['data'] as Map));
  }
}
