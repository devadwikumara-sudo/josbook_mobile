import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets/navbar.dart';
import '../../shared/widgets/state_views.dart';
import '../unduh/unduh_service.dart';
import 'nilai_model.dart';
import 'nilai_provider.dart';
import 'nilai_service.dart';

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key, this.service, this.unduhService});

  final NilaiService? service;
  final UnduhService? unduhService;

  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  late final NilaiProvider _provider;
  late final UnduhService _unduhService;
  bool _sedangUnduh = false;

  @override
  void initState() {
    super.initState();
    _provider = NilaiProvider(
      service: widget.service ?? const MockNilaiService(),
    );
    _unduhService = widget.unduhService ?? UnduhService();
    unawaited(_provider.muatPeriode());
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _unduh() async {
    final periode = _provider.periodeTerpilih;
    if (periode == null || _sedangUnduh) return;

    setState(() => _sedangUnduh = true);
    try {
      await _unduhService.unduh(
        jenis: JenisUnduhan.nilai,
        tahunAjaran: periode.tahunAjaran,
        semester: periode.semester,
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
                child: AnimatedBuilder(
                  animation: _provider,
                  builder: (context, _) => _isi(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _isi() {
    final provider = _provider;
    final periode = provider.periodeTerpilih;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (provider.memuatPeriode)
          const _MemuatNilai()
        else if (provider.errorPeriode != null)
          _ErrorNilai(
            pesan: provider.errorPeriode!,
            onUlang: () => unawaited(provider.muatPeriode()),
          )
        else if (periode == null)
          const _KartuNilai(data: null)
        else ...[
          _PilihTahun(
            nilai: periode.tahunAjaran,
            daftar: provider.periode
                .map((item) => item.tahunAjaran)
                .toSet()
                .toList(),
            onChanged: (tahun) => unawaited(provider.pilihTahun(tahun)),
          ),
          const SizedBox(height: 10),
          _PilihSemester(
            periode: provider.periode
                .where((item) => item.tahunAjaran == periode.tahunAjaran)
                .toList(),
            terpilih: periode.semester,
            onChanged: (semester) =>
                unawaited(provider.pilihSemester(semester)),
          ),
          const SizedBox(height: 14),
          if (provider.memuatNilai)
            const _MemuatNilai()
          else if (provider.errorNilai != null)
            _ErrorNilai(
              pesan: provider.errorNilai!,
              onUlang: () => unawaited(provider.muatNilai()),
            )
          else
            _KartuNilai(data: provider.data),
        ],
        const SizedBox(height: 22),
        _TombolUnduh(
          sedangUnduh: _sedangUnduh,
          aktif: periode != null && !provider.memuatPeriode,
          onTap: _unduh,
        ),
      ],
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
            for (final tahun in daftar)
              DropdownMenuItem(value: tahun, child: Text(tahun)),
          ],
          onChanged: (tahun) {
            if (tahun != null) onChanged(tahun);
          },
        ),
      ),
    );
  }
}

class _PilihSemester extends StatelessWidget {
  const _PilihSemester({
    required this.periode,
    required this.terpilih,
    required this.onChanged,
  });

  final List<NilaiPeriode> periode;
  final String terpilih;
  final ValueChanged<String> onChanged;

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
          for (final item in periode)
            Expanded(
              child: _ItemSemester(
                label: item.semester,
                aktif: terpilih == item.semester,
                onTap: () => onChanged(item.semester),
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

class _MemuatNilai extends StatelessWidget {
  const _MemuatNilai();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat nilai...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorNilai extends StatelessWidget {
  const _ErrorNilai({required this.pesan, required this.onUlang});

  final String pesan;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(
      title: 'Nilai gagal dimuat.',
      message: pesan,
      onRetry: onUlang,
      compact: true,
      retryIcon: Icons.refresh,
      titleStyle: const TextStyle(color: WarnaJosBook.merah),
      messageStyle: const TextStyle(color: WarnaJosBook.merah),
    );
  }
}

class _KartuNilai extends StatelessWidget {
  const _KartuNilai({required this.data});

  final NilaiData? data;

  @override
  Widget build(BuildContext context) {
    final mapel = data?.mapel ?? const <NilaiMapel>[];
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
      child: mapel.isEmpty
          ? const EmptyStateView(
              message: 'Belum ada nilai untuk semester ini',
              padding: EdgeInsets.symmetric(vertical: 28),
              textStyle: TextStyle(color: Color(0xFF718096), fontSize: 14),
            )
          : Column(
              children: [
                for (final item in mapel)
                  _BarisNilai(
                    label: item.nama,
                    nilai: _formatNilai(item.nilai),
                  ),
                _BarisNilai(
                  label: 'Rata-rata',
                  nilai: _formatNilai(data!.rataRata),
                  garis: false,
                ),
              ],
            ),
    );
  }

  String _formatNilai(num? nilai) =>
      nilai?.toString().replaceAll('.', ',') ?? '-';
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
      builder: (context, constraints) {
        const lebar = 4.0;
        const jarak = 3.0;
        final jumlah = (constraints.maxWidth / (lebar + jarak)).floor();
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
  const _TombolUnduh({
    required this.sedangUnduh,
    required this.aktif,
    required this.onTap,
  });

  final bool sedangUnduh;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: aktif ? const Color(0xFF12365F) : const Color(0xFF7F8B99),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: aktif && !sedangUnduh ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sedangUnduh)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              const SizedBox(width: 8),
              const Text(
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
