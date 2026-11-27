import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../shared/widgets/animasi_josbook.dart';
import '../../shared/widgets/latar_halaman.dart';
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
        _periodeTerpilih =
            pilihan ??
            (hasil.isEmpty
                ? null
                : hasil.firstWhere(
                    (item) => item.terpilih,
                    orElse: () => hasil.first,
                  ));
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
        tahunAjaranId: _butuhPeriode ? periode?.tahunAjaranId : null,
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
      backgroundColor: latarHalamanJosBook,
      bottomNavigationBar: const NavbarJosBook(aktif: TabNav.unduh),
      body: LatarGradasiJosBook(
        child: SafeArea(
          child: Column(
            children: [
              HeaderHalamanJosBook(
                judul: 'Unduh data',
                tooltipKembali: 'Kembali ke Home',
                onKembali: () => context.go('/home'),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    MasukBertahap(
                      tunda: Duration.zero,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: garisKartuJosBook),
                          boxShadow: [
                            BoxShadow(
                              color: WarnaJosBook.navy.withValues(alpha: 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: WarnaJosBook.biruMuda,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: WarnaJosBook.navy,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ekspor Dokumen PDF',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: WarnaJosBook.teks,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Pilih jenis dokumen dan periode',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: teksPudarJosBook,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _pilihJenis(),
                            if (_butuhPeriode) ...[
                              const SizedBox(height: 12),
                              if (_errorPeriode != null)
                                _pesanErrorPeriode()
                              else if (_periode.isEmpty && !_memuatPeriode)
                                _pesanKosongPeriode()
                              else ...[
                                _pilihTahun(),
                                const SizedBox(height: 12),
                                _pilihSemester(),
                              ],
                            ],
                            const SizedBox(height: 18),
                            KartuTekan(
                              child: SizedBox(
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
                                    backgroundColor: WarnaJosBook.navy,
                                    disabledBackgroundColor: const Color(
                                      0xFF9AA5B4,
                                    ),
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white70,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: _sedangUnduh
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.download_for_offline_outlined,
                                        ),
                                  label: Text(
                                    _sedangUnduh
                                        ? 'Menyiapkan PDF...'
                                        : 'Unduh PDF',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: latarHalamanJosBook,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: garisKartuJosBook),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: teksPudarJosBook,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Semua semester dapat dipilih. Semester yang '
                                      'belum memiliki nilai akan tampil kosong dan '
                                      'tetap dapat diunduh.',
                                      style: TextStyle(
                                        color: teksPudarJosBook,
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAF2),
        borderRadius: BorderRadius.circular(12),
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
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: latarHalamanJosBook,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: garisKartuJosBook),
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
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAF2),
        borderRadius: BorderRadius.circular(12),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: terpilih ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: terpilih
              ? [
                  BoxShadow(
                    color: WarnaJosBook.navy.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: terpilih ? WarnaJosBook.navy : teksPudarJosBook,
              fontSize: 12.5,
              fontWeight: terpilih ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
