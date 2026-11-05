import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';

/// Satu baris nilai mata pelajaran.
class NilaiMapel {
  const NilaiMapel(this.mapel, this.nilai);

  final String mapel;
  final int nilai;
}

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key});

  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  static const List<String> _daftarTahun = [
    '2022/2023',
    '2023/2024',
    '2024/2025',
    '2025/2026',
  ];

  // Urutan mapel (sama untuk semua tahun dan semester).
  static const List<String> _daftarMapel = [
    'Pendidikan Agama dan Budi Pekerti',
    'Pendidikan Pancasila',
    'Bahasa Indonesia',
    'Matematika',
    'Ilmu Pengetahuan Alam (IPA)',
    'Ilmu Pengetahuan Sosial (IPS)',
    'Bahasa Inggris',
    'Pendidikan Jasmani Olahraga dan Kesehatan',
    'Seni Budaya dan Prakarya/Seni dan Budaya',
    'Informatika',
    'Bahasa Jawa',
  ];

  // TODO: ganti dengan data dari API Laravel kalau endpoint nilai sudah ada,
  // misalnya ApiClient.instance.get('/nilai?tahun=$_tahun&semester=...').
  // Sementara ini data contoh. Kunci: 'tahun|semester' (1 = Ganjil, 2 = Genap).
  // Urutan angka mengikuti urutan _daftarMapel di atas.
  static const Map<String, List<int>> _dataNilai = {
    '2025/2026|1': [92, 82, 87, 92, 82, 87, 92, 82, 87, 92, 82],
    '2025/2026|2': [90, 85, 88, 89, 84, 86, 91, 83, 88, 90, 85],
    '2024/2025|1': [88, 80, 85, 86, 81, 84, 89, 80, 85, 88, 82],
    '2024/2025|2': [89, 82, 86, 87, 83, 85, 90, 81, 86, 89, 83],
    '2023/2024|1': [85, 78, 83, 84, 79, 82, 86, 78, 83, 85, 80],
    '2023/2024|2': [86, 80, 84, 85, 80, 83, 87, 79, 84, 86, 81],
    '2022/2023|1': [82, 76, 80, 81, 77, 79, 83, 76, 80, 82, 78],
    '2022/2023|2': [83, 77, 81, 82, 78, 80, 84, 77, 81, 83, 79],
  };

  String _tahun = _daftarTahun.last;
  bool _ganjil = true;

  List<NilaiMapel> _ambilNilai() {
    final angka = _dataNilai['$_tahun|${_ganjil ? 1 : 2}'];
    if (angka == null) return const [];
    return [
      for (var i = 0; i < _daftarMapel.length; i++)
        NilaiMapel(_daftarMapel[i], angka[i]),
    ];
  }

  String _rataRata(List<NilaiMapel> data) {
    if (data.isEmpty) return '-';
    final total = data.fold<int>(0, (jumlah, e) => jumlah + e.nilai);
    return (total / data.length).toStringAsFixed(2).replaceAll('.', ',');
  }

  void _unduh() {
    // TODO: sambungkan ke endpoint unduh nilai kalau backend sudah siap.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur unduh belum tersedia.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _ambilNilai();

    return Scaffold(
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.nilai),
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
                        'Nilai',
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _PilihTahun(
                      nilai: _tahun,
                      daftar: _daftarTahun,
                      onChanged: (v) => setState(() => _tahun = v),
                    ),
                    const SizedBox(height: 10),
                    _PilihSemester(
                      ganjil: _ganjil,
                      onChanged: (v) => setState(() => _ganjil = v),
                    ),
                    const SizedBox(height: 14),
                    _KartuNilai(data: data, rataRata: _rataRata(data)),
                    const SizedBox(height: 22),
                    _TombolUnduh(onTap: _unduh),
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

class _PilihTahun extends StatelessWidget {
  const _PilihTahun({
    required this.nilai,
    required this.daftar,
    required this.onChanged,
  });

  final String nilai;
  final List<String> daftar;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: nilai,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(
            color: WarnaJosBook.teks,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: [
            for (final t in daftar) DropdownMenuItem(value: t, child: Text(t)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _PilihSemester extends StatelessWidget {
  const _PilihSemester({required this.ganjil, required this.onChanged});

  final bool ganjil;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAF2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ItemSemester(
              label: 'Ganjil',
              aktif: ganjil,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ItemSemester(
              label: 'Genap',
              aktif: !ganjil,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemSemester extends StatelessWidget {
  const _ItemSemester({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  final String label;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: aktif ? WarnaJosBook.teks : const Color(0xFF718096),
            fontSize: 14,
            fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _KartuNilai extends StatelessWidget {
  const _KartuNilai({required this.data, required this.rataRata});

  final List<NilaiMapel> data;
  final String rataRata;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: data.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Belum ada nilai untuk semester ini.',
                  style: TextStyle(color: Color(0xFF718096)),
                ),
              ),
            )
          : Column(
              children: [
                for (final e in data)
                  _BarisNilai(label: e.mapel, nilai: '${e.nilai}'),
                _BarisNilai(label: 'Rata-rata', nilai: rataRata, garis: false),
              ],
            ),
    );
  }
}

class _BarisNilai extends StatelessWidget {
  const _BarisNilai({
    required this.label,
    required this.nilai,
    this.garis = true,
  });

  final String label;
  final String nilai;
  final bool garis;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                nilai,
                style: const TextStyle(
                  color: WarnaJosBook.teks,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (garis) const _GarisPutus(),
      ],
    );
  }
}

class _GarisPutus extends StatelessWidget {
  const _GarisPutus();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const lebar = 4.0;
        const jarak = 3.0;
        final jumlah = (c.maxWidth / (lebar + jarak)).floor();
        return Row(
          children: List.generate(
            jumlah,
            (_) => const Padding(
              padding: EdgeInsets.only(right: jarak),
              child: SizedBox(
                width: lebar,
                height: 1,
                child: ColoredBox(color: Color(0xFFD5DEEA)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TombolUnduh extends StatelessWidget {
  const _TombolUnduh({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF12365F),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Unduh nilai semester ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}