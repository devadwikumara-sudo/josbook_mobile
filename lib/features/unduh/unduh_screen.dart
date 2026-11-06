import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';
import 'unduh_service.dart';

class UnduhScreen extends StatefulWidget {
  const UnduhScreen({super.key});

  @override
  State<UnduhScreen> createState() => _UnduhScreenState();
}

class _UnduhScreenState extends State<UnduhScreen> {
  final UnduhService _service = UnduhService();
  final List<String> _semester = ['Ganjil', 'Genap'];

  JenisUnduhan _jenis = JenisUnduhan.biodata;
  String? _tahunAjaran;
  String _semesterTerpilih = 'Ganjil';
  List<String> _daftarTahun = const [];
  Object? _errorPeriode;
  bool _memuatPeriode = true;
  bool _sedangUnduh = false;

  @override
  void initState() {
    super.initState();
    _muatPeriode();
  }

  Future<void> _muatPeriode() async {
    setState(() {
      _memuatPeriode = true;
      _errorPeriode = null;
    });

    try {
      final response = await ApiClient.instance.get('/home');
      final data = response['data'];
      if (data is! Map) {
        throw const FormatException('Data periode dari server tidak valid.');
      }

      final tahunAktif = data['tahun_ajaran']?.toString().trim() ?? '';
      final tahunMulai = RegExp(r'^(\d{4})').firstMatch(tahunAktif);
      if (tahunMulai == null) {
        throw const FormatException(
          'Tahun ajaran aktif tidak tersedia dari server.',
        );
      }

      final awal = int.parse(tahunMulai.group(1)!);
      final daftarTahun = [
        tahunAktif,
        for (var index = 1; index < 10; index++)
          '${awal - index}/${awal - index + 1}',
      ];
      final semesterAktif = data['semester']?.toString().toLowerCase();

      if (!mounted) return;
      setState(() {
        _tahunAjaran = daftarTahun.first;
        _daftarTahun = daftarTahun;
        if (semesterAktif != null &&
            (semesterAktif == 'ganjil' || semesterAktif == 'genap')) {
          _semesterTerpilih =
              semesterAktif[0].toUpperCase() + semesterAktif.substring(1);
        }
        _memuatPeriode = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorPeriode = error;
        _memuatPeriode = false;
      });
    }
  }

  Future<void> _unduh() async {
    final tahun = _tahunAjaran;
    if (tahun == null || _sedangUnduh) return;

    setState(() => _sedangUnduh = true);
    try {
      await _service.unduh(
        jenis: _jenis,
        tahunAjaran: tahun,
        semester: _semesterTerpilih,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Unduhan gagal: $error'),
            backgroundColor: WarnaJosBook.merah,
          ),
        );
    } finally {
      if (mounted) setState(() => _sedangUnduh = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.unduh),
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
                        'Unduh data',
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
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 24),
                  children: [
                    _pilihJenis(),
                    const SizedBox(height: 10),
                    _pilihTahun(),
                    const SizedBox(height: 10),
                    _pilihSemester(),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _memuatPeriode || _sedangUnduh
                            ? null
                            : _unduh,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF12385F),
                          disabledBackgroundColor: const Color(0xFF12385F),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        icon: _sedangUnduh
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_for_offline_outlined),
                        label: Text(
                          _sedangUnduh ? 'Menyiapkan PDF...' : 'Unduh PDF',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_errorPeriode != null)
                      _pesanErrorPeriode()
                    else
                      const Text(
                        'Hanya tahun ajaran dan semester yang sudah dijalani '
                        'yang bisa dibuka. Data tidak dapat diubah dari app.',
                        style: TextStyle(
                          color: Color(0xFF758396),
                          fontSize: 12,
                          height: 1.35,
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

  Widget _pilihJenis() {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (final jenis in JenisUnduhan.values)
            Expanded(
              child: _TombolPilihan(
                label: jenis.label,
                terpilih: _jenis == jenis,
                onTap: () => setState(() => _jenis = jenis),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pilihTahun() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: _memuatPeriode
          ? const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _tahunAjaran,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  for (final tahun in _daftarTahun)
                    DropdownMenuItem(value: tahun, child: Text(tahun)),
                ],
                onChanged: _daftarTahun.isEmpty
                    ? null
                    : (tahun) {
                        if (tahun != null) setState(() => _tahunAjaran = tahun);
                      },
              ),
            ),
    );
  }

  Widget _pilihSemester() {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (final semester in _semester)
            Expanded(
              child: _TombolPilihan(
                label: semester,
                terpilih: _semesterTerpilih == semester,
                onTap: () => setState(() => _semesterTerpilih = semester),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pesanErrorPeriode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Periode unduhan gagal dimuat.\n$_errorPeriode',
          style: const TextStyle(
            color: WarnaJosBook.merah,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        TextButton.icon(
          onPressed: _muatPeriode,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }
}

class _TombolPilihan extends StatelessWidget {
  const _TombolPilihan({
    required this.label,
    required this.terpilih,
    required this.onTap,
  });

  final String label;
  final bool terpilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: terpilih ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: terpilih ? WarnaJosBook.navy : const Color(0xFF667085),
              fontSize: 12,
              fontWeight: terpilih ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
