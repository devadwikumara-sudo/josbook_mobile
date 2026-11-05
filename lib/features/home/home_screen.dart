import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../shared/widgets/navbar.dart';
import '../auth/auth_provider.dart';

/// Home SEMENTARA: hanya membuktikan aplikasi sudah terhubung ke Laravel
/// (memanggil GET /home). Desain Home yang sebenarnya dibuat tahap berikutnya.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _muat();
  }

  Future<Map<String, dynamic>> _muat() async {
    final res = await ApiClient.instance.get('/home');
    return Map<String, dynamic>.from(res['data'] as Map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.home),
      appBar: AppBar(
        title: const Text('JosBook'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }

          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Halo, ${d['nama']}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Kelas ${d['kelas'] ?? '-'} | NISN: ${d['nisn']}'),
              Text('Status: ${d['status'] ?? '-'}'),
              Text('Tahun ajaran ${d['tahun_ajaran'] ?? '-'} · Semester ${d['semester']}'),
              const SizedBox(height: 16),
              if (context.watch<AuthProvider>().wajibGantiPassword)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                        'Akun ini wajib mengganti password. (Layar Ganti Password dibuat di tahap berikutnya.)'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}