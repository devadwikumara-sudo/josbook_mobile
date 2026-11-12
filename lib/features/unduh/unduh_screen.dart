import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';
import '../../shared/widgets/state_views.dart';
import '../nilai/nilai_model.dart';
import '../nilai/nilai_service.dart';
import 'unduh_service.dart';

class UnduhScreen extends StatefulWidget {
  const UnduhScreen({super.key, this.service, this.periodeService});

  final UnduhService? service;
  final NilaiService? periodeService;

  @override
  State<UnduhScreen> createState() => _UnduhScreenState();
}

class _UnduhScreenState extends State<UnduhScreen> {
  late final UnduhService _service;
  late final NilaiService _periodeService;

  JenisUnduhan _jenis = JenisUnduhan.biodata;
  List<NilaiPeriode> _periode = const [];
  NilaiPeriode? _periodeTerpilih;
  Object? _errorPeriode;
  bool _memuatPeriode = true;
  bool _sedangUnduh = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? UnduhService();
    _periodeService = widget.periodeService ?? HttpNilaiService();
    _muatPeriode();
  }

  Future<void> _muatPeriode() async {
    setState(() {
      _memuatPeriode = true;
      _errorPeriode = null;
    });

    try {
      final hasil = await _periodeService.ambilPeriode();
      final pilihanLama = _periodeTerpilih;
      NilaiPeriode? pilihan;
      if (pilihanLama != null) {
        for (final item in hasil) {
          if (item.tahunAjaran == pilihanLama.tahunAjaran &&
              item.semester == pilihanLama.semester) {
            pilihan = item;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _periode = hasil;
        _periodeTerpilih = pilihan ?? (hasil.isEmpty ? null : hasil.first);
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
    final periode = _periodeTerpilih;
    if (_sedangUnduh || (_butuhPeriode && periode == null)) return;

    setState(() => _sedangUnduh = true);
    try {
      await _service.unduh(
        jenis: _jenis,
        tahunAjaran: _butuhPeriode ? periode?.tahunAjaran : null,
        semester: _butuhPeriode ? periode?.semester : null,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unduhan gagal: ${error is ApiException ? error.pesan : 'Coba lagi.'}',
            ),
            backgroundColor: WarnaJosBook.merah,
          ),
        );
    } finally {
      if (mounted) setState(() => _sedangUnduh = false);
    }
  }

  bool get _butuhPeriode => _jenis != JenisUnduhan.biodata;

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
                    if (_butuhPeriode) ...[
                      const SizedBox(height: 10),
                      if (_errorPeriode != null)
                        _pesanErrorPeriode()
                      else if (_periode.isEmpty && !_memuatPeriode)
                        _pesanKosongPeriode()
                      else ...[
                        _pilihTahun(),
                        const SizedBox(height: 10),
                        _pilihSemester(),
                      ],
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed:
                            _sedangUnduh ||
                                (_butuhPeriode &&
                                    (_memuatPeriode ||
                                        _errorPeriode != null ||
                                        _periodeTerpilih == null))
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
    final daftarTahun = _periode
        .map((item) => item.tahunAjaran)
        .toSet()
        .toList(growable: false);
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
                value: _periodeTerpilih?.tahunAjaran,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  for (final tahun in daftarTahun)
                    DropdownMenuItem(value: tahun, child: Text(tahun)),
                ],
                onChanged: daftarTahun.isEmpty
                    ? null
                    : (tahun) {
                        if (tahun != null) _setTahunAjaran(tahun);
                      },
              ),
            ),
    );
  }

  void _setTahunAjaran(String tahunAjaran) {
    final pilihan = _periode.firstWhere(
      (item) => item.tahunAjaran == tahunAjaran,
    );
    setState(() => _periodeTerpilih = pilihan);
  }

  Widget _pilihSemester() {
    final periodeTahunIni = _periode
        .where((item) => item.tahunAjaran == _periodeTerpilih?.tahunAjaran)
        .toList(growable: false);
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (final periode in periodeTahunIni)
            Expanded(
              child: _TombolPilihan(
                label: periode.semester,
                terpilih: _periodeTerpilih?.semester == periode.semester,
                onTap: () => setState(() => _periodeTerpilih = periode),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pesanErrorPeriode() {
    return ErrorStateView(
      message:
          'Periode unduhan gagal dimuat.\n'
          '${_errorPeriode is ApiException ? (_errorPeriode as ApiException).pesan : 'Terjadi kesalahan. Coba lagi.'}',
      onRetry: _muatPeriode,
      compact: true,
      alignment: CrossAxisAlignment.start,
      retryIcon: Icons.refresh,
      messageStyle: const TextStyle(
        color: WarnaJosBook.merah,
        fontSize: 12,
        height: 1.35,
      ),
    );
  }

  Widget _pesanKosongPeriode() {
    return const EmptyStateView(
      message: 'Belum ada periode yang bisa diunduh.',
      padding: EdgeInsets.symmetric(vertical: 12),
      textStyle: TextStyle(color: Color(0xFF758396), fontSize: 12),
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
