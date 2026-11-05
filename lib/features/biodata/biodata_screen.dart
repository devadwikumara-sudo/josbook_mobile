import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _muat();
  }

  Future<Map<String, dynamic>> _muat() async {
    final res = await ApiClient.instance.get('/home');
    final data = res['data'];
    if (data is! Map) {
      throw const FormatException(
        'Format data biodata dari server tidak valid.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  String _teks(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '-';
  }

  List<MapEntry<String, String>> _baris(Map<String, dynamic> data) {
    final tempatLahir = _teks(data, ['tempat_lahir']);
    final tanggalLahir = _teks(data, ['tanggal_lahir', 'tgl_lahir']);
    final ttl = [
      if (tempatLahir != '-') tempatLahir,
      if (tanggalLahir != '-') tanggalLahir,
    ].join(', ');

    final tinggi = _teks(data, ['tinggi', 'tinggi_badan']);
    final berat = _teks(data, ['berat', 'berat_badan']);
    final tinggiBerat = [
      if (tinggi != '-') '$tinggi cm',
      if (berat != '-') '$berat kg',
    ].join(' / ');

    return [
      MapEntry('Nama', _teks(data, ['nama'])),
      MapEntry('NISN', _teks(data, ['nisn'])),
      MapEntry('NIS', _teks(data, ['nis'])),
      MapEntry('TTL', ttl.isEmpty ? _teks(data, ['ttl']) : ttl),
      MapEntry('Agama', _teks(data, ['agama'])),
      MapEntry('Alamat', _teks(data, ['alamat'])),
      MapEntry('Ayah', _teks(data, ['ayah', 'nama_ayah'])),
      MapEntry('Ibu', _teks(data, ['ibu', 'nama_ibu'])),
      MapEntry('Wali', _teks(data, ['wali', 'nama_wali'])),
      MapEntry('Asal sekolah', _teks(data, ['asal_sekolah', 'sekolah_asal'])),
      MapEntry(
        'Tgl diterima',
        _teks(data, ['tgl_diterima', 'tanggal_diterima']),
      ),
      MapEntry(
        'Tinggi / berat',
        tinggiBerat.isEmpty ? _teks(data, ['tinggi_berat']) : tinggiBerat,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.biodata),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WarnaJosBook.navy,
              Color(0xFF2F80ED),
              Color(0xFFEAF2FF),
              Colors.white,
            ],
            stops: [0, 0.22, 0.42, 0.58],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 72,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Kembali ke Home',
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Biodata',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _data,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Biodata gagal dimuat.\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: WarnaJosBook.teks,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () {
                                  setState(() => _data = _muat());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: () async {
                        final dataBaru = _muat();
                        setState(() => _data = dataBaru);
                        await dataBaru;
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'HANYA LIHAT',
                              style: TextStyle(
                                color: WarnaJosBook.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                for (final row in _baris(data))
                                  _BarisBiodata(
                                    label: row.key,
                                    nilai: row.value,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarisBiodata extends StatelessWidget {
  const _BarisBiodata({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4EAF2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WarnaJosBook.teks,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
