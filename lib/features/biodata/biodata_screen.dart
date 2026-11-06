import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';

class BiodataScreen extends StatelessWidget {
  const BiodataScreen({super.key});

  static const _baris = [
    MapEntry('Nama', 'Indra Kusuma'),
    MapEntry('NISN', '0098202509'),
    MapEntry('NIS', '5509'),
    MapEntry('TTL', 'Nganjuk, 10 Januari 2009'),
    MapEntry('Agama', 'Islam'),
    MapEntry('Alamat', 'Dsn. Kedungbulu'),
    MapEntry('Ayah', 'Ayah Indra'),
    MapEntry('Ibu', 'Ibu Indra'),
    MapEntry('Wali', '-'),
    MapEntry('Asal sekolah', 'SMPN 1 Rejoso'),
    MapEntry('Tgl diterima', '17 Juli 2025'),
    MapEntry('Tinggi / berat', '174 cm / 59 kg'),
  ];

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
                    Material(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Kembali ke Home',
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
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
                child: ListView(
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
                          fontSize: 12,
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
                          for (final row in _baris)
                            _BarisBiodata(label: row.key, nilai: row.value),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur unduh biodata PDF akan tersedia nanti.',
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: WarnaJosBook.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Unduh biodata (PDF)'),
                      ),
                    ),
                  ],
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
